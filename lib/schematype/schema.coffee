require '../schematype/base'

class global.SchemaType.Schema extends SchemaType.Base
  main: ->
    @type[@meta.name]

  constructor: ({@input})->
    if @input?
      @new_from_input @input
    else
      error "invalid input to Schema constructor"

  new_from_input: (input)->
    if input.type == 'stp'
      @new_from_stp input.read()
    else
      error "Can only construct Schema from '.stp' file"

  new_from_stp: (stp)->
    @data = load_yaml stp

    @make_meta()

    @type = {}

    name = @meta.name
    if m = name.match /^\/[-\w]+$/
      @make_type name, @data
    else
      die "Can't handle -name == '#{name}'"

    # Delete internals so object is a compilation tree:
    delete @input
    delete @data

  make_meta: ->
    @meta = {}
    @set_name()
    @set_desc()
    @set_spec()
    @set_from()

  make_type: (name, data)->
    @type[name] = new Type
    @type[name].from_stp data, @type

  set_name: ->
    name = @meta.name = @data['-name'] || null
    delete @data['-name']
    name? or
      @error "the '-name' field is required"
    name.match(/^\//) or
      @error "the '-name' field must begin with '/'"

  set_desc: ->
    @meta.desc = @data['-desc'] || null
    delete @data['-desc']

  set_spec: ->
    spec = @meta.spec = @data['-spec'] || null
    delete @data['-spec']
    spec? or
      @error "the '-spec' field is required"
    spec == 'schematype.org/v0.0.1' or
      @error "the '-spec' field must be set to 'schematype.org/v0.0.1'"

  set_from: ->
    from = @meta.from = @data['-from'] || null
    delete @data['-from']
    if typeof(from) == 'string'
      @meta.from = '%': from.replace /(.*\/)/, '$1%'

  error: (msg)->
    error "In '#{@input.name}' #{msg}"

class Type
  from_stp: (data, types)->
    # say "from_stp #{JSON.stringify data}"
    for key, val of data
      if m = key.match /^\+(.*)/
        delete data[key]
        name = m[1]
        if m = name.match /^\/[-\w]+$/
          types[name] = new Type
          types[name].from_stp val, types
        else
          die "Unsupported type name '#{name}'"

    if @is_map data
      @make_map data, @
    else
      @make_value data, null, @

  make_value: (data, opt=true, value={})->
    value.need = true if not opt
    data = data.replace /\.\s+/, ''
    while data.length
      if m = data.match /^\+([-\/\w\|\+]+)(?:\[([\*\+\!]+)\])?(\?)?/
        value.type = m[1]
        if value.type.match /\|/
          value.type = value.type.split '|'
        if m[2]?.match /\*/
          value.list = true
          value.mini = 0
        if m[2]?.match /\+/
          value.list = true
          value.mini = 1
        value.uniq = true if m[2]?.match /\!/
        value.null = true if m[3]?
        data = data[(m[0].length)..]
      else if m = data.match /^(\/\S+)/
        value.type = 'str'
        value.like = m[1]
        data = data[(m[0].length)..]
      else if m = data.match /^\[(.*)\]/
        value.type = 'str'
        value.enum = m[1].split /,\s*/
        data = data[(m[0].length)..]
      else
        die "Can't handle value '#{data}'"
    return value

  make_map: (data, target)->
    hash = target.hash = []

    for key, val of data
      delete data[key]
      if key == '-base'
        hash.push ['base', val.replace /^\+/, '']
      else if key == '-list'
        target.list = true
        target.mini = val
      else if key == '-deny'
        target.deny = val
      else if m = key.match /^([-\w\/]+)(\[\+\])?(\?)?$/
        [pair, key] = @make_pair key, val
        hash.push pair
      else if m = key.match /^\(\+(.*)\)/
        [pair, key] = @make_pair m[1] + '?', val
        hash.push ['type', pair]
      else
        die "Unsupported key '#{key}'"
      if pair[key]?.list == false
        delete pair[key].list

  make_pair: (key, node)->
    m = key.match /^([-\w\/]+)(\[\+\])?(\?)?$/
    # xxx key if @xyz?
    name = m[1]
    list = m[2]?
    opt = Boolean m[3]?
    pair = {}
    if _.isString node
      pair[name] = @make_value node, opt
    else if _.isPlainObject node
      val = pair[name] = list: list
      @make_map node, val
    else
      die "Unsupported value '#{node}'"
    return [pair, name]

  is_map: (data)->
    return false unless _.isPlainObject data
    for key of data
      return true if key.match /^(-base|[-\w]+\??)$/
    return false
