/**
 * Enumeration of supported primitive configuration entry types.
 */
export const T = Object.freeze({
    NIL: 'nil',
    STR: 'string',
    NUMBER: 'number',
    INT: 'integer',
    BOOL: 'boolean',
    TABLE: 'table',
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

/**
 * Factory function to create a new configuration entry.
 *
 * @param {Type} type - The type of the configuration entry.
 * @param {string} [description=''] - The description of the configuration entry.
 * @param {*} [defaultValue=null] - The default value of the configuration entry.
 * @param {boolean} [nullable=true] - Whether the configuration entry can be null.
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
