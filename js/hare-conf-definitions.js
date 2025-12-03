import { entry, union, T, list, table, classRef } from './hare-conf-types.js'

const CLASS_HIGHLIGHT_GROUP = classRef('vim.api.keyset.highlight')

const system = {
    $lua_name: 'HareConfSystem',
    $description: 'System-wide settings.',
    buffer: {
        $lua_name: 'HareConfSystemBuffer',
        $description: 'The settings for system-wide buffer.',
        exclude: entry(list(T.STR), 'Buffer types to be excluded in many scenarios.', []),
    },
    filetype: {
        $lua_name: 'HareConfSystemFiletype',
        $description: 'The settings for system-wide filetype.',
        exclude: entry(list(T.STR), 'Filetypes to be excluded in many scenarios.', []),
    },
}

const appearance = {
    $lua_name: 'HareConfAppearance',
    $description: 'Appearance settings.',
    netrw: {
        $lua_name: 'HareConfAppearanceNetrw',
        $description: 'The settings for Netrw (the built-in file explorer).',
        enabled: entry(T.BOOL, 'Whether to enable Netrw.', false),
    },
    theme: {
        $lua_name: 'HareConfAppearanceTheme',
        $description: 'The theme settings.',
        mode: entry(union('system', 'light', 'dark'), 'The mode of using themes.', 'system'),
        light: entry(T.STR, 'The light theme.', 'default'),
        dark: entry(T.STR, 'The dark theme.', 'default'),
    },
}

const editor = {
    $lua_name: 'HareConfEditor',
    $description: 'Editor settings.',
    appearance: {
        $lua_name: 'HareConfEditorAppearance',
        $description: 'The appearance settings for the editor.',
        line_number: {
            $lua_name: 'HareConfEditorAppearanceLineNumber',
            enabled: entry(T.BOOL, 'Whether to enable line numbers.', true),
            relative: entry(T.BOOL, 'Whether to enable relative line numbers.', true),
            highlight: entry(CLASS_HIGHLIGHT_GROUP, 'The highlight group for line numbers.', null),
        },
        sign_column: {
            $lua_name: 'HareConfEditorAppearanceSignColumn',
            $description: 'The settings for the sign column.',
            enabled: entry(T.BOOL, 'Whether to enable the sign column.', true),
        },
        cursor: {
            $lua_name: 'HareConfEditorAppearanceCursor',
            $description: 'The settings for the cursor.',
            highlight: entry(CLASS_HIGHLIGHT_GROUP, 'The highlight group for the cursor.', null),
        },
        cursor_insert: {
            $lua_name: 'HareConfEditorAppearanceCursorInsert',
            $description: 'The settings for the cursor in insert mode.',
            highlight: entry(
                CLASS_HIGHLIGHT_GROUP,
                'The highlight group for the cursor in insert mode.',
                null
            ),
        },
        cursor_line: {
            $lua_name: 'HareConfEditorAppearanceCursorLine',
            $description: 'The settings for cursor line highlighting.',
            enabled: entry(T.BOOL, 'Whether to enable cursor line highlighting.', false),
            highlight: entry(
                CLASS_HIGHLIGHT_GROUP,
                'The highlight group for the cursor line.',
                null
            ),
        },
        fill_chars: entry(T.STR, 'The character used for end-of-buffer filling.', ' '),
    },
    diagnostics: {
        $lua_name: 'HareConfEditorDiagnostics',
        $description: 'The settings for editor diagnostics.',
        virtual_text: entry(T.BOOL, 'Whether to enable virtual text for diagnostics.', true),
        virtual_lines: entry(T.BOOL, 'Whether to enable virtual lines for diagnostics.', false),
        update_in_insert: entry(T.BOOL, 'Whether to update diagnostics in insert mode.', true),
        underline: entry(T.BOOL, 'Whether to enable underline for diagnostics.', true),
        signs: entry(T.BOOL, 'Whether to enable signs for diagnostics.', true),
        severity_sort: entry(T.BOOL, 'Whether to sort diagnostics by severity.', true),
    },
    buffer: {
        $lua_name: 'HareConfEditorBuffer',
        $description: 'The default settings for all editor buffers.',
        indent: {
            $lua_name: 'HareConfEditorBufferIndent',
            $description: 'The indentation settings for the editor buffer.',
            type: entry(union('spaces', 'tabs'), 'The type of indentation to use.', 'spaces'),
            width: entry(T.INT, 'The number of spaces per tab.', 4),
            display_width: entry(T.INT, 'The number of spaces to display for a tab character.', 4),
            shift_size: entry(T.INT, 'The number of spaces to use for each step of indent.', 4),
        },
        ruler: {
            $lua_name: 'HareConfEditorBufferRuler',
            $description: 'The ruler settings for the editor buffer.',
            enabled: entry(T.BOOL, 'Whether to enable the ruler.', true),
            columns: entry(list(T.INT), 'The columns at which to show the ruler.', [80, 100]),
            highlight: entry(CLASS_HIGHLIGHT_GROUP, 'The highlight group for the ruler.', null),
        },
        treesitter: {
            $lua_name: 'HareConfEditorBufferTreesitter',
            $description: 'The Tree-sitter settings for the editor buffer.',
            enabled: entry(T.BOOL, 'Whether to enable Tree-sitter.', true),
            name: entry(T.STR, 'The default Tree-sitter parser to use.', null),
        },
        lsp: {
            $lua_name: 'HareConfEditorBufferLSP',
            $description: 'The LSP settings for the editor buffer.',
            enabled: entry(T.BOOL, 'Whether to enable LSP.', true),
            name: entry(T.STR, 'The default LSP to use.', null),
        },
        linter: {
            $lua_name: 'HareConfEditorBufferLinter',
            $description: 'The linter settings for the editor buffer.',
            enabled: entry(T.BOOL, 'Whether to enable the linter.', true),
            name: entry(T.STR, 'The default linter to use.', null),
        },
        formatter: {
            $lua_name: 'HareConfEditorBufferFormatter',
            $description: 'The formatter settings for the editor buffer.',
            enabled: entry(T.BOOL, 'Whether to enable the formatter.', true),
            name: entry(T.STR, 'The default formatter to use.', null),
        },
        debugger: {
            $lua_name: 'HareConfEditorBufferDebugger',
            $description: 'The debugger settings for the editor buffer.',
            enabled: entry(T.BOOL, 'Whether to enable the debugger.', true),
            name: entry(T.STR, 'The default debugger to use.', null),
        },
    },
    filetype: entry(
        table(union(T.STR, classRef('HareConfEditorBuffer'))),
        'The editor buffer settings for specific filetypes.',
        {}
    ),
}

const clipboard = {
    $lua_name: 'HareConfClipboard',
    $description: 'Clipboard integration settings.',
    enabled: entry(T.BOOL, 'Whether to enable clipboard integration.', false),
    name: entry(T.STR, 'The name of the clipboard integration tool.', 'HareConf Clipboard'),
    host: entry(T.STR, 'The host address for clipboard integration.', ''),
    enabled_cache: entry(T.BOOL, 'Whether to enable clipboard caching.', false),
    clipboard_option: entry(T.STR, 'The clipboard option to use.', 'unnamedplus'),
}

const terminal = {
    $lua_name: 'HareConfTerminal',
    $description: 'Terminal settings.',
    shell: entry(T.STR, 'The shell to use for the terminal.', null),
}

export const hareConfDefinitions = {
    $version: '2025.1',
    system,
    appearance,
    editor,
    clipboard,
    terminal,
}
