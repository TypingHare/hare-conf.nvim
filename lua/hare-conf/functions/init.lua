local M = {}

local buffer_functions = require 'hare-conf.functions.buffer'
M.get_buffer_config_of_filetype = buffer_functions.get_buffer_config_of_filetype
M.get_buffer_config = buffer_functions.get_buffer_config
M.set_buffer_config = buffer_functions.set_buffer_config
M.set_buffer_config_aliases = buffer_functions.set_buffer_config_aliases
M.clear_buffer_config_cache = buffer_functions.clear_buffer_config_cache
M.collect_buffer_configs = buffer_functions.collect_buffer_configs

local language_functions = require 'hare-conf.functions.language'
M.get_supported_languages = language_functions.get_supported_languages
M.set_language_config = language_functions.set_language_config
M.get_enabled_languages = language_functions.get_enabled_languages
M.enable_language = language_functions.enable_language
M.enable_languages_in_config = language_functions.enable_languages_in_config

--- Sets a highlight group.
---
--- @param group_name string The name of the highlight group.
--- @param group table|nil The highlight group definition. If nil, no action is taken.
function M.set_highlight(group_name, group)
    if group then
        vim.api.nvim_set_hl(0, group_name, group)
    end
end

--- Gets the path to the JSON schema for hare-conf.nvim.
---
--- @return string - The path to the JSON schema file.
function M.get_json_schema_path()
    return require('lazy.core.config').plugins['hare-conf.nvim'].dir
        .. '/schemas/hare-conf.schema.json'
end

--- Gets the JSON schema definition for hare-conf.nvim.
---
--- @return table - The JSON schema definition.
function M.get_json_schema()
    return {
        description = 'HareConf configuration schema for Neoconf files.',
        fileMatch = { 'neoconf.json', 'neoconf.example.json' },
        url = M.get_json_schema_path(),
    }
end

return M
