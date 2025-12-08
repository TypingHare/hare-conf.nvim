local M = {}

---@class hare.builtin.language.Config
---@field filetypes string[] List of filetypes the configuration applies to
---@field buffer_config hare.editor.BufferInput Buffer-specific configurations.

-- Language configurations mapped by language name
---@type table<string, hare.builtin.language.Config>
M.config = {
    lua = {
        filetypes = { 'lua' },
        buffer_config = {
            treesitter = { name = 'lua' },
            lsp = { name = 'lua_ls' },
            formatter = { name = 'stylua' },
            ruler = { columns = { 100 } },
        },
    },
    json = {
        filetypes = { 'json', 'jsonc' },
        buffer_config = {
            treesitter = { name = 'json' },
            lsp = { name = 'jsonls' },
            formatter = { name = 'prettier' },
            indent = { width = 2 },
            ruler = { enabled = false },
        },
    },
    toml = {
        filetypes = { 'toml' },
        buffer_config = {
            treesitter = { name = 'toml' },
            lsp = { name = 'taplo' },
            formatter = { name = 'taplo' },
            ruler = { enabled = false },
        },
    },
    javascript = {
        filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
        buffer_config = {
            lsp = { name = 'ts_ls' },
            formatter = { name = 'prettier' },
            linter = { name = 'eslint-lsp' },
            indent = { width = 2 },
            ruler = { columns = { 100 } },
        },
    },
    bash = {
        filetypes = { 'sh', 'zsh' },
        buffer_config = {
            treesitter = { name = 'bash' },
            lsp = { name = 'bashls' },
            linter = { name = 'shellcheck' },
            formatter = { name = 'shfmt' },
            ruler = { columns = { 80 } },
        },
    },
    latex = {
        filetypes = { 'tex', 'bib' },
        buffer_config = {
            treesitter = { name = 'bibtex', highlight_enabled = false },
            lsp = { name = 'texlab' },
            formatter = { name = 'latexindent' },
            ruler = { enabled = false },
        },
    },
    camke = {
        filetypes = { 'cmake' },
        buffer_config = {
            treesitter = { name = 'cmake' },
            formatter = { name = 'cmakelint' },
            lsp = { name = 'cmake' },
            ruler = { columns = { 80 } },
        },
    },
    cpp = {
        filetypes = { 'c', 'cpp', 'h', 'hpp' },
        buffer_config = {
            treesitter = { name = 'cpp' },
            formatter = { name = 'clang-format' },
            lsp = { name = 'clangd' },
            ruler = { columns = { 80 } },
        },
    },
    css = {
        filetypes = { 'css', 'scss', 'less' },
        buffer_config = {
            treesitter = { name = 'css' },
            lsp = { name = 'cssls' },
            formatter = { name = 'prettier' },
            indent = { width = 2 },
        },
    },
    html = {
        filetypes = { 'html' },
        buffer_config = {
            treesitter = { name = 'html' },
            lsp = { name = 'html' },
            formatter = { name = 'prettier' },
            indent = { width = 2 },
        },
    },
    java = {
        filetypes = { 'java' },
        buffer_config = {
            treesitter = { name = 'java' },
            lsp = { name = 'jdtls' },
            formatter = { name = 'google-java-format' },
        },
    },
    just = {
        filetypes = { 'just' },
        buffer_config = {
            treesitter = { name = 'just' },
            lsp = { name = 'just' },
            formatter = { name = 'prettier' },
        },
    },
    make = {
        filetypes = { 'make' },
        buffer_config = {
            treesitter = { name = 'make' },
            lsp = { name = 'mbake' },
            linter = { name = 'checkmake' },
            --formatter = { name = 'mbake' },
            indent = { type = 'tabs', display_width = 4 },
            ruler = { columns = { 80 } },
        },
    },
    markdown = {
        filetypes = { 'markdown' },
        buffer_config = {
            treesitter = { name = 'markdown' },
            lsp = { name = 'marksman' },
            formatter = { name = 'prettier' },
            linter = { name = 'markdownlint' },
            ruler = { enabled = false },
        },
    },
    python = {
        filetypes = { 'python' },
        buffer_config = {
            treesitter = { name = 'python' },
            lsp = { name = 'pyright' },
            formatter = { enabled = false },
            ruler = { columns = { 88 } },
        },
    },
    rust = {
        filetypes = { 'rust' },
        buffer_config = {
            treesitter = { name = 'rust' },
            lsp = { name = 'rust-analyzer' },
            formatter = { name = 'rustfmt' },
            linter = { name = 'bacon' },
        },
    },
    sql = {
        filetypes = { 'sql' },
        buffer_config = {
            treesitter = { name = 'sql' },
            lsp = { name = 'sqls' },
            formatter = { name = 'sqruff' },
        },
    },
    svelte = {
        filetypes = { 'svelte' },
        buffer_config = {
            treesitter = { name = 'svelte' },
            lsp = { name = 'svelte' },
            formatter = { name = 'prettier' },
            indent = { width = 2 },
        },
    },
    systemd = {
        filetypes = { 'systemd' },
        buffer_config = {
            lsp = { name = 'systemd_ls' },
            linter = { name = 'systemdlint' },
            tab = { width = 8 },
            ruler = { enabled = false },
        },
    },
    typos = {
        filetypes = { '*typos' },
        buffer_config = {
            lsp = { name = 'typos_lsp' },
        },
    },
    yaml = {
        filetypes = { 'yaml' },
        buffer_config = {
            treesitter = { name = 'yaml' },
            lsp = { name = 'yamlls' },
            formatter = { name = 'prettier' },
            linter = { name = 'yamllint' },
            ruler = { enabled = false },
        },
    },
}

-- List of enabled programming languages
---@type string[]
M.enabled_languages = {}

--- Enables the configuration for a specific programming language. If the language is not found in
--- the configuration, a warning is logged.
---
---@param language_name string The name of the programming language to enable.
function M.enable_language(language_name)
    local hc = require 'hare-conf'

    local language = M.config[language_name]
    if not language then
        vim.notify(
            string.format('Language configuration for "%s" not found.', language_name),
            vim.log.levels.WARN
        )
        return
    end

    local filetypes = language.filetypes
    local buffer_config = language.buffer_config
    hc.fn.set_buffer_config(filetypes, buffer_config)

    -- Mark language as enabled
    table.insert(M.enabled_languages, language_name)
end

--- Enables all programming languages specified in the Hare configuration.
function M.enable_languages_in_config()
    local hc = require 'hare-conf'

    local languages = hc.config.language.names or {}
    for _, language_name in ipairs(languages) do
        M.enable_language(language_name)
    end
end

return M
