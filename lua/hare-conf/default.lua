---@type HareConf
return {
  system = {
    buffer = {
      exclude_types = {
        'nofile', -- help, quickfix, explorer UIs, etc.
        'terminal', -- terminal buffers
        'prompt', -- Telescope prompt
        'quickfix', -- quickfix/location list
        'help', -- :help buffers (yes, help is buftype)
      },
    },
    file = {
      exclude_types = {
        -- UI panels
        'neo-tree',
        'NvimTree',
        'lazy',
        'mason',
        'noice',
        'trouble',
        'dashboard',
        'alpha',
        'spectre_panel',

        -- Fuzzy finders / pickers
        'TelescopePrompt',
        'TelescopeResults',

        -- Terminals
        'toggleterm',
        'term',
        'terminal',
      },
    },
  },
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
        width = 2,
        display_width = 2,
        shift_width = 2,
      },
      color_column = {
        enabled = true,
        width = 80,
        highlight = nil,
      },
      format_on_save = true,
      treesitter = { name = '' },
      lsp = { enabled = true, name = '' },
      linter = { enabled = true, name = '' },
      formatter = { enabled = true, name = '' },
    },
    lang = {
      python = {
        tab = {
          width = 4,
          display_width = 4,
          shift_width = 4,
        },
        color_column = {
          width = 88,
        },
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
