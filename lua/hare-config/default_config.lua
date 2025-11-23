---@type HareConfig
return {
  appearance = {
    netrw = {
      enabled = false,
    },
    color_scheme = {
      mode = 'system',
      light_scheme = 'default',
      dark_scheme = 'default',
    },
  },
  editor = {
    appearance = {
      line_number = {
        enabled = true,
        relative = true,
        highlight = { fg = '#6c757d' },
        cursor_highlight = { fg = '#6f9ceb', bold = true },
      },
      sign_column = {
        enabled = true,
      },
      cursor = {
        highlight = { fg = 'NONE', bg = '#6f9ceb' },
      },
      color_column = {
        enabled = true,
        highlight = nil,
        disabled_filetypes = {
          'lazy',
          'mason',
          'help',
          'netrw',
          'neo-tree',
          'checkhealth',
          'lspinfo',
          'noice',
        },
      },
      cursor_insert = {
        highlight = { fg = 'NONE', bg = '#cccccc' },
      },
      cursor_line = {
        enabled = true,
        highlight = nil,
      },
      fill_chars = ' ',
    },
    general = {
      tab = {
        expand_with_spaces = true,
        width = 4,
        display_width = 4,
        shift_width = 4,
      },
    },
  },
  clipboard = {
    enabled = false,
    name = 'Hare Config Clipboard',
    host = '',
    enabled_cache = false,
    clipboard_option = 'unnamedplus',
  },
  terminal = {
    shell = '/bin/zsh',
  },
}
