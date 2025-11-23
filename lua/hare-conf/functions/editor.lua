local M = {}

---@type HareConf
local config = require('hare-conf').config

--- Gets editor configuration with defaults.
---
--- TODO: cache
---
--- @param filetype string|nil The filetype to get configuration for.
--- @return HareConfEditorLang
M.get_lang_config = function(filetype)
  --- @type HareConfEditorLang
  local lang_config = config.editor.general

  if filetype and config.editor.lang[filetype] then
    --- @type HareConfEditorLang|nil
    local specific_lang_config = config.editor.lang[filetype]
    if specific_lang_config ~= nil then
      lang_config =
        vim.tbl_deep_extend('force', lang_config, specific_lang_config)
    end
  end

  return lang_config
end

--- Sets editor configuration for a specific language.
---
--- @param lang string The language to set configuration for.
--- @param lang_config HareConfEditorLang The configuration to set.
M.set_lang_config = function(lang, lang_config)
  local specific_lang_config = config.editor.lang[lang]
  if specific_lang_config ~= nil then
    lang_config =
      vim.tbl_deep_extend('force', specific_lang_config, lang_config)
  end

  config.editor.lang[lang] = lang_config
end

return M
