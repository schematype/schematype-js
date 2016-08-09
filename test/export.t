#!/bin/bash

source test/setup
use Test::More

initialize

file=$TMP/manifest.jsc
out=$(stp export -i test/manifest/manifest.stp -o $file 2>&1 || true)

is "$out" \
   "Exported 'test/manifest/manifest.stp' to '/Users/ingy/src/schematype/schematype-js/tmp/manifest.jsc'" \
   "Output is correct"

ok "`[[ -f $file ]]`" \
   "manifest.jsc created"

ok "`jsonlint $file &>/dev/null`" \
   "JSON is valid"

done_testing

finalize
