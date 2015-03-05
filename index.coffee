
crypto  = require 'crypto'
Promise = require 'bluebird'
request = require 'request-promise'



module.exports = do ->

  access_token: null


  github_request: (path) ->
    url = "https://api.github.com/#{path}"
    if @access_token
      url += "?access_token=#{@access_token}"

    @request url


  request: (url) ->
    request
      url: url
      json: true
      headers:
        'User-Agent': 'Just a stalker, nevermind'


  md5: (email) ->
    shasum = crypto.createHash 'md5'
    shasum.update email
    shasum.digest 'hex'


  find_emails: (res) ->
    emails = res
    .filter (event) ->
      event.payload?.commits?.length
    .map (event) ->
      event.payload.commits
    .map (commits) ->
      commits.map (c) ->
        c.author?.email

    [].concat.apply [], emails



  find_profile_email: (username) ->
    @github_request "users/#{username}"
    .then (data) -> data?.email



  aggregate: (emails) ->
    ret = emails.reduce ((acc, item) ->
      acc[item] ||= { email: item, count: 0 }
      acc[item].count++
      acc
    ), {}

    Object.keys(ret).map (key) -> ret[key]


  find_activity_emails: (username) ->
    @github_request "users/#{username}/events/public"
    .then (activity) =>
      emails = @find_emails activity
      @aggregate(emails).sort (a, b) ->
        if a.count > b.count then -1 else 1


  find: (username) ->

    profile_email = null

    new Promise (resolve, reject) =>

      promise = @find_profile_email username
      .then (email) =>
        return unless email
        promise.cancel()

        resolve
          best_guess: email
          alternatives: []

      .then =>
        @find_activity_emails username

      .then (emails) =>
        unless emails.length
          return reject new Error("No emails found")

        emails.map (item) -> item.email

      .then (emails) =>
        best_guess = emails[0]
        alternatives = emails.splice(1)


        resolve
          best_guess: best_guess
          alternatives: alternatives


      .cancellable()

      .catch Promise.CancellationError, (->)

      .catch (error) ->
        reject error
