# hare-conf.nvim

**hare-conf.nvim** is a structured, schema-driven configuration framework for Neovim.
It provides a single source of truth for editor behavior, appearance, language tooling,
and per-filetype customization — with strong typing, defaults, and JSON schema support.

This plugin is designed to be used standalone or as a foundation for larger Neovim
distributions (such as HareVim).

## ✨ Features

- Centralized configuration for editor, appearance, language, clipboard, and terminal
- Strongly typed Lua configuration (auto-generated EmmyLua annotations)
- JSON Schema generation for `neoconf.nvim`
- Per-filetype buffer configuration with inheritance and aliases
- Built-in language presets (Lua, JS/TS, Python, Rust, Go, etc.)
- Safe lazy-loading with optional dependency guards
- Declarative LSP, formatter, linter, and debugger setup via Mason

## 📦 Installation

Using **lazy.nvim**:

```lua
{
  'TypingHare/hare-conf.nvim',
  dependencies = {
    'folke/neoconf.nvim',
    'MunifTanjim/nui.nvim',
  },
  config = function()
    require('hare-conf').setup()
  end,
}
```

On first launch, HareConf automatically builds required generated files.
Restart Neovim after the initial build.

## ⚙️ Basic Configuration

```lua
require('hare-conf').setup {
  appearance = {
    theme = {
      mode = 'dark',
      dark = 'catppuccin-mocha',
    },
  },

  language = {
    names = { 'lua', 'python', 'rust' },
  },
}
```

All options are deeply merged with defaults and may be overridden via Neoconf.

## 🧠 Neoconf Integration

Example `neoconf.json`:

```json
{
  "HareConf": {
    "editor": {
      "diagnostic": {
        "virtual_text": false
      }
    }
  }
}
```

A JSON schema is automatically registered for validation and completion.

## 🗂 Configuration Overview

Top-level sections:

- `system` – global exclusions (filetypes, buftypes)
- `appearance` – theme, cursor, cursor line
- `editor` – status column, diagnostics, buffers
- `language` – enabled languages
- `clipboard` – local or remote clipboard integration
- `terminal` – shell configuration

## 🧩 Buffer Configuration Model

Buffer configuration resolution order:

1. Global defaults
2. Filetype-specific overrides
3. Cached resolved result

Filetype aliases are supported:

```lua
editor = {
  filetype = {
    javascriptreact = 'javascript',
  },
}
```

## 🛠 Commands

| Command | Description |
|-------|-------------|
| `:Hareconf` | Show full resolved configuration |
| `:Hareconf buffer` | Show buffer config for current file |
| `:Hareconf lang` | Show language status |
| `:Hareconf make` | Rebuild generated files |

## 🧪 Health Check

```vim
:checkhealth hare-conf
```

## 📁 Generated Files

These files are auto-generated and should not be edited manually:

- `lua/hare-conf/types.lua`
- `lua/hare-conf/defaults.lua`
- `schemas/hare-conf.schema.json`

## 📜 License

MIT
