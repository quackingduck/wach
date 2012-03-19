assert = require 'assert'
support = require '../src/support'

suite 'parseArgs'

test '--help', -> assert.ok support.parseArgs(['--help']).help?
test '-h', -> assert.ok support.parseArgs(['-h']).help?

test '--version', -> assert.ok support.parseArgs(['--version']).version?
test '-v', -> assert.ok support.parseArgs(['-v']).version?

test 'make', ->
  {command} = support.parseArgs ['make']
  assert.equal command, 'make'

test 'coffee foo.coffee', ->
  {command, only, except} = support.parseArgs ['coffee', 'foo.coffee']
  assert.equal command, 'coffee foo.coffee'

test '--only *.c, make', ->
  {command, only, except} = support.parseArgs ['--only','*.c,','make']
  assert.equal command, 'make'
  assert.deepEqual only, ['*.c']

test '-o *.c, make', ->
  {command, only, except} = support.parseArgs ['-o','*.c,','make']
  assert.equal command, 'make'
  assert.deepEqual only, ['*.c']

test '--except *.o, make', ->
  {command, only, except} = support.parseArgs ['--except','*.o,','make']
  assert.equal command, 'make'
  assert.deepEqual except, ['*.o']

test '-e *.o, make', ->
  {command, only, except} = support.parseArgs ['-e','*.o,build/*','make']
  assert.equal command, 'make'
  assert.deepEqual except, ['*.o', 'build/*']

test '-o *.coffee, -e examples/*, make', ->
  {command, only, except} = support.parseArgs ['-o', '*.coffee,', '-e', 'examples/*,', 'make']
  assert.equal command, 'make'
  assert.deepEqual only, ['*.coffee']
  assert.deepEqual except, ['examples/*']

# reverse order of above
test '-e examples/*, -o *.coffee, make', ->
  {command, only, except} = support.parseArgs ['-e', 'examples/*,', '-o', '*.coffee,', 'make']
  assert.equal command, 'make'
  assert.deepEqual only, ['*.coffee']
  assert.deepEqual except, ['examples/*']

test '-o foo', ->
  {command, only, except} = support.parseArgs ['-o','foo']
  assert.deepEqual only, ['foo']
  assert not command?

# ---

{matchesGlobs} = require '../src/support'

suite "matchesGlobs"

test "empty list always false", ->
  assert not matchesGlobs "foo.txt", []

test "exact match", ->
  assert matchesGlobs "foo.txt", ['foo.txt']

test "match *", ->
  assert matchesGlobs "foo.txt", ['*']

test "match * plus extension", ->
  assert matchesGlobs "foo.txt", ['*.txt']

test "match second pattern", ->
  assert matchesGlobs "foo.txt", ['wontmatch', '*.txt']
