local M = {}

-- Required plugins
M.required_plugins = {
    neoconf = 'folke/neoconf.nvim',
    nui = 'MunifTanjim/nui.nvim',
}

-- Optional plugins
M.optional_plugins = {
    ['nvim-treesitter'] = 'nvim-treesitter/nvim-treesitter',
    mason = 'williamboman/mason.nvim',
    ['mason-lspconfig'] = 'williamboman/mason-lspconfig.nvim',
    ['mason-tool-installer'] = 'WhoIsSethDaniel/mason-tool-installer.nvim',
    ['conform'] = 'stevearc/conform.nvim',
}

--- Checks if a module has been loaded.
---
--- @param module_name string The module name to check.
--- @param full_name string The git repository name of the plugin.
--- @param optional boolean Whether the module is optional.
local function check_plugin(module_name, full_name, optional)
    local ok, _ = pcall(require, module_name)

    if ok then
        vim.health.ok(('%s is installed'):format(module_name))
    else
        local advice = string.format(
            'Install %s using lazy.nvim and ensure it\'s on your runtimepath.',
            full_name
        )
        if optional then
            vim.health.warn(('%s is not installed'):format(module_name), { advice })
        else
            vim.health.error(('%s is not installed'):format(module_name), { advice })
        end
    end
end

--- Main health check function.
function M.check()
    vim.health.start 'Required Dependencies'
    for name, full_name in pairs(M.required_plugins) do
        check_plugin(name, full_name, false)
    end

    vim.health.start 'Optional Dependencies'
    for name, full_name in pairs(M.optional_plugins) do
        check_plugin(name, full_name, true)
    end
end

return M
