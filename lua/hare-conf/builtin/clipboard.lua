local M = {}

--- Applies clipboard configurations.
---
--- @param config HareConfClipboard Clipboard configurations.
function M.apply_clipboard_config(config)
    if config.enabled then
        local host = config.host
        if host == '' then
            vim.notify(
                'Stop setting HareConf clipboard: clipboard.host is empty.',
                vim.log.levels.WARN { title = require('hare-conf').NAME }
            )
        else
            local copy_cmd = string.format('curl -s -X POST %s -d @-', vim.fn.shellescape(host))
            local paste_cmd = string.format('curl -s %s', vim.fn.shellescape(host))

            vim.g.clipboard = {
                name = config.name,
                copy = { ['+'] = copy_cmd, ['*'] = copy_cmd },
                paste = { ['+'] = paste_cmd, ['*'] = paste_cmd },
                cache_enabled = config.enabled_cache and 1 or 0,
            }
        end
    end

    vim.opt.clipboard = config.clipboard_option
end

return M
