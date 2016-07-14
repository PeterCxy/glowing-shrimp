EventEmitter = require 'events'
client = require './weechat/connection.coffee'
Protocol = require './weechat/protocol.js'

class WeeChat extends EventEmitter
  constructor: ->
    @conn = null
    @retry = false

  setParams: (hostname, port, password, ssl) ->
    @hostname = hostname
    @port = port
    @password = password
    @ssl = ssl

  connect: ->
    @emit 'clearAll'
    @conn = client.connect @hostname, @port, @password, @ssl, =>
      @retry = true
      @emit 'connect'
    @setupConnection()

  reconnect: ->
    if @retry
      @connect()

  setupConnection: ->
    @conn.on 'error', (err) =>
      @emit 'error', err
      @reconnect()
    @conn.on 'close', =>
      @emit 'close'
      @reconnect()

module.exports = new WeeChat