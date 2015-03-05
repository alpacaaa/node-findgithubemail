
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
    .then (data) ->
      return false unless data.email

      best_guess: data.email
      gravatar_match: true
      alternatives: []



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


  find_gravatar: (username) ->
    @github_request "users/#{username}"
    .then (data) ->
      data.gravatar_id


  find: (username) ->

    profile_email = null

    promise = new Promise (resolve, reject) =>

      @find_profile_email username
      .then (data) ->
        return resolve data if data

      .then =>
        return if promise.isFulfilled()

        @find_activity_emails username

      .then (emails) =>
        return if promise.isFulfilled()

        unless emails.length
          return reject new Error("No emails found")

        Promise.props
          emails: emails.map (item) -> item.email
          gravatar: @find_gravatar username

      .then (data) =>
        return if promise.isFulfilled()

        best_guess = data.emails.filter (email) =>
          @md5(email) == data.gravatar

        if best_guess.length == 1
          best_guess = best_guess.pop()
        else
          best_guess = data.emails[0]

        alternatives = data.emails.filter (item) ->
          item != best_guess

        gravatar_match = data.gravatar == @md5(best_guess)


        resolve
          best_guess: best_guess
          alternatives: alternatives
          gravatar_match: gravatar_match

      .catch (error) ->
        reject error
