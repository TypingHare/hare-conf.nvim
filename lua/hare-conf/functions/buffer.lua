local M = {}

-- Cache of per-filetype buffer configurations
---@type table<string, hare.editor.Buffer>
M._buffer_config_cache = {}

-- Hare configuration
---@type hare.Config
local config = require('hare-conf').config

--- @param filetype string The filetype to get per-filetype editor buffer configuration for.
--- @return hare.editor.Buffer | nil The editor buffer configuration for the given filetype, or nil
---     if none is set.
function M.get_buffer_config_of_filetype(filetype)
    local value = config.editor.filetype[filetype]

    if value == nil then
        return nil
    elseif type(value) == 'string' then
        -- If the filetype config is a string, it refers to a language config
        return M.get_buffer_config_of_filetype(value)
    else
        return value
    end
end

--- Gets editor buffer configuration with defaults.
---
--- Merges `config.editor.buffer` with `config.editor.filetype[filetype]` (if any) without mutating
--- the defaults. Result for a given filetype is cached.
---
--- @param filetype? string The filetype to get editor buffer configuration for.
--- @return hare.editor.Buffer The merged editor buffer configuration.
function M.get_buffer_config(filetype)
    if filetype and M._buffer_config_cache[filetype] ~= nil then
        return M._buffer_config_cache[filetype]
    end

    -- Start from a copy of the general defaults so we don't accidentally mutate them
    ---@type hare.editor.Buffer
    local buffer_config = vim.deepcopy(config.editor.buffer)

    if filetype then
        local filetype_buffer_config = M.get_buffer_config_of_filetype(filetype)
        if filetype_buffer_config ~= nil then
            buffer_config = vim.tbl_deep_extend('force', buffer_config, filetype_buffer_config)
        end

        -- Cache per-filetype result
        M._buffer_config_cache[filetype] = buffer_config
    end

    return buffer_config
end

--- Sets editor buffer configuration for one or more filetypes.
---
--- @param filetypes string[] The filetypes to set the editor buffer configuration for.
--- @param buffer_config hare.editor.BufferInput The editor buffer configuration to set/merge in.
function M.set_buffer_config(filetypes, buffer_config)
    for _, filetype in ipairs(filetypes) do
        local existing = config.editor.buffer[filetype] or {}
        local merged = vim.tbl_deep_extend('force', {}, existing, buffer_config)

        config.editor.filetype[filetype] = merged

        -- Invalidate cache so next get_buffer_config(filetype) recomputes correctly
        M._buffer_config_cache[filetype] = nil
    end
end

--- Makes one or more filetypes reuse another filetype's buffer configuration.
---
--- This sets `config.editor.filetype[alias] = canonical_filetype` for each alias, so that
--- `get_buffer_config(alias)` resolves via `canonical_filetype`.
---
--- @param alias_filetypes string[] Filetypes that should reuse the target's config.
--- @param canonical_filetype string The filetype whose config should be reused.
function M.set_buffer_config_aliases(alias_filetypes, canonical_filetype)
    if type(canonical_filetype) ~= 'string' or canonical_filetype == '' then
        error('canonical_filetype must be a non-empty string', 2)
    end

    for _, ft in ipairs(alias_filetypes) do
        if type(ft) == 'string' and ft ~= '' then
            -- Store the alias as a string. get_buffer_config_of_filetype will
            -- follow this string to the canonical filetype.
            config.editor.filetype[ft] = canonical_filetype

            -- Invalidate the cache so next get_buffer_config(ft) recomputes correctly.
            M._buffer_config_cache[ft] = nil
        end
    end
end

--- Clears all cached buffer configurations.
function M.clear_buffer_config_cache()
    M._buffer_config_cache = {}
end

--- Collects editor buffer configurations for all filetypes.
---
--- @return hare.editor.Buffer[] List of buffer configurations.
function M.collect_buffer_configs()
    local hc = require 'hare-conf'

    ---@type hare.editor.Buffer[]
    local buffer_configs = {}
    for filetype, _ in pairs(hc.config.editor.filetype) do
        local buffer_config = hc.fn.get_buffer_config(filetype)
        table.insert(buffer_configs, buffer_config)
    end

    return buffer_configs
end

return M
