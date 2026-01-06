local M = {}

local hare = require 'hare-conf'

local status_column_str = ''

--- Sets up editor appearance configuration.
---
--- This is the main entry point for editor appearance-related settings. It applies configuration
--- for line numbers, sign column visibility, status column behavior, and fill characters.
function M.setup()
    M.apply_status_column()
    M.apply_fill_chars()
    M.apply_diagnostic()
    M.apply_treesitter()
    M.apply_indent()
    M.apply_format_on_save()
end

--- Applies and configure the editor `statuscolumn`.
---
--- This function builds and activates a custom `statuscolumn` based on
--- `hare.config.editor.appearance.status_column`. It:
---
---     - Enables or disables the status column globally
---     - Configures sign column visibility
---     - Configures line numbers (absolute / relative)
---     - Applies line number highlight groups
---     - Constructs the final `statuscolumn` format string
---     - Installs an autocmd to apply the status column per-window,
---
--- respecting excluded filetypes and buftypes
---
--- When the status column is disabled, this function clears the option and exits early.
---
---@sideeffect Sets global and window-local Neovim options:
---
---     - `statuscolumn`
---     - `signcolumn`
---     - `number`
---     - `relativenumber`
---     - `cursorline`
---     - `cursorlineopt`
--- Creates an autocmd for `WinEnter`, `BufEnter`, and `TermOpen`.
function M.apply_status_column()
    local status_column = hare.config.editor.appearance.status_column
    if not status_column.enabled then
        vim.opt.statuscolumn = ''
        return
    end

    -- Sign column configuration.
    vim.opt.signcolumn = status_column.sign_column.enabled and 'yes' or 'no'

    -- Line number configuration.
    local line_number = status_column.line_number

    vim.opt.cursorline = line_number.enabled
    vim.opt.number = line_number.enabled
    vim.opt.relativenumber = line_number.relative
    hare.fn.set_highlight('LineNr', line_number.highlight)
    hare.fn.set_highlight('CursorLineNr', line_number.cursor_highlight or {
        fg = '#ffcc66',
        bold = true,
    })

    -- Specify what parts of the line to highlight when `cursorline` is enabled.
    vim.opt.cursorlineopt = { 'number', 'line' }

    -- Build the status column string.
    local _status_column_str = ''
    if status_column.sign_column.enabled then
        _status_column_str = _status_column_str .. '%s'
    end

    if line_number.enabled then
        _status_column_str = _status_column_str
            .. '%='
            .. (
                status_column.line_number.relative
                    and '%{v:virtnum == 0 ? (v:relnum ? v:relnum : v:lnum) : \'\'}'
                or '%{v:lnum}'
            )
    end

    local suffix = status_column.suffix or ''
    _status_column_str = _status_column_str .. suffix

    -- Set the module status column string.
    status_column_str = _status_column_str

    vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter', 'TermOpen' }, {
        callback = function(args)
            local filetype = vim.bo[args.buf].filetype
            local buftype = vim.bo[args.buf].buftype
            local excluded_filetypes = hare.config.system.filetype.exclude
            local excluded_buftypes = hare.config.system.buftype.exclude

            local is_editable = not vim.tbl_contains(excluded_filetypes, filetype)
                and not vim.tbl_contains(excluded_buftypes, buftype)
            if is_editable then
                vim.wo.statuscolumn = status_column_str
            else
                vim.wo.statuscolumn = '%s'
            end
        end,
    })
end

--- Applies fill character configuration.
---
--- This function appends configured fill characters to `fillchars`, currently targeting the
--- end-of-buffer (`eob`) character.
function M.apply_fill_chars()
    local fill_chars = hare.config.editor.appearance.fill_chars
    vim.opt.fillchars:append { eob = fill_chars }
end

