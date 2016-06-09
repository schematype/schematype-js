_ = require 'lodash'

_.extend global,
  out: (string)->
    process.stdout.write String string
  err: (string)->
    process.stderr.write String string
  exit: (rc=0)->
    process.exit rc

  say: (string...)->
    out "#{string.join ' '}\n"
  warn: (string...)->
    string = String string.join ' '
    if not string.match /\n/
      string = "Warning: #{string}\n"
    err string
  error: (msg)->
    say "schematype error: #{msg}"
    exit 1
  die: (msg)->
    throw msg
  xxx: (data...)->
    console.dir(data)
    exit 1
  XXX: (data...)->
    yaml = require 'js-yaml'
    for elem in data
      say "---\n#{yaml.dump elem}"
    exit 1
