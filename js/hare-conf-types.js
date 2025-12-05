/**
 * Enumeration of supported primitive configuration entry types.
 */
export const T = Object.freeze({
    NIL: 'nil',
    STR: 'string',
    NUMBER: 'number',
    INT: 'integer',
    BOOL: 'boolean',
    ANY: 'any',
})

/**
 * List type (array-like table in Lua) representation.
 *
 * @class
 * @property {Type} elementType - The type of the list elements.
 */
export class List {
    elementType = T.NIL
}

/**
 * Table type (dictionary-like table in Lua) representation.
 *
 * @class
 * @property {Type} keyType - The type of the table keys.
 * @property {Type} valueType - The type of the table values.
 */
export class Table {
    keyType = T.STR
    valueType = T.ANY
}

/**
 * Function type representation.
 *
 * @class
 * @property {Type[]} paramTypes - The parameters of the function.
 * @property {string} returnType - The return type of the function.
 */
export class Fn {
    paramTypes = []
    returnTypes = T.NIL
}

/**
 * Union type representation.
 *
 * @class
 * @property {Type[]} types - The types in the union.
 */
export class Union {
    types = []
}

/**
 * Class reference representation.
 *
 * @class
 * @property {string} className - The name of the referenced class.
 * @property {boolean} builtin - Whether the class is a built-in class in Lua.
 */
export class ClassRef {
    className = ''
    isBuiltin = false
}

/**
 * @typedef {T | Fn | Union} Type
 */

/**
 * Configuration entry representation.
 *
 * @class
 * @property {string} type - The type of the configuration entry.
 * @property {string} description - The description of the configuration entry.
 * @property {*} defaultValue - The default value of the configuration entry.
 */
export class Entry {
    type = T.NIL
    description = ''
    nullable = false
    defaultValue = null
}

/**
 * Factory function to create a new list type.
 *
 * @param {Type} [elementType=T.NIL] - The type of the list elements.
 * @returns {List} A new list type instance.
 */
export function list(elementType = T.NIL) {
    const list = new List()
    list.elementType = elementType

    return list
}

/**
 * Factory function to create a new table type.
 *
 * @param {Type} [valueType=T.ANY] - The type of the table values.
 * @param {Type} [keyType=T.STR] - The type of the table keys.
 * @returns {Table} A new table type instance.
 */
export function table(valueType = T.ANY, keyType = T.STR) {
    const table = new Table()
    table.keyType = keyType
    table.valueType = valueType

    return table
}

/**
 * Factory function to create a new function type.
 *
 * @param {Type} [returnType=T.NIL] - The return type of the function.
 * @param {Type[]} [paramTypes=[]] - The parameter types of the function.
 * @returns {Fn} A new function type instance.
 */
export function fn(returnType = T.NIL, paramTypes = []) {
    const fn = new Fn()
    fn.returnTypes = returnType
    fn.paramTypes = paramTypes

    return fn
}

/**
 * Factory function to create a new Union type.
 *
 * @param {Type[]} types - The types in the union.
 * @returns {Union} A new literal type instance.
 */
export function union(...types) {
    const union = new Union()
    union.types = types

    return union
}

export function classRef(className, builtin = false) {
    const classRef = new ClassRef()
    classRef.className = className
    classRef.isBuiltin = builtin

    return classRef
}

/**
 * Factory function to create a new configuration entry.
 *
 * @param {Type} type - The type of the configuration entry.
 * @param {string} description - The description of the configuration entry.
 * @param {*} defaultValue - The default value of the configuration entry.
 * @param {boolean} [nullable=false] - Whether the configuration entry can be null.
 * @returns {Entry} A new configuration entry instance.
 */
export function entry(type, description, defaultValue, nullable = false) {
    if (description === undefined) {
        console.error('Description is required for configuration entry.')
        process.exit(1)
    }

    if (defaultValue === undefined) {
        console.error('Default value is required for configuration entry.')
        process.exit(1)
    }

    const entry = new Entry()
    entry.type = type
    entry.description = description
    entry.defaultValue = defaultValue
    entry.nullable = nullable

    if (defaultValue === null) {
        entry.nullable = true
    }

    return entry
}

/**
 * A recursive map of configuration entries.
 *
 * Keys are Lua table keys; values are either:
 * - an {@link Entry} instance (leaf node), or
 * - another EntryMap (nested table).
 *
 * @typedef {Object<string, Entry | EntryMap>} EntryMap
 */
