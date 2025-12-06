import { entry, union, T, list, table, classRef } from './hare-conf-types.js'

const CLASS_HIGHLIGHT_GROUP = classRef('vim.api.keyset.highlight', true)

const system = {
  $class_name: 'hare.System',
  $description: 'System-wide configurations.',
  buftype: {
    $class_name: 'hare.system.Buftype',
    $description: 'The configurations for system-wide buffer.',
    exclude: entry(list(T.STR), 'Buffer types to be excluded in many scenarios.', [
      'nofile',
      'quickfix',
      'terminal',
      'prompt',
      'help',
    ]),
  },
  filetype: {
    $class_name: 'hare.system.Filetype',
    $description: 'The configurations for system-wide filetype.',
    exclude: entry(list(T.STR), 'Filetypes to be excluded in many scenarios.', [
      'help',
      'qf',
      'man',
      'terminal',
      'lazy',
      'mason',
    ]),
  },
}

const appearance = {
  $class_name: 'hare.Appearance',
  $description: 'Appearance configurations.',
  netrw: {
    $class_name: 'hare.appearance.Netrw',
    $description: 'The configurations for Netrw (the built-in file explorer).',
    enabled: entry(T.BOOL, 'Whether to enable Netrw.', false),
  },
  theme: {
    $class_name: 'hare.appearance.Theme',
    $description: 'The theme configurations.',
    mode: entry(union('system', 'light', 'dark'), 'The mode of using themes.', 'system'),
    light: entry(T.STR, 'The light theme.', 'default'),
    dark: entry(T.STR, 'The dark theme.', 'default'),
  },
}

