require '../schematype/base'
require '../schematype/schema'
require '../schematype/document'

class global.SchemaType.Exporter extends SchemaType.Base
  run: ->
    while @next_io 'stp', @args.to
      schema = new SchemaType.Schema input: @input
      if process.env.TEST_SCHEMA?
        @output.write (require 'js-yaml').dump schema
        break

      document = new SchemaType.Document schema: schema
      if process.env.TEST_DOC?
        @output.write (require 'js-yaml').dump document
        break

      output_type = @args.to || @output.type
      if output_type != 'jsc'
        error "invalid export type '#{output_type}'"

      @output.write @to_json_schema document

      if not process.env.TEST_EXPORT?
        if @output.name != '-'
          say "Exported '#{@input.name}' to '#{@output.name}'"

  from_input: (input)->
    schema = new SchemaType.Schema input: input
    document = schema.compile()
    @to_json_schema xxx document

  to_json_schema: (doc)->
    @jsc =
      '$schema': 'http://json-schema.org/draft-04/schema#'
      name: doc.meta.name.replace /^\//, ''
      type: 'object'
      additionalProperties: false
      required: []
      allOf: []
      properties: {}
      # definitions: {}

    @convert doc.main(), @jsc

    (JSON.stringify @jsc, null, 2) + "\n"

  convert: (node, jsc)->
    for elem in node.hash
      if _.isArray elem
        if elem[0] == 'type'
          delete jsc.properties
          key = (_.keys elem[1])[0]
          val = elem[1][key]
          pattern = jsc_type_map[key].pattern
          jsc.patternProperties = "#{pattern}": @get_jval val
        else
          xxx elem
      else
        key = (_.keys elem)[0]
        val = elem[key]
        jval = {}
        if val.type?
          jval = @get_jval val
        jval.type = 'string' if val.type == 'str'
        if val.like?
          like = val.like \
            .replace(/^\//, '') \
            .replace /\/[i]$/, ''
          jval.pattern = like
        if val.enum?
          jval.enum = val.enum
        if val.hash?
          jval =
            type: 'object'
            additionalProperties: false
            required: []
            allOf: []
            properties: {}
          @convert val, jval
        if val.list?
          jval =
            type: 'array'
            items: jval
        if val.need?
          jsc.required.push key
        if val.deny?
          deny =
            oneOf: [
              {required: [key]},
              {anyOf: _.map val.deny, (k)->
                required: [k]},
              {not:
                anyOf: _.map [key, val.deny...], (k)->
                  required: [k]},
            ]
          jsc.allOf.push deny
        jsc.properties[key] = jval
    if jsc.required.length == 0
      delete jsc.required
    if jsc.allOf.length == 0
      delete jsc.allOf

  get_jval: (val)->
    jval = {}
    if _.isArray val.type
      return oneOf: val.type.map (v)=>
        return {type: 'string'} if v == 'str'
        @get_jval {type: v}
    if jsc_type = jsc_type_map[val.type]
      jval = jsc_type
    else if val.type.match /^\//
      jval = '$ref': "#/definitions#{val.type}"
    if val.null
      jval = oneOf: [ jval, type: 'null' ]
    jval

jsc_type_map =
  bool:
    type: 'boolean'
  'code/shell-command':
    type: 'string'
  'file/path/dir/rel':
    type: 'string'
  'file/path/rel':
    type: 'string'
  'int':
    type: 'integer'
  'int/pos':
    type: 'integer'
    minimum: 1
  'net/domain-name':
    type: 'string'
  'net/uri':
    type: 'string'
    format: 'uri'
  'net/host-name':
    type: 'string'
    pattern: '^[-\\w]+$'
  'num':
    type: 'number'
  'str/word':
    type: 'string'
    pattern: '^[-\\w]+$'
  'sys/env-var-name':
    pattern: '^[A-Za-z0-9_]+$'
  'word':
    type: 'string'
    pattern: '^[-\\w]+$'
