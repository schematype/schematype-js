require '../schematype/base'

class global.SchemaType.GetOpt extends SchemaType.Base
  constructor: ->
  get_opt: (argv)->
    # See: https://www.npmjs.com/package/argparse
    argparse = require 'argparse'
    ArgumentParser = argparse.ArgumentParser
    @parser = new ArgumentParser
      prog: 'stp'
      version: "stp - version #{SchemaType::version}"
      addHelp: true
      description: 'SchemaType Compiler, Validator, Translator, Formatter and Generator'
      usage: 'stp <command> [<option>...] [<input_file>...]'
      epilog: "Use 'stp help' to see the full stp documentation. " +
              "Use 'stp <command> -h' for help with a command."

    @subparsers = @parser.addSubparsers
      title: "Commands"
      dest: 'command'

    @add_command 'compile'
    @add_command 'convert'
    @add_command 'create'
    @add_command 'import'
    @add_command 'export'
    @add_command 'format'
    @add_command 'generate'
    @add_command 'validate'
    @add_help()
    # @add_version()

    argv = ['-h'] unless argv.length
    args = @parser.parseArgs(argv)
    args.inputs = args['<input-file>']
    delete args['<input-file>']

    if args.input? and args.inputs.length > 0
      error "Use '--input=' OR <input-file> list; not both"

    if not args.from? and args.input?
      if m = args.input.match /\.(ya?ml|json|csv|stpx?|jsc)$/i
        args.from = m[1]
        args.from = 'yaml' if args.from == 'yml'

    if not args.to? and args.output?
      if m = args.output.match /\.(ya?ml|json|csv|stpx?|jsc)$/i
        args.to = m[1]
        args.to = 'yaml' if args.to == 'yml'

    return args

  add_help: ->
    command = @subparsers.addParser 'help',
      help: "Get help on stp or a specific command"
      usage: "stp help [<command>]"
    @add_cmd_name command

  add_command: (name, desc, args)->
    command = @subparsers.addParser name,
      help: @commands[name].desc
      usage: "stp #{name} [<option>...] [<input_file>...]"
      # addHelp: false
    for arg in @commands[name].args
      (add_option = @["add_#{arg}"])? ||
        die "#{arg} is not an option"
      add_option command

  add_input: (command)->
    command.addArgument [ '-i', '--input' ],
      action: 'store'
      metavar: '<file>'
      help: "Input file to use."

  add_output: (command)->
    command.addArgument [ '-o', '--output' ],
      action: 'store'
      metavar: '<file>'
      help: "Output file to use."

  add_from: (command)->
    command.addArgument [ '-f', '--from' ],
      action: 'store'
      metavar: '<format>'
      help: "Format of input."

  add_to: (command)->
    command.addArgument [ '-t', '--to' ],
      action: 'store'
      metavar: '<format>'
      help: "Format of input."

  add_schema: (command)->
    command.addArgument [ '-s', '--schema' ],
      action: 'store'
      metavar: '<file>'
      help: "SchemaType ('.stp') file to use."

  add_layout: (command)->
    command.addArgument [ '-l', '--layout' ],
      action: 'store'
      choices: ['compact', 'explicit']
      metavar: '<layout>'
      help: "Layout format for output: 'compact', 'explicit'."

  add_inputs: (command)->
    command.addArgument '<input-file>',
      nargs: '...'
      help: "The input file(s) for command. '-' for stdin."

  add_cmd_name: (command)->
    command.addArgument '<command>',
      nargs: '...'
      help: "Name of stp command."