const editor = {
  $class_name: 'hare.Editor',
  $description: 'Editor configurations.',
  appearance: {
    $class_name: 'hare.editor.Appearance',
    $description: 'The appearance configurations for the editor.',
    line_number: {
      $class_name: 'hare.editor.appearance.LineNumber',
      enabled: entry(T.BOOL, 'Whether to enable line numbers.', true),
      relative: entry(T.BOOL, 'Whether to enable relative line numbers.', true),
      cursor_highlight: entry(
        CLASS_HIGHLIGHT_GROUP,
        'The highlight group for the current line number.',
        null
      ),
      highlight: entry(CLASS_HIGHLIGHT_GROUP, 'The highlight group for line numbers.', null),
    },
    sign_column: {
      $class_name: 'hare.editor.appearance.SignColumn',
      $description: 'The configurations for the sign column.',
      enabled: entry(T.BOOL, 'Whether to enable the sign column.', true),
    },
    cursor: {
      $class_name: 'hare.editor.appearance.Cursor',
      $description: 'The configurations for the cursor.',
      highlight: entry(CLASS_HIGHLIGHT_GROUP, 'The highlight group for the cursor.', null),
    },
    cursor_insert: {
      $class_name: 'hare.editor.appearance.CursorInsert',
      $description: 'The configurations for the cursor in insert mode.',
      highlight: entry(
        CLASS_HIGHLIGHT_GROUP,
        'The highlight group for the cursor in insert mode.',
        null
      ),
    },
    cursor_line: {
      $class_name: 'hare.editor.appearance.CursorLine',
      $description: 'The configurations for cursor line highlighting.',
      enabled: entry(T.BOOL, 'Whether to enable cursor line highlighting.', false),
      highlight: entry(CLASS_HIGHLIGHT_GROUP, 'The highlight group for the cursor line.', null),
    },
    fill_chars: entry(T.STR, 'The character used for end-of-buffer filling.', ' '),
  },
  diagnostic: {
    $class_name: 'hare.editor.Diagnostic',
    $description: 'The configurations for editor diagnostic.',
    virtual_text: entry(T.BOOL, 'Whether to enable virtual text for diagnostic.', true),
    virtual_lines: entry(T.BOOL, 'Whether to enable virtual lines for diagnostic.', false),
    update_in_insert: entry(T.BOOL, 'Whether to update diagnostic in insert mode.', true),
    underline: entry(T.BOOL, 'Whether to enable underline for diagnostic.', true),
    signs: entry(T.BOOL, 'Whether to enable signs for diagnostic.', true),
    severity_sort: entry(T.BOOL, 'Whether to sort diagnostic by severity.', true),
  },
  buffer: {
    $class_name: 'hare.editor.Buffer',
    $description: 'The default configurations for all editor buffers.',
    indent: {
      $class_name: 'hare.editor.buffer.Indent',
      $description: 'The indentation configurations for the editor buffer.',
      type: entry(union('spaces', 'tabs'), 'The type of indentation to use.', 'spaces'),
      width: entry(T.INT, 'The number of spaces per tab.', 4),
      display_width: entry(T.INT, 'The number of spaces to display for a tab character.', null),
      shift_width: entry(T.INT, 'The number of spaces to use for each step of indent.', null),
    },
    ruler: {
      $class_name: 'hare.editor.buffer.Ruler',
      $description: 'The ruler configurations for the editor buffer.',
      enabled: entry(T.BOOL, 'Whether to enable the ruler.', true),
      columns: entry(list(T.INT), 'The columns at which to show the ruler.', [100]),
      highlight: entry(CLASS_HIGHLIGHT_GROUP, 'The highlight group for the ruler.', null),
    },
    treesitter: {
      $class_name: 'hare.editor.buffer.Treesitter',
      $description: 'The Tree-sitter configurations for the editor buffer.',
      enabled: entry(T.BOOL, 'Whether to enable Tree-sitter.', true),
      name: entry(T.STR, 'The default Tree-sitter parser to use.', null),
    },
    lsp: {
      $class_name: 'hare.editor.buffer.Lsp',
      $description: 'The LSP configurations for the editor buffer.',
      enabled: entry(T.BOOL, 'Whether to enable LSP.', true),
      name: entry(T.STR, 'The default LSP to use.', null),
    },
    linter: {
      $class_name: 'hare.editor.buffer.Linter',
      $description: 'The linter configurations for the editor buffer.',
      enabled: entry(T.BOOL, 'Whether to enable the linter.', true),
      name: entry(T.STR, 'The default linter to use.', null),
    },
    formatter: {
      $class_name: 'hare.editor.buffer.Formatter',
      $description: 'The formatter configurations for the editor buffer.',
      enabled: entry(T.BOOL, 'Whether to enable the formatter.', true),
      name: entry(T.STR, 'The default formatter to use.', null),
    },
    debugger: {
      $class_name: 'hare.editor.buffer.Debugger',
      $description: 'The debugger configurations for the editor buffer.',
      enabled: entry(T.BOOL, 'Whether to enable the debugger.', true),
      name: entry(T.STR, 'The default debugger to use.', null),
    },
    format_on_save: entry(T.BOOL, 'Whether to format the buffer automatically on save.', true),
  },
  filetype: entry(
    table(union(T.STR, classRef('hare.editor.Buffer'))),
    'The editor buffer configurations for specific filetypes.',
    {}
  ),
}

const language = {
  $class_name: 'hare.Language',
  $description: 'Language-specific configurations.',
  names: entry(list(T.STR), 'A list of strings specific to the language.', ['lua']),
}

const clipboard = {
  $class_name: 'hare.Clipboard',
  $description: 'Clipboard integration configurations.',
  enabled: entry(T.BOOL, 'Whether to enable clipboard integration.', false),
  name: entry(T.STR, 'The name of the clipboard integration tool.', 'HareConf Clipboard'),
  host: entry(T.STR, 'The host address for clipboard integration.', ''),
  enabled_cache: entry(T.BOOL, 'Whether to enable clipboard caching.', false),
  clipboard_option: entry(T.STR, 'The clipboard option to use.', 'unnamedplus'),
}

const terminal = {
  $class_name: 'hare.Terminal',
  $description: 'Terminal configurations.',
  shell: entry(T.STR, 'The shell to use for the terminal.', null),
}

export const hareConfDefinitions = {
  $version: '2025.1',
  system,
  appearance,
  editor,
  language,
  clipboard,
  terminal,
}
