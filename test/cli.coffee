assert = require 'assert'
cli = require('../src/cli')._test

suite "passesGlobFilters", ->

  test "empty filters always pass", ->
    assert cli.passesGlobFilters "foo.txt", []

  test "exact match", ->
    assert cli.passesGlobFilters "foo.txt", ['foo.txt']

  test "match *", ->
    assert cli.passesGlobFilters "foo.txt", ['*']

  test "match * plus extension", ->
    assert cli.passesGlobFilters "foo.txt", ['*.txt']

  test "match second pattern", ->
    assert cli.passesGlobFilters "foo.txt", ['wontmatch', '*.txt']


suite "parseArgs - 'only' (--only,-o)", ->

  test "one pattern", ->
    assert.deepEqual cli.parseArgs(['-o', 'foo.txt']).only, ['foo.txt']

  test "two patterns", ->
    assert.deepEqual cli.parseArgs(['-o', 'foo,bar']).only, ['foo','bar']

  test "one pattern with trailing comma", ->
    assert.deepEqual cli.parseArgs(['-o', '*.txt']).only, ['*.txt']
