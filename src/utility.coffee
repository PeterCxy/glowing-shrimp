Promise = require 'bluebird'
moment = require 'moment'
{Protocol} = require './weechat/protocol.js'

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

# Colors
materialColors =
  'default': '#757575'
  'black': '#000000'
  'darkgray': '#212121'
  'red': '#d32f2f'
  'lightred': '#f44336'
  'green': '#388e3c'
  'lightgreen': '#4caf50'
  'brown': '#795548'
  'yellow': '#ff6f00'
  'blue': '#2196f3'
  'lightblue': '#03a9f4'
  'magenta': '#e91e63'
  'lightmagenta': '#ec407a'
  'cyan': '#0097a7'
  'lightcyan': '#00acc1'
  'gray': '#757575'
  'white': '#d32f2f' # Do not use white in a light theme

# Get color of nickname from a list of tags
Handlebars.registerHelper 'nickColor', (tags) ->
  return materialColors['default'] if not tags? or tags.length is 0
  for tag in tags
    if tag.startsWith 'prefix_nick_'
      color = tag.replace 'prefix_nick_', ''
      return materialColors[color] if materialColors[color]?
  return materialColors['default']

# Get nickname from a list of tags
Handlebars.registerHelper 'getNick', (tags) ->
  return '???' if not tags? or tags.length is 0
  for tag in tags
    if tag.startsWith 'nick_'
      return tag.replace 'nick_', ''
  return tags[0]

# Convert raw text to rich text
Handlebars.registerHelper 'raw2rich', (raw) ->
  res = ''
  attrs = Protocol.rawText2Rich raw
  attrs.forEach (it) ->
    res += "<span style=\"#{"color: #{materialColors[it.fgColor.name]};" if it.fgColor?}\">#{it.text}</span>"
  return new Handlebars.SafeString res

# Hash code extension
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

module.exports =
  http: http
  readStream: readStream
  getString: getString