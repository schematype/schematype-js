require '../schematype'

class global.SchemaType.Output
  name: ''
  file: ''
  type: ''
  url: ''

  constructor: (name)->
    @name = name
    if name.match /^https?:\/\//
      @url = name
    else
      @file = name
    if m = name.match /\.(\w{3,4})$/
      @type = m[1]

  write: (string)->
    if @file
      write_file @file, string
    else if @url
      error "Writing output to url not supported: '#{@url}'"
