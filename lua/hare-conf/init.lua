local M = {}

--- The name of this plugin.
M.NAME = 'HareConf'

--- The package name of this plugin (used by lazy.nvim).
M.PACKAGE_NAME = 'hare-conf.nvim'

--- The key name used in Neoconf. The value (table) associated with this key will be merged to
--- the configuration of HareConf.
M.NEOCONF_KEY_NAME = M.NAME

--- The Neovim command name.
M.COMMAND_NAME = 'Hareconf'

--- Hare configuration.
--- @type hare.Config
--- @diagnostic disable-next-line: missing-fields
M.config = {}

--- Whether HareConf's setup is completed.
--- @type boolean
M.setup_completed = false

--- Logs an info message with the plugin name as the title.
---
--- @param message string - The warning message to log.
function M.info(message)
    vim.notify(message, vim.log.levels.INFO, { title = M.NAME })
end

--- Logs an warning message with the plugin name as the title.
---
--- @param message string - The warning message to log.
function M.warn(message)
    vim.notify(message, vim.log.levels.WARN, { title = M.NAME })
end

--- Logs an error message with the plugin name as the title.
---
--- @param message string - The error message to log.
function M.error(message)
    vim.notify(message, vim.log.levels.ERROR, { title = M.NAME })
end

--- Retrieves the Hare configuration from Neoconf.
---
--- This function checks if Neoconf is loaded and retrieves the configuration. If Neoconf is not
--- loaded, it logs a warning and returns an empty table. Otherwise, it returns the configuration
--- associated with the [NEOCONF_KEY_NAME].
---
--- @return table - The Neoconf configuration or an empty table if Neoconf is not loaded.
function M.get_config_from_neoconf()
    local ok, neoconf = pcall(require, 'neoconf')
    if not ok or type(neoconf.get) ~= 'function' then
        M.warn 'Neoconf is not loaded. Skipping Neoconf configuration.'
        return {}
    end

    return neoconf.get(M.NEOCONF_KEY_NAME, {}) or {}
end

--- Merges new configuration to the Hare configuration.
---
--- This function deeply extends the existing configuration with the provided new configuration. If
--- the new configuration is nil, no changes are made.
---
--- @param new_config hare.ConfigInput | nil - The new configuration to merge.
function M.update_config(new_config)
    if new_config ~= nil and type(new_config) == 'table' then
        M.config = vim.tbl_deep_extend('force', M.config, new_config)
    end
end

--- Gets the root path of the HareConf plugin.
---
--- @return string - The root path of the HareConf plugin.
function M.get_root_path()
    return require('lazy.core.config').plugins[M.PACKAGE_NAME].dir
end

--- Ensures that the required build files are present.
---
--- This function runs `make build` if any required build files are missing.
function M.ensure_built()
    local root = M.get_root_path()
    local required_files = {
        'schemas/hare-conf.schema.json',
        'lua/hare-conf/types.lua',
        'lua/hare-conf/defaults.lua',
    }

    for _, relative_path in ipairs(required_files) do
        local full_path = root .. '/' .. relative_path
        if not vim.uv.fs_stat(full_path) then
            M.run_make_build()
            return
        end
    end
end

--- Runs the `make build` command in the plugin's root directory.
---
--- This function executes the `make build` command and logs the result. If the build is
--- successful, it notifies the user that a restart of Neovim is required to enable HareConf. If
--- the build fails, it logs a warning with the error message.
function M.run_make_build()
    M.info 'Running make build...'

    local result = vim.system({ 'make', 'build' }, { cwd = M.get_root_path() }):wait()
    if result.code == 0 then
        M.info 'Build completed.\nYou have to restart Neovim to enable HareConf.'
    else
        M.error('Build failed:\n' .. (result.stderr or result.stdout))
    end
end

--- Sets up HareConf.
---
--- @param opts hare.ConfigInput | nil - Optional configuration to override the defaults.
function M.setup(opts)
    -- Ensure the required files are built.
    M.ensure_built()

    -- Load the default Hare configuration.
    M.config = require 'hare-conf.defaults'

    -- Update the Hare configuration with opts if provided.
    if opts then
        M.update_config(opts)
    end

    -- HareConf allows users to set the configuration using Neoconf.
    local config_from_neocof = M.get_config_from_neoconf()
    M.update_config(config_from_neocof)

    -- Load the fn module.
    M.fn = require 'hare-conf.functions'

    -- Load the builtin module.
    M.builtin = require 'hare-conf.builtin'

    -- Set up all commands.
    require 'hare-conf.commands'

    -- Mark setup_completed as true.
    M.setup_completed = true
end

return M
