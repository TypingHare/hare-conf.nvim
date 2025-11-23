local M = require 'hare-conf'

local show_config = function()
  local config_string = vim.inspect(M.config)
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
        top = 'Hare Config',
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

  -- close with q or <Esc>
  local opts = { noremap = true, silent = true, buffer = popup.bufnr }
  vim.keymap.set('n', 'q', function()
    popup:unmount()
  end, opts)

  vim.keymap.set('n', '<Esc>', function()
    popup:unmount()
  end, opts)
end

vim.api.nvim_create_user_command(M.NAME, function(opts)
  if #opts.args > 0 then
    local subcommand = opts.args
    if subcommand == 'show' then
      show_config()
    end
  end
end, {
  nargs = '*',
  desc = 'Hare Config',
})