--- Applies diagnostic display configuration.
---
--- This function configures how diagnostics are presented in the editor, including virtual text,
--- virtual lines, underline behavior, signs, and update timing. All options are derived from the
--- editor diagnostic configuration.
function M.apply_diagnostic()
    local diagnostic = hare.config.editor.diagnostic

    vim.diagnostic.config {
        virtual_text = diagnostic.virtual_text,
        virtual_lines = diagnostic.virtual_lines,
        update_in_insert = diagnostic.update_in_insert,
        underline = diagnostic.underline,
        signs = diagnostic.signs,
        severity_sort = diagnostic.severity_sort,
    }
end

--- Applies Tree-sitter integration for buffers.
---
--- This function reads Tree-sitter-related settings from the global
--- `hare.config.editor.buffer.treesitter` configuration and merges them with per-buffer overrides
--- collected via `hare.fn.collect_buffer_configs()`.
---
--- When Tree-sitter highlighting is enabled globally, it configures `nvim-treesitter.configs` to:
---
---     - Enable highlighting by default
---     - Disable highlighting for filetypes that explicitly opt out
---
function M.apply_treesitter()
    local treesitter = hare.config.editor.buffer.treesitter
    local buffer_configs = hare.fn.collect_buffer_configs()

    -- Configure treesitter highlighting.
    if treesitter.enabled and treesitter.highlight_enabled then
        local ok_configs, nvim_treesitter_configs = pcall(require, 'nvim-treesitter.configs')
        if ok_configs then
            ---@type string[]
            local disabled_highlight_filetypes = {}
            for filetype, buffer_config in pairs(buffer_configs) do
                if not buffer_config.treesitter.highlight_enabled then
                    table.insert(disabled_highlight_filetypes, filetype)
                end
            end

            ---@diagnostic disable-next-line missing-fields
            nvim_treesitter_configs.setup {
                highlight = {
                    enable = true,
                    disable = disabled_highlight_filetypes,
                },
            }
        end
    end
end

--- Installs required Tree-sitter parsers based on buffer configuration.
---
--- This function inspects all collected buffer configurations and extracts Tree-sitter parser
--- requirements declared via `buffer_config.treesitter.name`. Supported forms:
---
---     - A single parser name (`string`)
---     - A list of parser names (`string[]`)
---
--- It then:
---
---     - Deduplicates parser names
---     - Filters out empty or invalid entries
---     - Skips parsers that are already installed
---     - Installs missing parsers using `:TSInstall`
---
--- If `nvim-treesitter` is not available, the function fails gracefully and emits a warning instead
--- of throwing an error.
function M.install_treesitter_parsers()
    local buffer_configs = hare.fn.collect_buffer_configs()

    local ok_parsers, parsers = pcall(require, 'nvim-treesitter.parsers')
    local ok_install, config = pcall(require, 'nvim-treesitter.config')
    if ok_parsers and ok_install then
        ---@type string[]
        local parser_names = {}

        local function insert_if_valid(name)
            if name ~= '' and not vim.tbl_contains(parser_names, name) then
                table.insert(parser_names, name)
            end
        end

        -- Collect required treesitter parsers from buffer configurations.
        for _, buffer_config in pairs(buffer_configs) do
            local parser_name = buffer_config.treesitter.name
            if type(parser_name) == 'string' then
                insert_if_valid(parser_name)
            elseif type(parser_name) == 'table' and vim.islist(parser_name) then
                for _, name in ipairs(parser_name) do
                    insert_if_valid(name)
                end
            end
        end

        -- Collect parsers that are yet installed.
        ---@type string[]
        local installed_parsers = config.get_installed()
        ---@type string[]
        local parsers_to_install = {}
        for _, parser_name in ipairs(parser_names) do
            if parsers[parser_name] and not vim.tbl_contains(installed_parsers, parser_name) then
                table.insert(parsers_to_install, parser_name)
            end
        end

        -- Install missing tree-sitter parsers.
        if #parsers_to_install > 0 then
            vim.cmd('TSInstall ' .. table.concat(parsers_to_install, ' '))
        end
    else
        hare.warn(
            '(apply_treesitter) nvim-treesitter is not loaded;' .. ' skipping parser installation.'
        )
    end
