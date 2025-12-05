import { hareConfDefinitions } from './hare-conf-definitions.js'
import { T, Entry, List, Table, Fn, Union, ClassRef } from './hare-conf-types.js'

const PRIMITIVE_TYPE_SET = new Set(Object.values(T))
const INPUT_CLASS_SUFFIX = 'Input'

const isInput = process.argv[2] == '--input' || false

/**
 * Converts a JavaScript type to a Lua type annotation.
 *
 * @param {Type} type The JavaScript type.
 * @param {boolean} [isInput=false] Whether the type is for user input types.
 * @returns {string} The corresponding Lua type annotation.
 */
function toLuaType(type, isInput = false) {
    if (typeof type === 'string') {
        return PRIMITIVE_TYPE_SET.has(type) ? type : `'${type}'`
    } else if (type instanceof List) {
        const elementType = toLuaType(type.elementType, isInput)
        return `${elementType}[]`
    } else if (type instanceof Fn) {
        const paramTypes = type.paramTypes.map((t) => toLuaType(t, isInput)).join(', ')
        const returnType = toLuaType(type.returnTypes, isInput)
        return `fun(${paramTypes}): ${returnType}`
    } else if (type instanceof Union) {
        const luaTypes = type.types.map((t) => toLuaType(t, isInput))
        return luaTypes.join(' | ')
    } else if (type instanceof Table) {
        const keyType = toLuaType(type.keyType, isInput)
        const valueType = toLuaType(type.valueType, isInput)
        return `table<${keyType}, ${valueType}>`
    } else if (type instanceof ClassRef) {
        const { className, isBuiltin } = type
        return isBuiltin ? className : className + (isInput ? INPUT_CLASS_SUFFIX : '')
    }
}

/**
 * Creates a Lua field annotation.
 *
 * @param {string} name The name of the field.
 * @param {string} luaType The Lua type annotation.
 * @param {string} description The description of the field.
 * @param {boolean} nullable Whether the field is nullable.
 * @returns {string} The Lua field annotation.
 */
function createLuaField(name, luaType, description, nullable) {
    const desc = description ? `  # ${description}` : ''
    const qm = nullable ? '?' : ''

    return `---@field ${name}${qm} ${luaType}${desc}`.trim()
}

/**
 * @param {string} className The name of the Lua class.
 * @param {EntryMap} entryMap The map of entries to include in the class.
 * @param {boolean} [isInput=false] Whether the type is for user input types.
 * @returns {string[]} The lines of the Lua class definition.
 */
function createLuaClass(className, entryMap, isInput = false) {
    if (!className) {
        return []
    }

    if (isInput) {
        className += INPUT_CLASS_SUFFIX
    }

    let lines = [`---@class ${className}`]
    for (const [name, entry] of Object.entries(entryMap)) {
        if (entry instanceof Entry) {
            const { type, description, nullable } = entry
            const luaType = toLuaType(type, isInput)
            lines.push(createLuaField(name, luaType, description, isInput || nullable))
        } else if (typeof entry === 'object') {
            const childClassName = entry.$class_name
            const moreLines = createLuaClass(childClassName, entry, isInput)
            const description = entry.$description || ''
            const nullable = Boolean(entry.$nullable)
            const realChildClassName = isInput
                ? childClassName + INPUT_CLASS_SUFFIX
                : childClassName
            lines = [
                ...moreLines,
                '',
                ...lines,
                createLuaField(name, realChildClassName, description, isInput || nullable),
            ]
        }
    }

    return lines
}

const luaFileContent = createLuaClass('HareConf', hareConfDefinitions, isInput).join('\n')

console.log(luaFileContent)
