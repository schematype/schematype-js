#!/bin/bash

source test/setup
use Test::More

initialize

file=$TMP/manifest.jsc
out=$(stp export -i test/manifest/manifest.stp -o $file 2>&1 || true)

like "$out" \
   "Exported 'test/manifest/manifest.stp' to '$PWD/tmp/manifest.jsc'" \
   "Output is correct"

ok "`[[ -f $file ]]`" \
   "manifest.jsc created"

ok "`jsonlint $file &>/dev/null`" \
   "JSON is valid"

done_testing

finalize
