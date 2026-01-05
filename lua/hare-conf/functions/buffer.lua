local M = {}

--- Cache of per-filetype buffer configurations. This table maps filetype strings to tables
--- representing corresponding editor buffer configurations.
---@type table<string, hare.editor.Buffer>
M._buffer_config_cache = {}

--- Hare configuration module.
local hare = require 'hare-conf'

--- Retrieves the per-filetype editor buffer configuration for a given filetype.
---
--- @param filetype string - The filetype to get per-filetype editor buffer configuration for.
--- @return hare.editor.Buffer | nil - The editor buffer configuration for the given filetype, or
---     nil if none is set.
function M.get_buffer_config_by_filetype(filetype)
    local value = hare.config.editor.filetype[filetype]

    if value == nil then
        return nil
    elseif type(value) == 'string' then
        -- If the value is a string, it represents an alias to another buffer config
        return M.get_buffer_config_by_filetype(value)
    else
        return value
    end
end

--- Gets editor buffer configuration with defaults.
---
--- Merges `config.editor.buffer` with `config.editor.filetype[filetype]` (if any) without mutating
--- the defaults. Result for a given filetype is cached.
---
--- @param filetype? string - The filetype to get editor buffer configuration for.
--- @return hare.editor.Buffer - The merged editor buffer configuration.
function M.get_buffer_config(filetype)
    -- Return cached result if any.
    if filetype and M._buffer_config_cache[filetype] ~= nil then
        return M._buffer_config_cache[filetype]
    end

    -- Start from a copy of the general defaults so we don't accidentally mutate them.
    ---@type hare.editor.Buffer
    local buffer_config = vim.deepcopy(hare.config.editor.buffer)

    if filetype then
        local filetype_buffer_config = M.get_buffer_config_by_filetype(filetype)
        if filetype_buffer_config ~= nil then
            buffer_config = vim.tbl_deep_extend('force', buffer_config, filetype_buffer_config)
        end

        -- Cache per-filetype result.
        M._buffer_config_cache[filetype] = buffer_config
    end

    return buffer_config
end

--- Sets editor buffer configuration for one or more filetypes.
---
--- It is worth noting that this function updates the buffer configuration for specified filetypes,
--- and it may affect some behaviors where they read the buffer configuration after Neovim setup.
--- For instance, if a autocmd is triggered on BufReadPost that relies on the buffer configuration,
--- the changes made by this function will be reflected in that context.
---
--- @param filetypes string[] - The filetypes to set the editor buffer configuration for.
--- @param buffer_config hare.editor.BufferInput - The editor buffer configuration to set/merge in.
function M.set_buffer_config(filetypes, buffer_config)
    for _, filetype in ipairs(filetypes) do
        local existing = hare.config.editor.buffer[filetype] or {}
        local merged = vim.tbl_deep_extend('force', {}, existing, buffer_config)

        hare.config.editor.filetype[filetype] = merged

        -- Invalidate cache so next get_buffer_config(filetype) recomputes correctly.
        M._buffer_config_cache[filetype] = nil
    end
end

--- Makes one or more filetypes reuse another filetype's buffer configuration.
---
--- This sets `config.editor.filetype[alias] = canonical_filetype` for each alias, so that
--- `get_buffer_config(alias)` resolves via `canonical_filetype`.
---
--- @param alias_filetypes string[] - Filetypes that should reuse the target's config.
--- @param canonical_filetype string - The filetype whose config should be reused.
function M.set_buffer_config_aliases(alias_filetypes, canonical_filetype)
    if type(canonical_filetype) ~= 'string' or canonical_filetype == '' then
        require('hare-conf').error(
            '(set_buffer_config_aliases) canonical_filetype must be a ' .. 'non-empty string'
        )
        return
    end

    for _, filetype in ipairs(alias_filetypes) do
        if type(filetype) == 'string' and filetype ~= '' then
            -- Store the alias as a string. get_buffer_config_by_filetype will follow this string
            -- to the canonical filetype.
            hare.config.editor.filetype[filetype] = canonical_filetype

            -- Invalidate the cache so next get_buffer_config(ft) recomputes correctly.
            M._buffer_config_cache[filetype] = nil
        end
    end
end

--- Clears all cached buffer configurations.
function M.clear_buffer_config_cache()
    M._buffer_config_cache = {}
end

--- Collects editor buffer configurations for all filetypes.
---
--- This function iterates over all filetypes defined in `config.editor.filetype`, retrieves their
--- corresponding editor buffer configurations using `get_buffer_config`, and returns a table
--- mapping filetypes to their configurations.
---
--- @return table<string, hare.editor.Buffer> - A table mapping filetypes to their editor buffer
---     configurations.
function M.collect_buffer_configs()
    ---@type table<string, hare.editor.Buffer>
    local buffer_configs = {}
    for filetype, _ in pairs(hare.config.editor.filetype) do
        local buffer_config = hare.fn.get_buffer_config(filetype)
        buffer_configs[filetype] = buffer_config
    end

    return buffer_configs
end

return M
