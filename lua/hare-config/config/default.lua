---@type HareConfig
return {
  ui = {
    disable_netrw = false,
    color_scheme = 'default',
  },
  editor = {
    tab = {
      expand_with_spaces = true,
      width = 2,
      display_width = 2,
      shift_width = 2,
    },
    line_number = { show = true, relative = true },
    sign_column = { show = true },
    fill_chars = ' ',
    cursor_line_highlight = true,
    color_column = {
      enabled = true,
      disabled_filetypes = {
        'lazy',
        'mason',
        'help',
        'netrw',
        'neo-tree',
        'checkhealth',
        'lspinfo',
        'noice',
        'Trouble',
      },
    },
  },
  keymap = {},
  clipboard = {
    enabled = false,
    name = 'Hare Config',
    host = '',
    enabled_cache = false,
    clipboard_option = 'unnamedplus',
  },
}
