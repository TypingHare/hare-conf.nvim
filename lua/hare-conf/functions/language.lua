local M = {}

--- Gets all supported programming languages.
---
--- @return string[] - A list of all supported programming languages.
function M.get_supported_languages()
    return vim.tbl_keys(require('hare-conf.builtin.language').config)
end

--- Gets all enabled programming languages.
---
--- @return string[] - A list of all enabled programming languages.
function M.get_enabled_languages()
    return require('hare-conf.builtin.language').enabled_languages
end

return M