end

--- Applies per-buffer indentation settings.
---
--- Registers a `FileType` autocommand that configures indentation options for each buffer based on
--- its resolved buffer configuration. This includes tab vs. space behavior as well as logical,
--- display, and shift widths.
---
--- Settings are applied buffer-locally to ensure filetype-specific correctness.
function M.apply_indent()
    vim.api.nvim_create_autocmd('FileType', {
        pattern = '*',
        callback = function(args)
            local bufnr = args.buf
            local filetype = vim.bo[bufnr].filetype
            local buffer_config = hare.fn.get_buffer_config(filetype)
            vim.bo[bufnr].expandtab = buffer_config.indent.type == 'spaces'

            local width = buffer_config.indent.width
            local display_width = buffer_config.indent.display_width or width
            local shift_width = buffer_config.indent.shift_width or width
            vim.bo[bufnr].softtabstop = width
            vim.bo[bufnr].tabstop = display_width
            vim.bo[bufnr].shiftwidth = shift_width
        end,
    })
end

--- Applies format-on-save behavior.
---
--- Registers a `BufWritePre` autocommand that formats buffers before saving when enabled in the
--- buffer configuration. Formatting is delegated to the `conform` plugin and is skipped gracefully
--- if the plugin is not available.
function M.apply_format_on_save()
    vim.api.nvim_create_autocmd('bufwritepre', {
        callback = function(args)
            local ok, conform = pcall(require, 'conform')
            if not ok then
                return
            end

            local bufnr = args.buf
            local filetype = vim.bo[bufnr].filetype
            if hare.fn.get_buffer_config(filetype).format_on_save then
                conform.format { bufnr = bufnr }
            end
        end,
    })
end

--- Installs required Mason packages based on buffer configuration.
---
--- This function inspects all resolved buffer configurations and determines which Mason-managed
--- tools (LSPs, formatters, linters, and debuggers) are required. It resolves Mason package names,
--- checks installation status, and installs any missing packages.
---
--- Integration with `mason` and `mason-lspconfig` is fully guarded to ensure safe execution when
--- either plugin is not available. Any unresolved package names are reported via warnings.
function M.install_mason_packages()
    local ok_mason_registry, mason_registry = pcall(require, 'mason-registry')
    if not ok_mason_registry then
        hare.warn(
            '(install_mason_packages) mason is not loaded; '
                .. 'skipping mason package installation.'
        )
        return
    end

    local ok_mappings, mappings = pcall(require, 'mason-lspconfig.mappings')
    if not ok_mappings then
        hare.warn(
            '(install_mason_packages) mason-lspconfig is not loaded; '
                .. 'skipping mason package installation.'
        )
        return
    end

    local add_package_name_to_list = function(name_list, package_name)
        if not vim.tbl_contains(name_list, package_name) then
            table.insert(name_list, package_name)
        end
    end

    --- Resolves mason package names from a hareconf tool entry and adds them to the provided list.
    ---
    --- @param name_list string[] - List of mason package names.
    --- @param tool_entry hare.editor.buffer.Lsp
    ---     | hare.editor.buffer.Formatter
    ---     | hare.editor.buffer.Linter
    ---     | hare.editor.buffer.Debugger
    ---     - hareconf tool entry.
    local resolve_package_names = function(name_list, tool_entry)
        if not tool_entry then
            return
        end

        -- Resolve the 'name' field.
        local package_name = tool_entry.name
        if package_name and package_name ~= '' then
            add_package_name_to_list(name_list, package_name)
        end

        -- Resolve the 'packages' field.
        local packages = tool_entry.packages
        if packages and vim.islist(packages) then
            for _, package_entry in pairs(packages) do
                add_package_name_to_list(name_list, package_entry.package_name)
            end
        end
    end

    -- Collect required mason package names from all buffer configurations.
    local buffer_configs = hare.fn.collect_buffer_configs()

    ---@type string[]
    local package_names = {}
    for _, buffer_config in pairs(buffer_configs) do
        resolve_package_names(package_names, buffer_config.lsp)
        resolve_package_names(package_names, buffer_config.formatter)
        resolve_package_names(package_names, buffer_config.linter)
        resolve_package_names(package_names, buffer_config.debugger)
    end

    local lspconfig_to_package = mappings.get_mason_map().lspconfig_to_package
    local function resolve_mason_name(name)
        return name and lspconfig_to_package[name] or name
    end

    -- Resolve missing names of missing packages.
    ---@type string[]
    local packages_to_install = {}
    ---@type string[]
    local packages_not_found = {}
    for _, package_name in ipairs(package_names) do
        local ok_installable, _package = pcall(mason_registry.get_package, package_name)
        if ok_installable and not _package:is_installed() then
            table.insert(packages_to_install, package_name)
        else
            local mason_name = resolve_mason_name(package_name) or ''
            local ok_installable_mason, mason_package =
                pcall(mason_registry.get_package, mason_name)
            if ok_installable_mason then
                if not mason_package:is_installed() then
                    table.insert(packages_to_install, mason_name)
                end
            else
                table.insert(packages_not_found, package_name)
            end
        end
    end

    if #packages_not_found > 0 then
        hare.warn(
            '(install_mason_packages) Some mason packages not found: '
                .. table.concat(packages_not_found, ', ')
        )
    end

    if #packages_to_install > 0 then
        hare.info('Installing mason packages: ' .. table.concat(packages_to_install, ', '))
        for _, package_name in ipairs(packages_to_install) do
            local _package = mason_registry.get_package(package_name)
            _package:install()
        end
    end
