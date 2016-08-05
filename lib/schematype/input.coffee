require '../schematype'

class global.SchemaType.Input
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

  read: ->
    if @file
      read_file @file
    else if @url
      require('sync-request')('GET', @url).getBody()

