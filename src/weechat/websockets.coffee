{Protocol} = require './protocol.js'
protocol = new Protocol
EventEmitter = require 'events'
Promise = require 'bluebird'

module.exports = class WebSocketWrapper extends EventEmitter
  constructor: ->
    super
    @ws = null
    @curId = 0
    @callbacks = {}

  connect: (url, properties) ->
    @url = url
    @ws = new WebSocket @url
    for k, v of properties
      @ws[k] = v

    if @ws.onmessage?
      _onmessage = @ws.onmessage
      @ws.onmessage = =>
        _onmessage.apply this, arguments
        @onMessage.apply this, arguments
    else
      @ws.onmessage = @onMessage

  getCallbackId: ->
    if @curId >= 1000
      @curId = 0
    @curId++
    return @curId

  createCallback: (cb) ->
    new Promise (resolve, reject) =>
      cbId = @getCallbackId()
      @callbacks[cbId] =
        time: new Date
        cb:
          id: cbId
          resolve: resolve
          reject: reject
      cb @callbacks[cbId].cb

  send: (msg) ->
    @createCallback (cb) =>
      message = protocol.setId cb.id, msg
      @ws.send message

  onMessage: (event) =>
    message = protocol.parse event.data
    if @callbacks[message.id]?
      @callbacks[message.id].cb.resolve message
      delete @callbacks[message.id]
    else
      @emit 'message', message