import { entry, union, T, list } from './hare-conf-types.js'

const CLASS_HIGHLIGHT_GROUP = 'class:vim.api.keyset.highlight'

const system = {
    $lua_name: 'HareConfSystem',
    buffer: {
        $lua_name: 'HareConfSystemBuffer',
        exclude: entry(list(T.STR), 'The types of buffers to be excluded in many scenarios.', []),
    },
    filetype: {
        $lua_name: 'HareConfSystemFiletype',
        exclude: entry(list(T.STR), 'The types of files to be excluded in many scenarios.', []),
    },
}

const appearance = {
    $lua_name: 'HareConfAppearance',
    netrw: {
        $lua_name: 'HareConfAppearanceNetrw',
        enabled: entry(T.BOOL, 'Whether to enable Netrw.', false),
    },
    theme: {
        $lua_name: 'HareConfAppearanceTheme',
        mode: entry(union('system', 'light', 'dark'), 'THe mode of using themes.', 'auto'),
        light: entry(T.STR, 'The light theme.', 'default'),
        dark: entry(T.STR, 'The dark theme.', 'default'),
    },
}

const editor = {
    $lua_name: 'HareConfEditor',
    appearance: {
        $lua_name: 'HareConfEditorAppearance',
        line_number: {
            $lua_name: 'HareConfEditorAppearanceLineNumber',
            enabled: entry(T.BOOL, 'Whether to enable line numbers.', true),
            relative: entry(T.BOOL, 'Whether to enable relative line numbers.', true),
            highlight: entry(CLASS_HIGHLIGHT_GROUP, 'The highlight group for line numbers.', null),
        },
        sign_column: {
            $lua_name: 'HareConfEditorAppearanceSignColumn',
            enabled: entry(T.BOOL, 'Whether to enable the sign column.', true),
        },
        cursor: {
            $lua_name: 'HareConfEditorAppearanceCursor',
            highlight: entry(CLASS_HIGHLIGHT_GROUP, 'The highlight group for the cursor.', null),
        },
        cursor_insert: {
            $lua_name: 'HareConfEditorAppearanceCursorInsert',
            highlight: entry(
                CLASS_HIGHLIGHT_GROUP,
                'The highlight group for the cursor in insert mode.',
                null
            ),
        },
        cursor_line: {
            $lua_name: 'HareConfEditorAppearanceCursorLine',
            enabled: entry(T.BOOL, 'Whether to enable cursor line highlighting.', false),
            highlight: entry(
                CLASS_HIGHLIGHT_GROUP,
                'The highlight group for the cursor line.',
                null
            ),
        },
        fill_chars: entry(T.STR, 'The characters used to fill eob.', ' '),
    },
    diagnostics: {
        $lua_name: 'HareConfEditorDiagnostics',
        virtual_text: entry(T.BOOL, 'Whether to enable virtual text for diagnostics.', true),
        virtual_lines: entry(T.BOOL, 'Whether to enable virtual lines for diagnostics.', false),
        update_in_insert: entry(T.BOOL, 'Whether to update diagnostics in insert mode.', true),
        underline: entry(T.BOOL, 'Whether to enable underline for diagnostics.', true),
        signs: entry(T.BOOL, 'Whether to enable signs for diagnostics.', true),
        severity_sort: entry(T.BOOL, 'Whether to sort diagnostics by severity.', true),
    },
}

const clipboard = {
    $lua_name: 'HareConfClipboard',
    enabled: entry(T.BOOL, 'Whether to enable clipboard integration.', false),
    name: entry(T.STR, 'The name of the clipboard integration tool.', 'HareConf Clipboard'),
    host: entry(T.STR, 'The host address for clipboard integration.', ''),
    enabled_cache: entry(T.BOOL, 'Whether to enable clipboard caching.', false),
    clipboard_option: entry(T.STR, 'The clipboard option to use.', 'unnamedplus'),
}

const terminal = {
    $lua_name: 'HareConfTerminal',
    shell: entry(T.STR, 'The shell to use for the terminal.', '/bin/bash'),
}

export const hareConfDefinitions = {
    system,
    appearance,
    editor,
    clipboard,
    terminal,
}
