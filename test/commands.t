#!/bin/bash

source test/setup
use Test::More

initialize

run-cmd() {
  local command="$1"
  local command="${1//$'\n'/ }"
  local regex="$2"
  local rc=0
  output="$($command 2>&1)" || rc=$?
  ok $rc "Run command: '$command'"
  if [[ $rc -ne 0 ]]; then
    diag "$output"
  fi
  if [[ -n "$regex" ]]; then
    like "$output" "$regex" 'Output is correct'
  fi
}

run-bad-cmd() {
  local command="$1"
  local regex="$2"
  local rc=0
  output="$($command 2>&1)" || rc=$?
  [[ $rc -eq 0 ]] && rc=1 || rc=0
  ok $rc "Bad command: '$command'"
  if [[ -n "$regex" ]]; then
    like "$output" "$regex" "Error output looks correct"
  fi
}

dir='test/data'
out='test/output'
rm -fr "$out"
mkdir -p "$out"

#------------------------------------------------------------------------------
# `stp validate` test cases:
#------------------------------------------------------------------------------
# Run with zero input files:
run-bad-cmd 'stp validate -s test/manifest/manifest.stp' \
  'command requires at least one input file'

# Run with no schema file:
run-bad-cmd 'stp validate test/manifest/manifest.yml' \
  'Schema file required'

# Run with one input file:
run-cmd 'stp validate -s test/manifest/manifest.stp test/manifest/manifest.yml' \
  "Validating 'test/manifest/manifest.yml': OK"

# Run with multiple input files:
run-cmd 'stp validate -s test/manifest/manifest.stp test/manifest/manifest.yml test/manifest/manifest.yml'
is $(echo "$output" | wc -l) 3 'Got 3 output lines'

# Need CSV support:
# run "stp validate -s $dir/stuff.stp $dir/stuff.csv"


#------------------------------------------------------------------------------
# `stp create` test cases:
#------------------------------------------------------------------------------
stp="$out/schema.stp"

# Needs at least one input file:
run-bad-cmd "stp create" \
  "stp error: 'stp create' command requires at least one input file"

# Create new stp file from data files, write to stdout:
run-cmd "stp create $dir/x.yml $dir/y.yml" \
  'This is dummy output'

# Write new file to person.stp
run-cmd "stp create -o $stp $dir/x.yml $dir/y.yml"
ok "`[[ -e "$stp" ]]`" \
  "Created file '$stp'"
like "$(<$stp)" \
  'This is dummy output' \
  "'$stp' has correct output"

# Update existing stp file:
echo 'Original content' > $stp
run-cmd "stp create -s $stp -o $stp $dir/x.yml $dir/y.yml"
unlike "$(<$stp)" \
  'Original content' \
  "'$stp' content replaced"
like "$(<$stp)" \
  'This is dummy output' \
  "'$stp' has correct output"

# Make new stp file from old one:
echo 'Original content' > $stp
run-cmd "stp create -s $stp -o $stp.new $dir/x.yml $dir/y.yml"
is "$(<$stp)" \
  'Original content' \
  "'$stp' content left alone"
like "$(<$stp.new)" \
  'This is dummy output' \
  "'$stp.new' has correct output"

# Same as above but to stdout
echo 'Original content' > $stp
run-cmd "stp create -s $stp $dir/x.yml $dir/y.yml" \
  'This is dummy output'
is "$(<$stp)" \
  'Original content' \
  "'$stp' content left alone"

done_testing && exit

done_testing
