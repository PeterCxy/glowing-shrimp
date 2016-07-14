Promise = require 'bluebird'

# Promisify http methods
http = require 'http'
http.getAsync = (url) ->
  new Promise (resolve, reject) ->
    http.get url, (res) ->
      resolve res
    .on 'error', (e) ->
      reject e

readStream = (stream) ->
  new Promise (resolve, reject) ->
    str = ''
    stream.on 'data', (buf) ->
      str += buf.toString()
    stream.on 'end', ->
      resolve str
    stream.on 'error', (e) ->
      reject e

# Handlebars language helper
lang = require './lang/en_US.coffee' # TODO: Allow switching languages
Handlebars = require 'handlebars'

Handlebars.registerHelper 'lang', (name) ->
  getString name

getString = (name) ->
  return lang[name]

module.exports =
  http: http
  readStream: readStream
  getString: getString