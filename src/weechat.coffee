EventEmitter = require 'events'
client = require './weechat/connection.coffee'
{Protocol} = require './weechat/protocol.js'

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
      @updateBuffers()
        .then => @conn.send Protocol.formatSync()
    @setupConnection()

  reconnect: ->
    if @retry
      console.log 'reconnecting'
      @connect()

  setupConnection: ->
    @conn.on 'error', (err) =>
      @emit 'error', err
      @reconnect()
    @conn.on 'close', =>
      @emit 'close'
      @reconnect()

  updateBuffers: ->
    @conn.send Protocol.formatHdata
      path: 'buffer:gui_buffers(*)'
      keys: ['number', 'name', 'title']
    .catch (err) => @emit 'error', err
    .then (msg) =>
      @emit 'bufferListUpdate', msg.objects[0].content

  fetchBufferLines: (id, num) ->
    @conn.send Protocol.formatHdata
      path: "buffer:0x#{id}/own_lines/last_line(-#{num})/data"
      keys: []
    .then (msg) => msg.objects[0].content

module.exports = new WeeChat