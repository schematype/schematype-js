require '../schematype/base'

class global.SchemaType.Document extends SchemaType.Base
  main: ->
    @type[@meta.name]

  constructor: ({@input, @schema})->
    if @schema
      @new_from_schema()
    else if @input?
      @new_from_input()
    else
      error "invalid input to Schema constructor"

    delete @input
    delete @schema

  new_from_input: ->
    if @input.type == 'stpx'
      @new_from_stpx @input.read()
    else
      error "Can only construct Document from '.stpx' file"

  new_from_stpx: (input)->
    _.extend @, JSON.parse input

  new_from_schema: ->
    @meta =
      name: @schema.meta.name
      desc: @schema.meta.desc
      spec: @schema.meta.spec
    @type = {}
    name = @schema.meta.name
    data = @schema.type[name]
    @expand_type data
    @type[name] = data

  expand_type: (data)->
    return unless data.hash?
    hash = data.hash
    i = 0
    while i < hash.length
      elem = hash[i]
      if _.isArray elem
        if elem[0] == 'base'
          base = @schema.type[elem[1]]
          @expand_type base
          base = base.hash
          base = @clone base
          hash.splice i, 1, base...
          i = i + base.length - 1
      else
        key = _.keys(elem)[0]
        val = elem[key]
        if val.hash?
          @expand_type val
        else if val.type?.match /^\//
          elem[key] = @clone @schema.type[val.type]
      i++

  clone: (data)->
    JSON.parse JSON.stringify data
