---@class HighlightGroup
---@field fg string
---@field bg string
---@field bold boolean

---@class HareConfigUI
---@field disable_netrw boolean
---@field color_scheme string

---@class HareConfigEditorTab
---@field expand_with_spaces boolean
---@field width integer
---@field display_width integer
---@field shift_width integer

---@class HareConfigEditorLineNumber
---@field show boolean
---@field relative boolean
---@field highlight HighlightGroup
---@field cursor_highlight HighlightGroup

---@class HareConfigEditorSignColumn
---@field show boolean

---@class HareConfigEditorColorColumn
---@field enabled boolean
---@field disabled_filetypes string[]

---@class HareConfigEditorCursorLineHighlight
---@field enabled boolean
---@field highlight HighlightGroup

---@class HareConfigEditor
---@field tab HareConfigEditorTab
---@field line_number HareConfigEditorLineNumber
---@field sign_column HareConfigEditorSignColumn
---@field fill_chars string
---@field cursor_insert_highlight HighlightGroup
---@field cursor_line_highlight HareConfigEditorCursorLineHighlight
---@field color_column HareConfigEditorColorColumn

---@class HareConfigKeymap

---@class HareConfigClipbopard
---@field enabled boolean
---@field name string
---@field host string
---@field enabled_cache boolean
---@field clipboard_option string

---@class HareConfig
---@field ui HareConfigUI
---@field editor HareConfigEditor
---@field keymap HareConfigKeymap
---@field clipboard HareConfigClipbopard
