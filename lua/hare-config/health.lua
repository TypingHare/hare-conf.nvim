local M = {}

local health = vim.health

--- Checks if a module loads.
---
--- @param module_name string The module name to check.
--- @param full_name string The git repository name of the plugin.
--- @param optional boolean Whether the module is optional.
local function check_plugin(module_name, full_name, optional)
  local ok, _ = pcall(require, module_name)

  if ok then
    health.ok(('%s is installed'):format(module_name))
  else
    local advice = string.format(
      'Install %s using lazy.nvim and ensure it\'s on your runtimepath.',
      full_name
    )
    if optional then
      health.warn(('%s is not installed'):format(module_name), { advice })
    else
      health.error(('%s is not installed'):format(module_name), { advice })
    end
  end
end

function M.check()
  health.start 'Required Dependencies'
  check_plugin('neoconf', 'folke/neoconf.nvim', true)
  check_plugin('mason', 'williamboman/mason.nvim', true)
  check_plugin('mason-lspconfig', 'williamboman/mason-lspconfig.nvim', true)
  check_plugin('bufferline', 'akinsho/bufferline.nvim', true)
  check_plugin('blink.cmp', 'saghen/blink.cmp', true)

  health.start 'Optional Dependencies'
  check_plugin('smartcolumn', 'm4xshen/smartcolumn.nvim', false)
end

return M