end

--- Enables LSP servers based on buffer configurations.
---
--- Iterates over all resolved buffer configurations and enables the configured LSP servers for each
--- buffer. LSP servers may be specified directly via the `name` field or indirectly via a list of
--- package entries that expose an executable.
function M.enable_lsp()
    local buffer_configs = hare.fn.collect_buffer_configs()

    for _, buffer_config in pairs(buffer_configs) do
        local lsp = buffer_config.lsp
        if lsp.enabled then
            -- Resolve the 'name' field.
            if lsp.name and lsp.name ~= '' then
                vim.lsp.enable(lsp.name)
            end

            -- Resolve the 'packages' field.
            if lsp.packages and vim.islist(lsp.packages) then
                for _, package_entry in pairs(lsp.packages) do
                    if package_entry.executable and package_entry.executable ~= '' then
                        vim.lsp.enable(package_entry.executable)
                    end
                end
            end
        end
    end
end

--- Applies formatter configuration using Conform.
---
--- Collects formatter settings from all buffer configurations and maps filetypes to their
--- corresponding formatters. Formatter definitions may be provided via a single formatter name or a
--- list of formatter packages.
---
--- If Conform is not installed, formatter setup is skipped safely with a warning.
function M.apply_formatters()
    local ok, conform = pcall(require, 'conform')
    if not ok then
        hare.warn '(apply_formatters) Conform not installed; skipping formatter setup.'
        return
    end

    local buffer_configs = hare.fn.collect_buffer_configs()

    ---@type table<string, string[]>
    local formatters_by_ft = {}
    for filetype, buffer_config in pairs(buffer_configs) do
        local formatter = buffer_config.formatter
        if formatter.enabled then
            -- Resolve the 'name' field.
            if formatter.name and formatter.name ~= '' then
                formatters_by_ft[filetype] = { formatter.name }
            end

            -- Resolve the 'packages' field.
            if formatter.packages and vim.islist(formatter.packages) then
                ---@type string[]
                local formatters = {}
                for _, package_entry in pairs(formatter.packages) do
                    local executable = package_entry.executable
                    if executable and executable ~= '' then
                        table.insert(formatters, executable)
                    end
                end
                formatters_by_ft[filetype] = formatters
            end
        end
    end

    conform.setup { formatters_by_ft = formatters_by_ft }
end

return M
