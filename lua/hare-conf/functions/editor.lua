local M = {}

---@type table<string, HareConfEditorLang>
M._lang_config_cache = {}

---@type HareConf
local config = require('hare-conf').config

--- Gets editor configuration with defaults.
---
--- Merges `config.editor.general` with `config.editor.lang[lang_name]` (if
--- any) without mutating the defaults. Result for a given lang is cached.
---
--- @param lang_name? string The language name to get configuration for.
--- @return HareConfEditorLang
function M.get_lang_config(lang_name)
  if lang_name and M._lang_config_cache[lang_name] ~= nil then
    return M._lang_config_cache[lang_name]
  end

  -- Start from a copy of the general defaults so we don't accidentally mutate
  -- them
  ---@type HareConfEditorLang
  local lang_config = vim.deepcopy(config.editor.general)

  if lang_name then
    local specific_lang_config = config.editor.lang[lang_name]
    if specific_lang_config ~= nil then
      lang_config =
        vim.tbl_deep_extend('force', lang_config, specific_lang_config)
    end

    -- cache per-language result
    M._lang_config_cache[lang_name] = lang_config
  end

  return lang_config
end

--- Sets editor configuration for one or more languages.
---
--- This *extends* any existing per-language config with `lang_config`.
---
--- @param lang_names string[] The language names to set configuration for.
--- @param lang_config HareConfEditorLang The configuration to set/merge in.
function M.set_lang_config(lang_names, lang_config)
  for _, lang_name in ipairs(lang_names) do
    local existing = config.editor.lang[lang_name] or {}

    -- Create a fresh table so multiple languages don't share the same reference
    local merged = vim.tbl_deep_extend('force', {}, existing, lang_config)

    config.editor.lang[lang_name] = merged

    -- Invalidate cache so next get_lang_config(lang_name) recomputes correctly
    M._lang_config_cache[lang_name] = nil
  end
end

--- Clears all cached language configs.
function M.clear_cache()
  M._lang_config_cache = {}
end

return M
