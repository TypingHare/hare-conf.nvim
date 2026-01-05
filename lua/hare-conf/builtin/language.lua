local M = {}

local hare = require 'hare-conf'

--- Builtin language configurations for various programming languages.
--- @type table<string, hare.modules.language.Config>
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
    cmake = {
        filetypes = { 'cmake' },
        buffer_config = {
            treesitter = { name = 'cmake' },
            lsp = { name = 'cmake' },
            linter = { name = 'cmakelint' },
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
            formatter = {
                packages = {
                    { package_name = 'mbake', executable = 'bake' },
                },
            },
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
            lsp = { name = 'systemd_lsp' },
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
    kotlin = {
        filetypes = { 'kotlin', 'kt', 'kts' },
        buffer_config = {
            treesitter = { name = 'kotlin' },
            lsp = { name = 'kotlin_language_server' },
            linter = { name = 'ktlint' },
            formatter = { name = 'ktlint' },
            ruler = { columns = { 100 } },
        },
    },
    go = {
        filetypes = { 'go' },
        buffer_config = {
            treesitter = { name = 'go' },
            lsp = { name = 'gopls' },
            linter = { name = 'golangci-lint' },
            formatter = { name = 'gofumpt' },
            ruler = { columns = { 100 } },
        },
    },
}

--- Sets up builtin language configuration.
function M.setup()
    hare.fn.set_language_config(M.config)
end

--- Uses builtin language configuration.
function M.use_builtin_language_config()
    hare.fn.set_language_config(M.config)
end

return M
