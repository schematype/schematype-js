_ = require 'lodash'

class global.TestMore
  constructor: ->
    @plan = 0
    @run = 0
    @bail = false

  next: ->
    ++@run

  pass: (label='')->
    label = " - #{label}" if label
    @say "ok #{@next()}#{label}"
  fail: (label='')->
    label = " - #{label}" if label
    @say "not ok #{@next()}#{label}"
    if @bail
      @say "Bail out!"
      process.exit 255

  say: (msg)->
    process.stdout.write "#{msg}\n"
  nay: (msg)->
    process.stderr.write "#{msg}\n"

_.extend global,
  plan: ({tests, skip_all})->
    if skip_all
      TestMore.say "1..0 # SKIP #{skip_all}"
      process.exit 0
    tests or throw "Usage: plan tests: <number>"
    TestMore.plan = tests
    TestMore.say "1..#{tests}"
  done_testing: (plan)->
    plan ||= TestMore.run
    TestMore.say "1..#{plan}"

  pass: (label='')->
    TestMore.pass label
  fail: (label='')->
    TestMore.fail label

  ok: (test, label='')->
    if test
      pass label
    else
      fail label
      diag "  Failed test '#{label}"

  Is: (got, want, label='')->
    if got == want
      pass label
    else
      fail label
      diag """
        Failed test '#{label}'
               got: '#{got}'
          expected: '#{want}'
      """
  isnt: (got, want, label='')->
    if got != want
      pass label
    else
      fail label
  like: (got, want, label='')->
    if got.match want
      pass label
    else
      fail label
      diag """
                        '#{got}'
          doesn't match '#{want}'
      """
  unlike: (got, want, label='')->
    if not got.match want
      pass label
    else
      fail label

  diag: (msg)->
    msg = '# ' + msg.replace /\n/g, "\n# "
    TestMore.nay msg
  note: (msg)->
    msg = '# ' + msg.replace /\n/g, "\n# "
    TestMore.say msg

  BAIL_OUT: (msg='No reason given.')->
    TestMore.say "Bail out!  #{msg}"
    process.exit 255
  BAIL_ON_FAIL: ()->
    TestMore.bail = true

  # Replace global class with global singleton:
  TestMore: new TestMore
