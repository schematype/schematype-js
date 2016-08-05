require '../schematype/base'
require '../schematype/get-opt'

class global.SchemaType.Command extends SchemaType.Base
  constructor: ->

  run: (argv)->
    args = (new SchemaType.GetOpt).get_opt argv
    command = args.command

    if command == 'help'
      if args['<command>'].length == 0
        exec 'man', ['schematype']
      else
        exec './bin/stp', [args['<command>'][0], '-h']
    else
      (new (@require_command_module command)(args)).run()
