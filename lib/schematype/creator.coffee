require '../schematype/base'
require '../schematype/output'

# This is currently not implemented, except enough to test `stp create` CLI
# permutations.
class global.SchemaType.Creator extends SchemaType.Base
  run: ->
    error "'stp create' command requires at least one input file" \
      unless @args.inputs.length

    while @next_io()
      @input.read()

    output = new SchemaType.Output @args.output
    output.write '''
      This is dummy output
      for the create command.
      '''
