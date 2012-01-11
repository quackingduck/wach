assert = require 'assert'
cli = require('../src/cli')._test

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
