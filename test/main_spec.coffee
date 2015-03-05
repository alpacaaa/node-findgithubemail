
fs = require 'fs'
assert  = require 'assert'
Promise = require 'bluebird'

mod = require '../index.coffee'



json_file = (file) ->
  file = __dirname + '/' + file
  JSON.parse fs.readFileSync(file).toString()

# Poor men HTTP mocking
mod.request = (url) ->
  file = url.replace('https://', '')
  file = file.split('/').join('.')
  file = file.split('?').shift()

  data = json_file file
  Promise.resolve data



describe "Unit tests", ->

  test_emails = [
    'test2@gmail.com',
    'test2@gmail.com',
    'test2@hotmail.com',
    'test2@gmail.com',
    'test2@gmail.com',
    'test2@gmail.com',
    'test2@hotmail.com'
  ]


  it "should find available emails", ->
    input = json_file 'api.github.com.users.test2.events.public'
    assert.deepEqual mod.find_emails(input), test_emails


  it "should aggregate email addresses", ->
    assert.deepEqual mod.aggregate(test_emails), [
      { email: 'test2@gmail.com', count: 5 }
      { email: 'test2@hotmail.com', count: 2 }
    ]



describe "Find email for user", ->

  it "should return the public email address, if available", (done) ->

    mod.find 'test1'
    .then (result) ->
      assert.equal result.best_guess, 'test1@gmail.com'
      assert.ok !result.alternatives.length

      done()


  it "should search for email addresses in commits", (done) ->

    mod.find 'test2'
    .then (result) ->
      assert.equal result.best_guess, 'test2@gmail.com'
      assert.ok result.alternatives.length
      assert.ok 'test2@hotmail.com' in result.alternatives

      done()
