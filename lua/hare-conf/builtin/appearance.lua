local M = {}

--- Applies appearance configurations.
---
--- @param config hare.Appearance - Appearance configurations.
function M.apply_appearance_config(config)
    -- Netrw configuration
    if not config.netrw.enabled then
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
    end

    -- Theme configuration
    local theme_mode = config.theme.mode
    if theme_mode == 'dark' or theme_mode == 'system' then
        vim.cmd.colorscheme(config.theme.dark)
    elseif theme_mode == 'light' then
        vim.cmd.colorscheme(config.theme.dark)
    end

    -- Cursor configuration
    if config.cursor.enabled then
        vim.opt.guicursor = {
            'n:block-CursorNormal',
            'v:block-CursorVisual',
            'V:block-CursorVisual',
            'c:block-CursorCommand',
            'i:ver25-CursorInsert',
            't:block-CursorTerminal',
        }

        local normal_highlight = config.cursor.cursor_normal_highlight
            or { fg = '#000000', bg = '#a6e3a1' }
        local insert_highlight = config.cursor.cursor_insert_highlight
            or { fg = '#000000', bg = '#89b4fa' }
        local visual_highlight = config.cursor.cursor_visual_highlight
            or { fg = '#000000', bg = '#f9e2af' }
        local command_highlight = config.cursor.cursor_command_highlight
            or { fg = '#000000', bg = '#f38ba8' }
        local terminal_highlight = config.cursor.cursor_terminal_highlight
            or { fg = '#000000', bg = '#94e2d5' }

        vim.api.nvim_set_hl(0, 'CursorNormal', normal_highlight)
        vim.api.nvim_set_hl(0, 'CursorInsert', insert_highlight)
        vim.api.nvim_set_hl(0, 'CursorVisual', visual_highlight)
        vim.api.nvim_set_hl(0, 'CursorCommand', command_highlight)
        vim.api.nvim_set_hl(0, 'CursorTerminal', terminal_highlight)
    end
end

return M
