local M = {}

-- Constants
M.NAME = 'HareConf'

-- Default Hare configuration
M.default = require 'hare-conf.default'

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

--- Merges new configuration to the Hare configuration.
---
--- @param new_config table | nil The new configuration to merge.
M.update_config = function(new_config)
  if new_config ~= nil then
    M.config = vim.tbl_deep_extend('force', M.config, new_config)
  end
end

--- Applies appearance settings.
---
--- @param settings HareConfAppearance
M.apply_appearance_settings = function(settings)
  if not settings.netrw.enabled then
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end

  local color_scheme_mode = settings.color_scheme.mode
  if color_scheme_mode == 'dark' then
    vim.cmd.colorscheme(settings.color_scheme.dark_scheme)
  elseif color_scheme_mode == 'light' then
    vim.cmd.colorscheme(settings.color_scheme.light_scheme)
  elseif color_scheme_mode == 'system' then
    -- TODO: How to implement?
    vim.cmd.colorscheme(settings.color_scheme.light_scheme)
  end
end

--- Applies editor settings.
---
--- @param settings HareConfEditor
M.apply_editor_settings = function(settings)
  M.apply_editor_appearance_settings(settings.appearance)
  M.apply_editor_general_settings(settings.general)
end

--- Applies editor appearance settings.
---
--- @param settings HareConfEditorAppearance
M.apply_editor_appearance_settings = function(settings)
  -- line_number
  vim.opt.number = settings.line_number.enabled
  vim.opt.relativenumber = settings.line_number.relative
  local line_number_highlight = settings.line_number.highlight
  if line_number_highlight ~= nil then
    vim.api.nvim_set_hl(0, 'LineNr', line_number_highlight)
  end
  local line_number_cursor_highlight = settings.line_number.cursor_highlight
  if line_number_cursor_highlight ~= nil then
    vim.api.nvim_set_hl(0, 'CursorLineNr', line_number_cursor_highlight)
  end

  -- sign_column
  vim.opt.signcolumn = settings.sign_column.enabled and 'yes' or 'no'

  -- fill_chars
  vim.opt.fillchars:append { eob = settings.fill_chars }

  -- cursor & cursor_insert
  vim.opt.guicursor = {
    'n-v-c:block-Cursor',
    'i:ver25-CursorInsert',
    'r-cr:hor20',
    'o:hor50',
    --'a:blinkwait500-blinkon600-blinkoff400'
  }

  if settings.cursor.highlight ~= nil then
    vim.api.nvim_set_hl(0, 'Cursor', settings.cursor.highlight)
  end
  if settings.cursor_insert.highlight ~= nil then
    vim.api.nvim_set_hl(0, 'CursorInsert', settings.cursor_insert.highlight)
  end

  -- cursor_line
  vim.opt.cursorline = settings.cursor_line.enabled
  if settings.cursor_line.highlight then
    vim.api.nvim_set_hl(0, 'CursorLine', settings.cursor_line.highlight)
  end
end

--- Applies editor general settings.
---
--- @param settings HareConfEditorLang
M.apply_editor_general_settings = function(settings)
  -- tab
  vim.opt.expandtab = settings.tab.expand_with_spaces
  vim.opt.softtabstop = settings.tab.width
  vim.opt.tabstop = settings.tab.display_width
  vim.opt.shiftwidth = settings.tab.shift_width
end

--- Applies clipboard settings.
---
--- @param settings HareConfClipbopard
M.apply_clipboard_settings = function(settings)
  if settings.enabled then
    local host = settings.host
    if host == '' then
      vim.notify(
        'Stop setting Hare Config clipboard: clipboard.host is empty.',
        vim.log.levels.WARN
      )
    else
      local copy_url = 'curl -s X POST ' .. host .. ' -d @-'
      local paste_url = 'curl -s ' .. host
      vim.g.clipboard = {
        name = settings.name,
        copy = { ['+'] = copy_url, ['*'] = copy_url },
        paste = { ['+'] = paste_url, ['*'] = paste_url },
        cache_enabled = settings.enabled_cache and 1 or 0,
      }
    end
  end

  vim.opt.clipboard = settings.clipboard_option
end

--- Applies terminal settings.
---
--- @param settings HareConfTerminal
M.apply_terminal_settings = function(settings)
  vim.opt.shell = settings.shell
end

--- Applies all settings.
---
--- @param settings HareConf
M.apply_all_settings = function(settings)
  M.apply_appearance_settings(settings.appearance)
  M.apply_editor_settings(settings.editor)
  M.apply_clipboard_settings(settings.clipboard)
  M.apply_terminal_settings(settings.terminal)
end

--- Sets up Hare configuration by applying all settings.
---
--- @param opts HareConf
M.setup = function(opts)
  local neoconf_config = M.get_neoconf_config()
  M.update_config(opts)
  M.update_config(neoconf_config[M.NAME])
  M.apply_all_settings(M.config)

  -- Set up all commands
  require 'hare-conf.commands'

  -- Load the fn module
  M.fn = require 'hare-conf.functions'
end

return M
