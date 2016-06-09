require './prelude'
fs = require 'fs'

class global.SchemaType
  version: '0.0.3'

  run: (args)->
    @get_opt args
    @read_input()
    @load_input()
    @lint_input()
    @write_output()

  read_input: ->
    @input_file = @args['path/to/input/file'][0]
    if @input_file == '-'
      @input_file = '<stdin>'
      @input = fs.readFileSync('/dev/stdin').toString()
    else
      @input = fs.readFileSync(@input_file).toString()

    if @args.from?
      @input_format = @args.from
    else if m = @input_file.match /\.(yaml|json|csv|tsv)$/i
      @input_format = m[1]
    # TODO improve heuristics:
    else if @input.match /^\s*[\{\[]/
      @input_format = 'json'
    else if @input.match /^---\n/
      @input_format = 'yaml'
    else
      error "Can't guess input format. Use '--from=...'."

  load_input: ->
    try
      switch @input_format
        when 'yaml'
          @data = require('js-yaml').load @input
        when 'json'
          @data = JSON.parse @input
        when 'csv'
          error "Format 'csv' support not yet implemented."
        when 'tsv'
          error "Format 'tsv' support not yet implemented."
        else
          error "Unknown input format '#{input_format}'."
    catch e
      error "The input from '#{@input_file}' is not valid '#{@input_format}'."

  lint_input: ->
    return unless @args.schema?
    error 'Schema validation is not yet implemented'

  write_output: ->
    return unless @args.to?

    switch @args.to
      when 'yaml'
        out require('js-yaml').dump @data
      when 'json'
        out JSON.stringify @data, null, 2
      when 'csv'
        error "Output 'csv' support not yet implemented."
      when 'tsv'
        error "Output 'tsv' support not yet implemented."
      else
        error "Unknown output format '#{args.to}'."

  get_opt: (args)->
    argparse = require 'argparse'
    ArgumentParser = argparse.ArgumentParser
    parser = new ArgumentParser
      prog: 'schematype'
      usage: 'schematype [<option>...] <input-file>'
      version: "schematype - version #{SchemaType::version}"
      addHelp: true
      description: 'YAML Validator, Linter, Formatter.'
#       epilog: 'If called without options, `schematype` will ...'
    parser.addArgument \
      [ '-s', '--schema' ],
      action: 'store'
      metavar: '<file>'
      help: "Schema file to use. See 'schematype' documentation."
    parser.addArgument \
      [ '-t', '--to' ],
      action: 'store'
      metavar: '<format>'
      choices: ['yaml', 'json', 'csv', 'tsv']
      help: "Output format (yaml json csv tsv)."
    parser.addArgument \
      [ '-f', '--from' ],
      action: 'store'
      metavar: '<format>'
      choices: ['yaml', 'json', 'csv', 'tsv']
      help: "Explicit input format (yaml json csv tsv)."
    parser.addArgument \
      [ '-q', '--quiet' ],
      action: 'storeTrue'
      help: "Suppress validation output."
    parser.addArgument \
      'path/to/input/file',
      nargs: '1'
      help: "The (YAML/JSON/etc) input data file. '-' for stdin."
#     parser.addArgument \
#       [ '<program arguments>' ],
#       nargs: '...'
#       help: "The program's arguments."
    @args = parser.parseArgs(args)
