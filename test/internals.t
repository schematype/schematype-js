#!/bin/bash

source test/setup
use Test::More

initialize

jyj test/manifest/manifest.stps | jyj > $TMP/manifest.stps
TEST_SCHEMA=1 stp export -i test/manifest/manifest.stp -o $TMP/manifest.schema
output=$(diff -u $TMP/manifest.stps $TMP/manifest.schema || true)
if [[ -z $output ]]; then
  pass 'Load SchemaType.Schema object'
else
  fail 'Load SchemaType.Schema object'
  diag "$output"
  BAIL_OUT
fi

jyj test/manifest/manifest.stpx | jyj > $TMP/manifest.stpx
TEST_DOC=1 stp export -i test/manifest/manifest.stp -o $TMP/manifest.doc
output=$(diff -u $TMP/manifest.stpx $TMP/manifest.doc || true)
if [[ -z $output ]]; then
  pass "Load SchemaType.Document object"
else
  fail "Load SchemaType.Document object"
  diag "$output"
  BAIL_OUT
fi

TEST_EXPORT=1 stp export -i test/manifest/manifest.stp -o $TMP/manifest.jsc
output=$(diff -u test/manifest/manifest.jsc $TMP/manifest.jsc || true)
if [[ -z $output ]]; then
  pass "Export SchemaType.Document object"
else
  fail "Export SchemaType.Document object"
  diag "$output"
  BAIL_OUT
fi

done_testing

finalize
