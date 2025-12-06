local M = {}

local appearance = require 'hare-conf.builtin.appearance'
local clipboard = require 'hare-conf.builtin.clipboard'
local editor = require 'hare-conf.builtin.editor'
local language = require 'hare-conf.builtin.language'

M.apply_appearance_config = appearance.apply_appearance_config

M.apply_clipboard_config = clipboard.apply_clipboard_config

M.apply_editor_config = editor.apply_editor_config
M.apply_editor_appearance_config = editor.apply_editor_appearance_config
M.apply_diagnostic_config = editor.apply_diagnostic_config
M.create_buffer_autocommands = editor.create_buffer_autocommands
M.install_treesitters = editor.install_treesitters
M.install_mason_packages = editor.install_mason_packages
M.enable_lsp = editor.enable_lsp
M.set_up_conform = editor.set_up_conform

M.enable_language = language.enable_language
M.enable_languages_in_config = language.enable_languages_in_config

--- Applies all configurations.
---
--- @param config hare.Config The complete configuration table.
M.apply_config = function(config)
    M.apply_appearance_config(config.appearance)
    M.apply_clipboard_config(config.clipboard)
    M.apply_editor_config(config.editor)
end

return M
