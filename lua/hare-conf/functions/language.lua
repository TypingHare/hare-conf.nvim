local M = {}

--- HareConf main module.
local hare = require 'hare-conf'

--- HareConf language module.
local language_module = require 'hare-conf.modules.language'

--- Gets all supported programming languages.
---
--- @return string[] - A list of all supported programming languages.
function M.get_supported_languages()
    return vim.tbl_keys(language_module.config)
end

--- Sets the configuration for programming languages by merging the provided configuration with
--- the existing one.
---
--- @param language_config table<string, hare.modules.language.Config> - The configuration table for
---     programming languages.
function M.set_language_config(language_config)
    language_module.config = vim.tbl_deep_extend('force', language_module.config, language_config)
end

--- Gets all enabled programming languages.
---
--- @return string[] - A list of all enabled programming languages.
function M.get_enabled_languages()
    return language_module.enabled_languages
end

--- Enables the configuration for a specific programming language. If the language is not found in
--- the configuration, a warning will be logged.
---
---@param language_name string - The name of the programming language to enable.
function M.enable_language(language_name)
    local language = language_module.config[language_name]
    if not language then
        hare.warn('Language is not supported: ' .. language_name)
        return
    end

    hare.fn.set_buffer_config(language.filetypes, language.buffer_config)

    -- Mark language as enabled
    table.insert(language_module.enabled_languages, language_name)
end

--- Enables all programming languages specified in the Hare configuration.
function M.enable_languages_in_config()
    local languages = hare.config.language.names or {}
    for _, language_name in ipairs(languages) do
        M.enable_language(language_name)
    end
end

return M
