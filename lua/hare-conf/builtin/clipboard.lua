local M = {}

local hare = require 'hare-conf'

--- Sets up clipboard integration according to the Hare configuration.
---
--- This function configures Neovim's clipboard behavior using values from `hare.config.clipboard`.
--- It always sets `vim.opt.clipboard`, and, if a remote clipboard host is configured, it registers
--- a custom clipboard provider via `vim.g.clipboard` that proxies copy/paste operations through
--- HTTP using `curl`.
---
--- When `config.host` is an empty string, no custom clipboard provider is installed and Neovim
--- falls back to its default clipboard handling.
---
--- Side effects:
---   - Sets `vim.opt.clipboard`
---   - Optionally sets `vim.g.clipboard`
---
--- Requirements:
---   - `curl` must be available in `$PATH` when `config.host` is set
function M.setup()
    local config = hare.config.clipboard

    vim.opt.clipboard = config.clipboard_option

    local host = config.host
    if host ~= '' then
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

return M
