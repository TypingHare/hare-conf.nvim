local M = {}

-- The name of the plugin
M.NAME = 'HareConf'

-- The name of HareConf used in Neoconf as a key
M.NEOCONF_KEY_NAME = M.NAME

-- The command name for HareConf
M.COMMAND_NAME = 'Hareconf'

-- Hare configuration
--- @type hare.Config
--- @diagnostic disable-next-line: missing-fields
M.config = {}

--- Retrieves the current Neoconf user configuration safely.
---
--- @return table - The Neoconf configuration or an empty table if Neoconf is not loaded.
function M.get_config_from_neoconf()
    local user_config = {}
    local ok, neoconf = pcall(require, 'neoconf')

    if ok and neoconf and type(neoconf.get) == 'function' then
        user_config = neoconf.get(M.NEOCONF_KEY_NAME, {}) or {}
    else
        vim.notify(
            'Neoconf is not loaded. Skipping Neoconf configuration.',
            vim.log.levels.WARN,
            { title = M.NAME }
        )
    end

    return user_config
end

--- Merges new configuration to the Hare configuration.
---
--- @param new_config hare.ConfigInput | nil The new configuration to merge.
function M.update_config(new_config)
    if new_config ~= nil then
        M.config = vim.tbl_deep_extend('force', M.config, new_config)
    end
end

--- Gets the root path of the HareConf plugin.
---
--- @return string - The root path of the HareConf plugin.
function M.get_root_path()
    return require('lazy.core.config').plugins['hare-conf.nvim'].dir
end

--- Ensures that the required build files are present, and runs `make build` if any are missing.
function M.ensure_built()
    local root = M.get_root_path()
    local required_files = {
        'schemas/hare-conf.schema.json',
        'lua/hare-conf/types.lua',
        'lua/hare-conf/defaults.lua',
    }

    function M.missing_files(files)
        local missing = {}
        for _, rel in ipairs(files) do
            local full = root .. '/' .. rel
            if not vim.uv.fs_stat(full) then
                table.insert(missing, full)
            end
        end
        return missing
    end

    local missing = M.missing_files(required_files)
    if #missing == 0 then
        return
    end

    vim.notify('Running make build...', vim.log.levels.INFO, { title = M.NAME })
    local result = vim.system({ 'make', 'build' }, { cwd = root }):wait()
    if result.code == 0 then
        vim.notify(
            'Build completed.\nYou have to restart Neovim to enable HareConf.',
            vim.log.levels.INFO,
            { title = M.NAME }
        )
    else
        vim.notify(
            'Build FAILED:\n' .. (result.stderr or result.stdout),
            vim.log.levels.ERROR { title = M.NAME }
        )
    end
end

--- Sets up HareConf.
---
--- @param opts hare.ConfigInput | nil
function M.setup(opts)
    -- Ensure the required files are built
    M.ensure_built()

    -- Load the default Hare configuration
    M.config = require 'hare-conf.defaults'

    -- Update the Hare configuration with opts if provided
    if opts then
        M.update_config(opts)
    end

    -- HareConf allows user to set the config using Neoconf by merging the Neoconf config to the
    -- Hare configuration
    local config_from_neocof = M.get_config_from_neoconf()
    M.update_config(config_from_neocof)

    -- Load the fn module
    M.fn = require 'hare-conf.functions'

    -- Load the builtin module
    M.builtin = require 'hare-conf.builtin'

    -- Set up all commands
    require 'hare-conf.commands'
end

return M
