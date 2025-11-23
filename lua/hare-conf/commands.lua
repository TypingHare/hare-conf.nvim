local M = require 'hare-conf'

--- Displays the current configuration in a popup window.
---
--- @param config_string string The configuration string to display.
--- @param title string The title of the popup window.
local show_config_string = function(config_string, title)
  local markdown_text = '```lua\n' .. config_string .. '\n```'
  local lines = vim.split(markdown_text, '\n', { plain = true })

  -- create popup
  local Popup = require 'nui.popup'
  local popup = Popup {
    enter = true,
    focusable = true,
    relative = 'editor',
    position = '50%',
    border = {
      style = 'rounded',
      text = {
        top = title,
        top_align = 'center',
      },
    },
    size = {
      width = math.floor(vim.o.columns * 0.7),
      height = math.floor(vim.o.lines * 0.7),
    },
  }

  -- mount it
  popup:mount()

  vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, lines)
  vim.api.nvim_set_option_value('filetype', 'markdown', { buf = popup.bufnr })
  vim.api.nvim_set_option_value('buftype', 'nofile', { buf = popup.bufnr })
  vim.api.nvim_set_option_value('conceallevel', 2, { win = popup.winid })

  -- Close with q or <Esc>
  local opts = { noremap = true, silent = true, buffer = popup.bufnr }
  local quit_callback = function()
    popup:unmount()
  end

  vim.keymap.set('n', 'q', quit_callback, opts)
  vim.keymap.set('n', '<Esc>', quit_callback, opts)
end

--- Shows the current configuration in a popup window.
local show_config = function()
  show_config_string(vim.inspect(M.config), 'Hare Configuration')
end

--- Shows the language-specific configuration in a popup window.
---
--- @param filetype string The filetype to show configuration for.
local show_lang_config = function(filetype)
  local lang_config = M.fn.editor.get_lang_config(filetype)
  show_config_string(
    vim.inspect(lang_config),
    filetype and 'Hare Langugage Configuration (' .. filetype .. ')'
      or 'Hare Language Configuration'
  )
end

vim.api.nvim_create_user_command(M.NAME, function(opts)
  if #opts.args > 0 then
    local subcommand = opts.args
    if subcommand == 'show' then
      show_config()
    elseif subcommand == 'lang' then
      show_lang_config(vim.bo.filetype)
    end
  end
end, {
  nargs = '*',
  desc = M.NAME,
})
