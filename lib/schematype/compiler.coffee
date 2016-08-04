require '../schematype/base'
require '../schematype/schema'
require '../schematype/document'

class global.SchemaType.Compiler extends SchemaType.Base
  run: ->
    while @next_io 'stp', 'stpx'
      if @input.type != 'stp'
        error "Can only compile .stp files"

      schema = new SchemaType.Schema input: @input
      document = new SchemaType.Document schema: schema
      @output.write JSON.stringify document

      if @output.file != '-'
        say "Compiled '#{@input.file}' to '#{@output.file}'"
