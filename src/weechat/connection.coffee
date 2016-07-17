{Protocol} = require './protocol.js'
protocol = new Protocol
EventEmitter = require 'events'
WebSocketWrapper = require './websockets.coffee'

connect = (host, port, password, ssl, cb) ->
  self = new EventEmitter
  if host.indexOf(':') isnt -1 and host[0] isnt '['
    # IPv6 Host
    host = "[#{host}]"
  conn = new WebSocketWrapper
  connected = false
  onopen = ->
    conn.send Protocol.formatInit
      password: password
      compression: 'zlib'

    conn.send Protocol.formatInfo
      name: 'version'
    .then (msg) ->
      cb(msg) if cb?
  onmessage = ->
    connected = true
  onclose = ->
    if connected
      self.emit 'close'
    else
      self.emit 'error', new Error 'Wrong password'
  onerror = (err) ->
    console.log err
    self.emit 'error', err

  conn.on 'message', (msg) ->
    if msg.id? and msg.id.startsWith('_') and msg.objects?
      self.emit msg.id, msg.objects

  conn.connect "#{if ssl then 'wss' else 'ws'}://#{host}:#{port}/weechat",
    binaryType: 'arraybuffer'
    onopen: onopen
    onmessage: onmessage
    onclose: onclose
    onerror: onerror

  self.send = conn.send.bind conn
  return self

module.exports =
  connect: connect