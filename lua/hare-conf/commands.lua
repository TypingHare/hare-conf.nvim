local M = require 'hare-conf'

--- Displays a Lua code snippet in a popup window using Popup from nui.nvim.
---
--- The popup window will display the provided Lua code snippet in a Markdown buffer. The buffer is
--- readonly and not modifiable. The popup can be closed by pressing 'q' or 'Esc'.
---
--- @param lua_code string The Lua code snippet to display.
--- @param title string The title of the popup window.
local display_lua_code = function(lua_code, title)
    local ok, Popup = pcall(require, 'nui.popup')
    if not ok then
        vim.notify(
            'nui.nvim is not installed (required for popup)',
            vim.log.levels.ERROR,
            { title = M.NAME }
        )
        return
    end

    -- Create markdown text
    local markdown_text = '```lua\n' .. lua_code .. '\n```'
    local lines = vim.split(markdown_text, '\n', { plain = true })

    -- Create popup
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

    -- Mount the popup window
    popup:mount()

    vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, lines)
    vim.api.nvim_set_option_value('filetype', 'markdown', { buf = popup.bufnr })
    vim.api.nvim_set_option_value('buftype', 'nofile', { buf = popup.bufnr })
    vim.api.nvim_set_option_value('modifiable', false, { buf = popup.bufnr })
    vim.api.nvim_set_option_value('readonly', true, { buf = popup.bufnr })
    vim.api.nvim_set_option_value('conceallevel', 2, { win = popup.winid })

    -- Close with q or <Esc>
    local opts = { noremap = true, silent = true, buffer = popup.bufnr }
    local quit_callback = function()
        popup:unmount()
    end

    vim.keymap.set('n', 'q', quit_callback, opts)
    vim.keymap.set('n', '<Esc>', quit_callback, opts)
end

--- Displays the Hare configuration in a popup window.
local display_config = function()
    display_lua_code(vim.inspect(M.config), 'Hare Configuration')
end

--- Displays the buffer configuration for the given filetype in a popup window.
---
--- If no filetype is provided, the default buffer configuration is displayed.
---
--- @param filetype string The filetype associated with the buffer.
local display_buffer_config = function(filetype)
    local filetype_specified = filetype and filetype ~= ''
    local buffer_config = filetype_specified and M.fn.get_buffer_config(filetype)
        or M.config.editor.buffer

    display_lua_code(
        vim.inspect(buffer_config),
        filetype_specified and 'Hare Configuration for Buffer (' .. filetype .. ')'
            or 'Hare Configuration for Buffer'
    )
end

-- Register commands
vim.api.nvim_create_user_command(M.COMMAND_NAME, function(opts)
    local command = opts.args
    if #command > 0 then
        local subcommand = opts.args
        if subcommand == 'buffer' then
            display_buffer_config(vim.bo.filetype)
        elseif subcommand == 'lang' then
            local object = {
                supported_languages = M.fn.get_supported_languages(),
                enabled_languages = M.fn.get_enabled_languages(),
            }
            display_lua_code(vim.inspect(object), 'Hare Languages')
        elseif subcommand == 'make' then
            M.run_make()
        else
            vim.notify('Unknown command: ' .. subcommand, vim.log.levels.WARN, { title = M.NAME })
        end
    else
        display_config()
    end
end, {
    nargs = '*',
    desc = 'HareConf commands',
})
