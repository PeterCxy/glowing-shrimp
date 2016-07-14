Promise = require 'bluebird'
moment = require 'moment'

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

Handlebars.registerHelper 'dateFormat', (date, format) ->
  moment(date).format(format)

Handlebars.registerHelper 'firstChar', (str) ->
  str[0...1].toUpperCase()

getString = (name) ->
  return lang[name]

# Avatar colors
avatarColors = [
  '#f44336', '#e91e63', '#e91e63',
  '#3f51b5', '#009688', '#795548',
  '#607d8b'
]

hashCodeCache = {}
String::hashCode = ->
  hash = 0
  return hash if @length is 0
  return hashCodeCache[@] if hashCodeCache[@]
  for char in @
    hash = ((hash << 5) - hash) + char.charCodeAt 0
    hash = hash & hash
  hashCodeCache[@] = hash
  return hash

Handlebars.registerHelper 'colorFor', (str) ->
  avatarColors[Math.abs(str.hashCode()) % avatarColors.length]

module.exports =
  http: http
  readStream: readStream
  getString: getString