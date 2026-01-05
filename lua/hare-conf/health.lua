local M = {}

---@class hare.commands.Plugin
---@field package string
---@field module string
---@field full string

--- Required plugins.
--- @type hare.commands.Plugin[]
M.required_plugins = {
    {
        package = 'neoconf',
        module = 'neoconf',
        full = 'folke/neoconf.nvim',
    },
    {
        package = 'nui',
        module = 'nui.popup',
        full = 'MunifTanjim/nui.nvim',
    },
}

--- Optional plugins.
--- @type hare.commands.Plugin[]
M.optional_plugins = {
    {
        package = 'nvim-treesitter',
        module = 'nvim-treesitter',
        full = 'nvim-treesitter/nvim-treesitter',
    },
    {
        package = 'mason',
        module = 'mason',
        full = 'williamboman/mason.nvim',
    },
    {
        package = 'mason-lspconfig',
        module = 'mason-lspconfig',
        full = 'williamboman/mason-lspconfig.nvim',
    },
    {
        package = 'mason-tool-installer',
        module = 'mason-tool-installer',
        full = 'WhoIsSethDaniel/mason-tool-installer.nvim',
    },
    {
        package = 'conform',
        module = 'conform',
        full = 'stevearc/conform.nvim',
    },
}

--- Checks if a module has been loaded.
---
--- @param package_name string - The name ofthe package.
--- @param module_name string - The module name to check.
--- @param full_name string - The git repository name of the plugin.
--- @param optional boolean - Whether the module is optional.
local function check_plugin(package_name, module_name, full_name, optional)
    local ok, _ = pcall(require, module_name)

    if ok then
        vim.health.ok(('%s is installed'):format(package_name))
    else
        local advice = string.format(
            'Install [%s] using lazy.nvim and ensure it\'s on your runtimepath.',
            full_name
        )
        local logger = optional and vim.health.warn or vim.health.error
        logger(('%s is not installed'):format(package_name), { advice })
    end
end

--- Main health check function.
function M.check()
    vim.health.start 'Required Dependencies'
    for _, plugin in ipairs(M.required_plugins) do
        check_plugin(plugin.package, plugin.module, plugin.full, false)
    end

    vim.health.start 'Optional Dependencies'
    for _, plugin in ipairs(M.optional_plugins) do
        check_plugin(plugin.package, plugin.module, plugin.full, true)
    end
end

return M
