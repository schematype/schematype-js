require '../schematype'

class global.SchemaType.Input
  type: ''

  constructor: (file)->
    @file = file
    if m = file.match /\.(\w{3,4})$/
      @type = m[1]

  read: ->
    read_file @file
