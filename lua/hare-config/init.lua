local M = {}

-- Constants
M.NEOCONF_KEY = 'HareConfig'

-- Default Hare configuration
M.default = require 'hare-config.config.default'

-- Final Hare configuration
M.config = M.default

--- Retrieves the current Neoconf user configuration safely.
---
--- @return table user_config The Neoconf configuration or an empty table if
---   Neoconf is not loaded.
M.get_neoconf_config = function()
  local user_config = {}
  local ok, neoconf = pcall(require, 'neoconf')

  if ok and neoconf and type(neoconf.get) == 'function' then
    user_config = neoconf.get('', {}) or {}
  end

  return user_config
end

---Updates hare configuration.
---
---@param new_config table
M.update_config = function(new_config)
  M.config = vim.tbl_deep_extend('force', M.config, new_config)
end

--- Applies UI settings.
---
--- @param ui_settings HareConfigUI
M.apply_ui_settings = function(ui_settings)
  if ui_settings.disable_netrw then
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end
end

--- Applies editor settings.
---
--- @param editor_settings HareConfigEditor
M.apply_editor_settings = function(editor_settings)
  vim.opt.expandtab = editor_settings.tab.expand_with_spaces
  vim.opt.number = editor_settings.line_number.show
  vim.opt.relativenumber = editor_settings.line_number.relative
  vim.opt.softtabstop = editor_settings.tab.width
  vim.opt.tabstop = editor_settings.tab.display_width
  vim.opt.shiftwidth = editor_settings.tab.shift_width
  vim.opt.signcolumn = editor_settings.sign_column.show and 'yes' or 'no'
  vim.opt.fillchars:append { eob = editor_settings.fill_chars }
  vim.opt.cursorline = editor_settings.cursor_line_highlight
end

--- Applies keymap settings.
--- @param keymap_settings HareConfigKeymap
M.apply_keymap_settings = function(keymap_settings) end

--- Applies clipboard settings.
---
--- @param clipboard_settings HareConfigClipbopard
M.apply_clipboard_settings = function(clipboard_settings)
  local host = clipboard_settings.host
  if host == '' then
    vim.notify(
      'Stop setting Hare Config clipboard: clipboard.host is empty.',
      vim.log.levels.WARN
    )
  else
    local copy_url = 'curl -s X POST ' .. host .. ' -d @-'
    local paste_url = 'curl -s ' .. host
    vim.g.clipboard = {
      name = clipboard_settings.name,
      copy = { ['+'] = copy_url, ['*'] = copy_url },
      paste = { ['+'] = paste_url, ['*'] = paste_url },
      cache_enabled = clipboard_settings.enabled_cache and 1 or 0,
    }

    vim.opt.clipboard = clipboard_settings.clipboard_option
  end
end

--- Applies all settings.
---
--- @param settings HareConfig
M.apply_all_settings = function(settings)
  M.apply_ui_settings(settings.ui)
  M.apply_editor_settings(settings.editor)
  M.apply_keymap_settings(settings.keymap)
  M.apply_clipboard_settings(settings.clipboard)
end

--- Sets up Hare configuration by applying all settings.
---
--- @param opts HareConfig
M.setup = function(opts)
  local neoconf_config = M.get_neoconf_config()
  M.update_config(opts)
  M.update_config(neoconf_config[M.NEOCONF_KEY])
  M.apply_all_settings(M.config)

  require 'hare-config.commands'
end

return M
