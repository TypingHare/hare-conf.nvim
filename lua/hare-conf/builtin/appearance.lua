local M = {}

local hare = require 'hare-conf'

--- Sets up appearance-related configuration.
---
--- This is the main entry point for the appearance module. It applies the configured theme, cursor
--- styling, and cursor line highlighting in a predictable order.
function M.setup()
    M.apply_theme()
    M.apply_cursor()
    M.apply_cursor_line()
end

--- Applies the configured colorscheme based on theme settings.
---
--- This function selects and applies a colorscheme according to
--- `hare.config.appearance.theme.mode`. Supported modes are:
---
---  	- "dark": always use the dark theme
---  	- "light": always use the light theme
---  	- "system": currently defaults to the dark theme
---
function M.apply_theme()
    local theme = hare.config.appearance.theme

    if theme.mode == 'dark' then
        vim.cmd.colorscheme(theme.dark)
    elseif theme.mode == 'light' then
        vim.cmd.colorscheme(theme.light)
    elseif theme.mode == 'system' then
        vim.cmd.colorscheme(theme.dark)
    end
end

--- Applies GUI cursor shape and highlight configuration.
---
--- This function configures `guicursor` and defines highlight groups for different editor modes
--- when cursor styling is enabled. Each mode can be customized via the appearance cursor
--- configuration, with sensible defaults provided as fallbacks.
function M.apply_cursor()
    local cursor = hare.config.appearance.cursor

    if cursor.enabled then
        vim.opt.guicursor = {
            'n:block-CursorNormal',
            'v:block-CursorVisual',
            'V:block-CursorVisual',
            'c:block-CursorCommand',
            'i:ver25-CursorInsert',
            't:block-CursorTerminal',
        }

        local normal_highlight = cursor.normal_highlight or { fg = '#000000', bg = '#a6e3a1' }
        local insert_highlight = cursor.insert_highlight or { fg = '#000000', bg = '#89b4fa' }
        local visual_highlight = cursor.visual_highlight or { fg = '#000000', bg = '#f9e2af' }
        local command_highlight = cursor.command_highlight or { fg = '#000000', bg = '#f38ba8' }
        local terminal_highlight = cursor.terminal_highlight or { fg = '#000000', bg = '#94e2d5' }

        vim.api.nvim_set_hl(0, 'CursorNormal', normal_highlight)
        vim.api.nvim_set_hl(0, 'CursorInsert', insert_highlight)
        vim.api.nvim_set_hl(0, 'CursorVisual', visual_highlight)
        vim.api.nvim_set_hl(0, 'CursorCommand', command_highlight)
        vim.api.nvim_set_hl(0, 'CursorTerminal', terminal_highlight)
    end
end

--- Applies cursor line highlighting.
---
--- This function enables and configures the `CursorLine` highlight group when cursor line
--- highlighting is enabled in the appearance configuration.
function M.apply_cursor_line()
    local cursor_line = hare.config.appearance.cursor_line

    if cursor_line.enabled then
        hare.fn.set_highlight('CursorLine', cursor_line.highlight)
    end
end

return M
