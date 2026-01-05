import { T, List, Table, Fn, Union, Entry, ClassRef } from './hare-conf-types.js'
import { hareConfDefinitions } from './hare-conf-definitions.js'

/**
 * Converts a Hare configuration type to a JSON schema type.
 *
 * @param {Type} type - The Hare configuration type.
 * @returns {Object} - The corresponding JSON schema type.
 */
function toJsonSchemaType(type) {
  if (typeof type === 'string') {
    switch (type) {
      case T.NIL:
        return { type: 'null' }
      case T.STR:
        return { type: 'string' }
      case T.NUMBER:
        return { type: 'number' }
      case T.INT:
        return { type: 'integer' }
      case T.BOOL:
        return { type: 'boolean' }
      case T.ANY:
        return {}
    }

    // Enumeration of string literals
    return { const: type }
  } else if (type instanceof List) {
    return {
      type: 'array',
      items: toJsonSchemaType(type.elementType),
    }
  } else if (type instanceof Fn) {
    return {
      type: 'object',
    }
  } else if (type instanceof Union) {
    const types = type.types.map((type) => toJsonSchemaType(type))
    if (types.every((type) => type.hasOwnProperty('const'))) {
      return { enum: types.map((type) => type.const) }
    } else {
      return { anyOf: types }
    }
  } else if (type instanceof Table) {
    return {
      type: 'object',
      additionalProperties: toJsonSchemaType(type.valueType),
    }
  } else if (type instanceof ClassRef) {
    return {
      $ref: `#${type.className}`,
    }
  }
}

/**
 * Generates a JSON schema from the provided entry.
 *
 * @param {Entry} entry - The entry object to generate the schema from.
 * @returns {Object} - The generated JSON schema.
 */
function generateJsonSchemaFromEntry(entry) {
  const { type, description } = entry
  const schema = { description, ...toJsonSchemaType(type) }

  return schema
}

/**
 * Generates a JSON schema from the provided entry map.
 *
 * @param {string} className - The name of the class for which the schema is being generated.
 * @param {EntryMap} entryMap - The map of entries to generate the schema from.
 * @returns {Object} - The generated JSON schema.
 */
function generateJsonSchema(className, entryMap) {
  const properties = {}
  for (const [name, entry] of Object.entries(entryMap)) {
    if (entry instanceof Entry) {
      properties[name] = generateJsonSchemaFromEntry(entry)
    } else if (typeof entry === 'object') {
      const childClassName = entry.$class_name
      properties[name] = generateJsonSchema(childClassName, entry)
    }
  }

  return {
    $anchor: className,
    type: 'object',
    properties,
    additionalProperties: false,
  }
}

const hareConfSchema = generateJsonSchema('HareConf', hareConfDefinitions)
const jsonSchema = {
  $schema: 'https://json-schema.org/draft/2020-12/schema',
  $defs: {
    Highlight: {
      $anchor: 'vim.api.keyset.highlight',
      type: 'object',
      properties: {
        fg: { type: 'string' },
        bg: { type: 'string' },
        bold: { type: 'boolean' },
      },
      additionalProperties: false,
    },
  },
  title: 'HareConf Schema',
  type: 'object',
  properties: {
    HareConf: hareConfSchema,
  },
}

console.log(JSON.stringify(jsonSchema, null, 2))
