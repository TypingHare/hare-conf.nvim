import { hareConfDefinitions } from './hare-conf-definitions.js'
import { Entry } from './hare-conf-types.js'

/**
 * Prefixes the first line with a Lua table key and appends a trailing comma
 * to the last line, turning a value representation into a table field.
 *
 * This function mutates and returns the same `lines` array.
 *
 * Example:
 *   lines: ["{", "  1", "}"], key: "foo"
 *   result: ["foo = {", "  1", "},"]
 *
 * @param {string[]} lines - Lines representing a Lua value.
 * @param {string} key - The Lua key for this table field (unquoted).
 * @returns {string[]} The same `lines` array, modified in place.
 */
function makeLinesEntry(lines, key) {
  lines[0] = key + ' = ' + lines[0]
  lines[lines.length - 1] += ','

  return lines
}

/**
 * Recursively converts a JavaScript value into an array of strings
 * representing its Lua equivalent.
 *
 * Supported conversions:
 * - `null` / `undefined` → `nil`
 * - `string` → single-quoted Lua string
 * - `boolean` → `true` / `false`
 * - `number` → numeric literal
 * - `Array` → Lua array-style table (`{ ... }`)
 * - `Object` → Lua map-style table (`{ key = value, ... }`)
 *
 * Complex values (arrays/objects) may span multiple lines.
 *
 * Note: strings are inserted verbatim inside single quotes and are not escaped.
 *
 * @param {*} value - The JavaScript value to convert.
 * @returns {string[]} Lines representing the Lua value.
 */
function valueToLines(value) {
  const lines = []
  if (value === null || value === undefined) {
    lines.push('nil')
  } else if (typeof value === 'string') {
    lines.push(`'${value}'`)
  } else if (typeof value === 'boolean') {
    lines.push(value ? 'true' : 'false')
  } else if (typeof value === 'number') {
    lines.push(String(value))
  } else if (Array.isArray(value)) {
    lines.push('{')
    for (const item of value) {
      const itemLines = valueToLines(item)
      // Add a trailing comma to each array element
      itemLines[itemLines.length - 1] += ','
      lines.push(...itemLines)
    }
    lines.push('}')
  } else if (typeof value === 'object') {
    lines.push('{')
    // Treat plain objects as Lua tables: key = value
    for (const [key, val] of Object.entries(value)) {
      lines.push(...makeLinesEntry(valueToLines(val), key))
    }
    lines.push('}')
  }

  return lines
}

/**
 * Recursively generates lines for a Lua table from an EntryMap.
 *
 * For each key:
 * - If the value is an {@link Entry}, its `defaultValue` is serialized.
 * - If the value is a plain object, it is treated as a nested table and
 *   processed recursively as another EntryMap.
 *
 * @param {EntryMap} entryMap - Map of configuration keys to entries or nested maps.
 * @returns {string[]} Lines representing the Lua table literal.
 */
function generateLuaTable(entryMap) {
  const lines = ['{']
  for (const [key, entry] of Object.entries(entryMap)) {
    if (entry instanceof Entry) {
      const { defaultValue } = entry
      lines.push(...makeLinesEntry(valueToLines(defaultValue), key))
    } else if (typeof entry === 'object') {
      // Nested table
      lines.push(...makeLinesEntry(generateLuaTable(entry), key))
    }
  }
  lines.push('}')

  return lines
}

// Build the final Lua module:
//   - First line: EmmyLua annotation for the HareConf type.
//   - Then the generated table, prefixed with `return`.
const lines = ['---@type HareConf', ...generateLuaTable(hareConfDefinitions)]
lines[1] = 'return ' + lines[1]

console.log(lines.join('\n'))
