#!/bin/bash

set -e

[[ -f bin/stp ]] || { echo 'Wrong cwd'; exit 1; }
TMP=$PWD/tmp
rm -fr $TMP
mkdir $TMP
export PATH=$PWD/bin:$PATH

# set -x

jyj test/manifest/manifest.stps | jyj > $TMP/manifest.stps
TEST_SCHEMA=1 stp export -i test/manifest/manifest.stp -o $TMP/manifest.schema
output=$(diff -u $TMP/manifest.stps $TMP/manifest.schema || true)
if [[ -n $output ]]; then
  echo "Failed to load SchemaType.Schema object:"
  echo "$output"
  exit 1
fi

jyj test/manifest/manifest.stpx | jyj > $TMP/manifest.stpx
TEST_DOC=1 stp export -i test/manifest/manifest.stp -o $TMP/manifest.doc
output=$(diff -u $TMP/manifest.stpx $TMP/manifest.doc || true)
if [[ -n $output ]]; then
  echo "Failed to load SchemaType.Document object:"
  echo "$output"
  exit 1
fi

TEST_EXPORT=1 stp export -i test/manifest/manifest.stp -o $TMP/manifest.jsc
output=$(diff -u test/manifest/manifest.jsc $TMP/manifest.jsc || true)
if [[ -n $output ]]; then
  echo "Failed to export SchemaType.Document object:"
  echo "$output"
  exit 1
fi


echo PASS

rm -fr $TMP
