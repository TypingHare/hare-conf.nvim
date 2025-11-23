local M = {}

---@type HareConf
local config = require('hare-conf').config

--- Gets editor configuration with defaults.
---
--- TODO: cache
---
--- @param buftype string|nil
--- @return HareConfEditorLang
M.get_editor_config = function(buftype)
  --- @type HareConfEditorLang
  local editor_lang_config = config.editor.general

  if buftype and config.editor.lang[buftype] then
    --- @type HareConfEditorLang|nil
    local lang_config = config.editor.lang[buftype]
    editor_lang_config = vim.tbl_deep_extend('force', M.config, lang_config)
  end

  return editor_lang_config
end

return M
