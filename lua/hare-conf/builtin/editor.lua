local M = {}

--- Applies editor appearance configurations.
---
--- @param config hare.Editor - Editor configurations.
function M.apply_editor_config(config)
    local hc = require 'hare-conf'

    M.apply_editor_appearance_config(config.appearance)
    M.apply_diagnostic_config(config.diagnostic)

    hc.fn.clear_buffer_config_cache()
    M.create_buffer_autocommands()
end

--- Applies editor appearance configurations.
---
--- @param config hare.editor.Appearance - Editor appearance configurations.
function M.apply_editor_appearance_config(config)
    local hc = require 'hare-conf'

    -- Line numbers (line_number)
    vim.opt.number = config.line_number.enabled
    vim.opt.relativenumber = config.line_number.relative
    hc.fn.set_highlight('LineNr', config.line_number.highlight)
    hc.fn.set_highlight('CursorLineNr', config.line_number.cursor_highlight)

    -- Sign column (sign_column)
    vim.opt.signcolumn = config.sign_column.enabled and 'yes' or 'no'

    -- Fill chars (fill_chars)
    vim.opt.fillchars:append { eob = config.fill_chars }

    -- Cursor & cursor_insert
    vim.opt.guicursor = {
        'n-v-c:block-Cursor',
        'i:ver25-CursorInsert',
        'r-cr:hor20',
        'o:hor50',
        -- 'a:blinkwait500-blinkon600-blinkoff400',
    }

    hc.fn.set_highlight('Cursor', config.cursor.highlight)
    hc.fn.set_highlight('CursorInsert', config.cursor_insert.highlight)

    -- Cursor line (cursor_line)
    vim.opt.cursorline = config.cursor_line.enabled
    hc.fn.set_highlight('CursorLine', config.cursor_line.highlight)
end

--- Applies diagnostic configurations.
---
--- @param config hare.editor.Diagnostic - Diagnostic configurations.
function M.apply_diagnostic_config(config)
    vim.diagnostic.config {
        virtual_text = config.virtual_text,
        virtual_lines = config.virtual_lines,
        update_in_insert = config.update_in_insert,
        underline = config.underline,
        signs = config.signs,
        severity_sort = config.severity_sort,
    }
end

--- Creates autocommands for applying buffer-specific configurations on buffer events.
---
--- This includes:
---   - Setting indentation settings on `FileType` event.
---   - Formatting on save on `BufWritePre` event.
function M.create_buffer_autocommands()
    local hc = require 'hare-conf'

    -- Indentation settings per filetype
    vim.api.nvim_create_autocmd('FileType', {
        pattern = '*',
        callback = function(args)
            local bufnr = args.buf
            local filetype = vim.bo[bufnr].filetype
            local buffer_config = hc.fn.get_buffer_config(filetype)
            vim.bo[bufnr].expandtab = buffer_config.indent.type == 'spaces'

            local width = buffer_config.indent.width
            local display_width = buffer_config.indent.display_width or width
            local shift_width = buffer_config.indent.shift_width or width
            vim.bo[bufnr].softtabstop = width
            vim.bo[bufnr].tabstop = display_width
            vim.bo[bufnr].shiftwidth = shift_width
        end,
    })

    -- Format on save (with Conform)
    vim.api.nvim_create_autocmd('BufWritePre', {
        callback = function(args)
            local ok, conform = pcall(require, 'conform')
            if not ok then
                return
            end

            local bufnr = args.buf
            local filetype = vim.bo[bufnr].filetype
            if hc.fn.get_buffer_config(filetype).format_on_save then
                conform.format { bufnr = bufnr }
            end
        end,
    })
end

--- Installs missing tree-sitter parsers specified in the `treesitter` field in each editor buffer
--- config.
function M.install_treesitters()
    local hc = require 'hare-conf'
    local ok, parsers = pcall(require, 'nvim-treesitter.parsers')
    if not ok then
        vim.notify(
            'nvim-treesitter not installed; skipping treesitter installation (install_treesitters)',
            vim.log.levels.WARN,
            { title = 'HareConf' }
        )
        return
    end

    local buffer_configs = hc.fn.collect_buffer_configs()

    ---@type string[]
    local treesitter_names = {}
    for _, buffer_config in pairs(buffer_configs) do
        local treesitter_name = buffer_config.treesitter.name
        if treesitter_name ~= '' and not vim.tbl_contains(treesitter_names, treesitter_name) then
            table.insert(treesitter_names, treesitter_name)
        end
    end

    ---@type string[]
    local parsers_to_install = {}
    for _, name in ipairs(treesitter_names) do
        if not parsers.has_parser(name) then
            local parser_config = parsers.get_parser_configs()[name]
            if parser_config then
                table.insert(parsers_to_install, name)
            end
        end
    end

    -- Install missing tree-sitter parsers
    if #parsers_to_install > 0 then
        vim.cmd('TSInstall ' .. table.concat(parsers_to_install, ' '))
    end
