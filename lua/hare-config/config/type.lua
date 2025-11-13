---@class HareConfigUI
---@field disable_netrw boolean

---@class HareConfigEditorTab
---@field expand_with_spaces boolean
---@field width integer
---@field display_width integer
---@field shift_width integer

---@class HareConfigEditorLineNumber
---@field show boolean
---@field relative boolean

---@class HareConfigEditorSignColumn
---@field show boolean

---@class HareConfigEditorColorColumn
---@field enabled boolean
---@field disabled_filetypes string[]

---@class HareConfigEditor
---@field tab HareConfigEditorTab
---@field line_number HareConfigEditorLineNumber
---@field sign_column HareConfigEditorSignColumn
---@field fill_chars string
---@field cursor_line_highlight boolean
---@field color_column HareConfigEditorColorColumn

---@class HareConfig
---@field ui HareConfigUI
---@field editor HareConfigEditor
