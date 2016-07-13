Handlebars = require 'handlebars'
{http, readStream} = require './utility.coffee'

# Base class for all components
module.exports = class Component
  constructor: (@element) ->
    @template = null

  initialize: ->
    http.getAsync @templateUrl
      .then readStream
      .then (t) => @template = Handlebars.compile t