end

--- Installs missing Mason tools specified in the following fields in each editor buffer config:
---   - lsp
---   - formatter
---   - linter
---   - debugger
---
--- This function relies on `mason-lspconfig` to map LSP names to Mason package names.
function M.install_mason_packages()
    local hc = require 'hare-conf'
    local ok_mappings, mappings = pcall(require, 'mason-lspconfig.mappings')
    if not ok_mappings then
        vim.notify(
            'mason-lspconfig not installed; skipping Mason package installation'
                .. ' (install_mason_packages)',
            vim.log.levels.WARN,
            { title = 'HareConf' }
        )
        return
    end

    local ok_mason_registry, mason_registry = pcall(require, 'mason-registry')
    if not ok_mason_registry then
        vim.notify(
            'mason not installed; skipping Mason package installation (install_mason_packages)',
            vim.log.levels.WARN,
            { title = 'HareConf' }
        )
        return
    end

    --- Adds the package name from the tool entry to the name list if enabled and not already
    --- present.
    --- @param name_list string[] List of Mason package names.
    --- @param tool_entry hare.editor.buffer.Lsp
    ---     | hare.editor.buffer.Formatter
    ---     | hare.editor.buffer.Linter
    ---     | hare.editor.buffer.Debugger
    ---     - HareConf tool entry.
    local add_package_name_to_list = function(name_list, tool_entry)
        if tool_entry.enabled then
            local tool_name = tool_entry.name
            if tool_name and not vim.tbl_contains(name_list, tool_name) then
                table.insert(name_list, tool_name)
            end
        end
    end

    local buffer_configs = hc.fn.collect_buffer_configs()

    ---@type string[]
    local package_names = {}
    for _, buffer_config in pairs(buffer_configs) do
        add_package_name_to_list(package_names, buffer_config.lsp)
        add_package_name_to_list(package_names, buffer_config.formatter)
        add_package_name_to_list(package_names, buffer_config.linter)
        add_package_name_to_list(package_names, buffer_config.debugger)
    end

    local lspconfig_to_package = mappings.get_mason_map().lspconfig_to_package
    local function resolve_mason_name(name)
        return name and lspconfig_to_package[name] or name
    end

    -- Resolve missing names of missing packages
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
        vim.notify(
            'Mason packages not found: ' .. table.concat(packages_not_found, ', '),
            vim.log.levels.WARN,
            {
                title = hc.NAME,
            }
        )
    end

    if #packages_to_install > 0 then
        vim.notify(
            'Installing mason packages: ' .. table.concat(packages_to_install, ', '),
            vim.log.levels.INFO,
            { title = hc.NAME }
        )
        for _, package_name in ipairs(packages_to_install) do
            local _package = mason_registry.get_package(package_name)
            _package:install()
        end
    end
end

--- Enables LSP servers specified in the `lsp` field in each editor buffer config.
function M.enable_lsp()
    local hc = require 'hare-conf'
    local buffer_configs = hc.fn.collect_buffer_configs()

    for _, buffer_config in pairs(buffer_configs) do
        if
            buffer_config.lsp.enabled
            and buffer_config.lsp.name
            and buffer_config.lsp.name ~= ''
        then
            vim.lsp.enable(buffer_config.lsp.name)
        end
    end
end

--- Sets up Conform with formatters specified in each editor buffer config.
---
--- This function requires Conform to be installed.
function M.set_up_conform()
    local hc = require 'hare-conf'

    local ok, conform = pcall(require, 'conform')
    if not ok then
        vim.notify(
            'Conform not installed; skipping Conform setup (set_up_conform)',
            vim.log.levels.WARN,
            { title = 'HareConf' }
        )
        return
    end

    ---@type table<string, string[]>
    local formatters_by_ft = {}
    for filetype, _ in pairs(hc.config.editor.filetype) do
        local buffer_config = hc.fn.get_buffer_config(filetype)
        if buffer_config.formatter.enabled then
            local formatter_name = buffer_config.formatter.name
            if formatter_name then
                formatters_by_ft[filetype] = { formatter_name }
            end
        end
    end

    conform.setup { formatters_by_ft = formatters_by_ft }
end

return M
