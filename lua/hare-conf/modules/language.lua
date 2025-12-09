local M = {}

---@class hare.modules.language.Config
---@field filetypes string[] List of filetypes the configuration applies to
---@field buffer_config hare.editor.BufferInput Buffer-specific configurations.

-- Language configurations mapped by language name
---@type table<string, hare.modules.language.Config>
M.config = {}

-- List of enabled programming languages
---@type string[]
M.enabled_languages = {}

return M
