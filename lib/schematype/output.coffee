require '../schematype'

class global.SchemaType.Output
  type: ''

  constructor: (file)->
    @file = file
    if m = file.match /\.(\w{3,4})$/
      @type = m[1]

  write: (string)->
    write_file @file, string
