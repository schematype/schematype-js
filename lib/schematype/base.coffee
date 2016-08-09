require '../schematype'

class global.SchemaType.Base
  constructor: (args)->
    @args = args

  inputs: []
  schema: null
  input: null
  output: null
  to: null
  from: null
  need: []

  commands:
    compile:
      clas: 'Compiler'
      desc: 'Compile a .stp file to a .stpx file'
      args: ['input', 'output', 'inputs']
    convert:
      clas: 'Converter'
      desc: 'XXX Convert a data file from one format to another'
      args: ['to', 'from', 'input', 'output', 'inputs']
    create:
      clas: 'Creator'
      desc: 'XXX Create a .stp file from valid data files'
      args: ['schema', 'inputs']
    export:
      clas: 'Exporter'
      desc: 'Export .stp to other formats'
      args: ['to', 'input', 'output', 'inputs']
    format:
      clas: 'Formatter'
      desc: 'XXX Reformat a .stp file to a desired style'
      args: ['input', 'output', 'layout', 'inputs']
    generate:
      clas: 'Generator'
      desc: 'XXX Generate code from a schema file'
      args: []
    import:
      clas: 'Importer'
      desc: 'XXX Import .stp from other formats'
      args: ['schema', 'inputs']
    validate:
      clas: 'Validator'
      desc: 'Validate one or more data files against a schema'
      args: ['schema', 'inputs']

  require_command_module: (command)->
    clas = @commands[command].clas or
      throw "Unknown command #{command}"
    module = clas.toLowerCase()
    require "./#{module}"
    SchemaType[clas]

  next_io: (iext, oext)->
    require '../schematype/input'
    require '../schematype/output'
    if not @io?
      @io = []
      if @args.input?
        if @args.output?
          @io.push [
            new SchemaType.Input(@args.input),
            new SchemaType.Output(@args.output),
          ]
        else
          @io.push [
            new SchemaType.Input(@args.input),
            new SchemaType.Output('-'),
          ]
      else if @args.inputs?
        for input in @args.inputs
          if iext? and oext? and input.match ///\.#{iext}$///
            output = input.replace ///\.#{iext}$///, ".#{oext}"
          else
            output = '-'
          @io.push [
            new SchemaType.Input(input),
            new SchemaType.Output(output),
          ]

    if io = @io.shift()
      [@input, @output] = io
    else
      false
