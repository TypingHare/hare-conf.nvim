const targetLuaFile = process.argv[2]

if (!targetLuaFile) {
    console.log('Please provide a target Lua file path as an argument.')
    process.exit(1)
}

import { hareConfDefinitions } from './hare-conf-definitions.js'
import { T, Entry, List, Fn, Union } from './hare-conf-types.js'

const PRIMITIVE_TYPE_SET = new Set(Object.values(T))

/**
 * Converts a JavaScript type to a Lua type annotation.
 *
 * @param {Type} type The JavaScript type.
 * @returns {string} The corresponding Lua type annotation.
 */
function toLuaType(type) {
    if (typeof type === 'string') {
        if (PRIMITIVE_TYPE_SET.has(type)) {
            return type
        } else if (type.startsWith('class:')) {
            return type.slice(6)
        } else {
            return `'${type}'`
        }
    } else if (type instanceof List) {
        const elementType = toLuaType(type.elementType)
        return `${elementType}[]`
    } else if (type instanceof Fn) {
        const paramTypes = type.paramTypes.map(toLuaType).join(', ')
        const returnType = toLuaType(type.returnTypes)
        return `fun(${paramTypes}): ${returnType}`
    } else if (type instanceof Union) {
        const luaTypes = type.types.map(toLuaType)
        return luaTypes.join(' | ')
    }
}

function createLuaField(name, luaType, description, nullable) {
    const desc = description ? `  # ${description}` : ''
    const qm = nullable ? '?' : ''
    return `---@field ${name}${qm} ${luaType}${desc}`.trim()
}

/**
 * @param {string} className The name of the Lua class.
 * @param {Object.<string, Entry>} entryMap The map of entries to include in the class.
 * @returns {string[]} The lines of the Lua class definition.
 */
function createLuaClass(className, entryMap) {
    if (!className) {
        return []
    }

    let lines = [`---@class ${className}`]
    for (const [name, entry] of Object.entries(entryMap)) {
        if (entry instanceof Entry) {
            const { type, description, nullable } = entry
            const luaType = toLuaType(type)
            lines.push(createLuaField(name, luaType, description, nullable))
        } else if (typeof entry === 'object') {
            const childClassName = entry.$lua_name
            const childEntryMap = { ...entry }
            const moreLines = createLuaClass(childClassName, childEntryMap)
            const description = entry.$description || ''
            const nullable = Boolean(entry.$nullable)
            lines = [
                ...moreLines,
                '',
                ...lines,
                createLuaField(name, childClassName, description, nullable),
            ]
        }
    }

    return lines
}

const luaFileContent = createLuaClass('HareConf', hareConfDefinitions).join('\n')
console.log(luaFileContent)
