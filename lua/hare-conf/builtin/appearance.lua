local M = {}

--- Applies appearance configurations.
---
--- @param config HareConfAppearance Appearance configurations.
function M.apply_appearance_config(config)
    if not config.netrw.enabled then
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
    end

    local theme_mode = config.theme.mode
    if theme_mode == 'dark' or theme_mode == 'system' then
        vim.cmd.colorscheme(config.theme.dark)
    elseif theme_mode == 'light' then
        vim.cmd.colorscheme(config.theme.dark)
    end
end

return M
