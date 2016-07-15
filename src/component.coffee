Handlebars = require 'handlebars'
{Promise} = require 'bluebird'
{templates} = require './templates_loader.coffee'

# Base class for all components
module.exports = class Component
  constructor: (@element) ->
    @template = null

  initialize: ->
    Promise.try =>
      templates[@templateUrl]
    .then (t) => @template = Handlebars.compile t