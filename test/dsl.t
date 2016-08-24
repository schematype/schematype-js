#!/usr/bin/env coffee

require '../ext/test-more-js/lib/test/more'
require '../lib/schematype/schema'

make_stp = (data)->
  stp =
    '-name': "/test"
    '-desc': "Schema for unit testing"
    '-spec': "schematype.org/v0.0.1"
    '-from': "github:schematype/type/#master"
  _.extend stp, data

dump = (data)->
  (require 'js-yaml').dump data
  return 42

data = load_yaml read_file 'test/dsl.yaml'
for test in data
  schema1 = new SchemaType.Schema
  schema1.new_from_data make_stp test.dsl
  schema2 = new SchemaType.Schema
  schema2.new_from_data make_stp test.exp
  Is dump(schema1), dump(schema2),
    "DSL and Explicit input are equivalent"

done_testing()
