require '../schematype/base'
require '../schematype/input'
require '../schematype/schema'
require '../schematype/document'
require '../schematype/exporter'

class global.SchemaType.Validator extends SchemaType.Base
  run: ->
    if not @args.schema?
      error "Schema file required. Use '-s'"
    input = new SchemaType.Input @args.schema
    if input.type == 'stp'
      schema = new SchemaType.Schema input: input
      document = new SchemaType.Document schema: schema
      json = JSON.parse (new SchemaType.Exporter).to_json_schema document
    else if input.type == 'stpx'
      document = new SchemaType.Document input: input
      json = JSON.parse (new SchemaType.Exporter).to_json_schema document
    else if input.type == 'jsc'
      json = JSON.parse input.read()
    else if input.name.match /\.jsc\.yaml$/
      json = load_yaml input.read()
    else
      error "Invalid file extension for schema file"
    YAML = require 'js-yaml'
    Ajv = require 'ajv'
    ajv = new Ajv \
      allErrors: true
    validator = ajv.compile json
    while @next_io()
      out "Validating '#{@input.name}':"
      yaml = @input.read()
      try
        data = YAML.load yaml
      catch e
        say "\n* YAML error:"
        say ''
        continue

      if valid = validator data
        say " OK!"
      else
        say ''
        for err in validator.errors
          @analyze_error err
      say ''

  analyze_error: (error)->
    path = error.dataPath
    path = path.replace /\./g, '/'
    path = path.replace /\[([0-9]+)\]/g, '/$1'
    path ||= '/'
    if error.keyword == 'additionalProperties'
      if error.params.additionalProperty == 'declared-services'
        return say "* Contains IBM Bluemix extension: 'declared-services'"
      else
        return say "* '#{path}' has unknown key '#{error.params.additionalProperty}'"
    else if error.keyword == 'format'
      if error.params.format == 'uri'
        return say "* #{path} should be a URL"
    else if error.keyword == 'pattern'
      return say "* '#{path}': #{error.message}"
    else if error.keyword == 'type'
      return say "* '#{path}' has wrong type: #{error.message}"
    else if error.keyword == 'required'
      return say "* '#{path}' missing required key: #{error.message}"

    say "* Unrecognized error:\n#{require('js-yaml').dump error}"
