handles = {}
callOptions = timeout: 5000
pingWithTCP = true
npmPing = Npm.require('ping')
wrappedPing = Meteor.wrapAsync(npmPing.sys.probe, npmPing.sys)

sendOnePing = (doc, callback) ->
  if pingWithTCP
    wrappedPing doc.url, (isAlive)->
      serverWatches.update {key:doc.key} , {$set: isAlive: isAlive} , upsert: true
      if typeof callback is "function"
        callback isAlive
  else
    HTTP.get doc.url, callOptions, (error, result, callback) ->
    isAlive = (not error) and result and result.statusCode is 200

    serverWatches.update {key:doc.key} , {$set: isAlive: isAlive} , upsert: true

    if typeof callback is "function"
      callback isAlive

ping = (doc) ->
  handle = Meteor.setInterval ->
    sendOnePing doc
  , doc.delay

  handles[doc._id] = handle


getByKey = (key) ->
  doc = serverWatches.findOne key: key

  if not doc
    throw new Meteor.Error "key-doesn't-exist", "There is no server associated
      with that key"

  return doc


serverWatch.refresh = (key, callback) ->
  doc = getByKey key
  sendOnePing doc, callback


serverWatch.overrideStatus = (key, isAlive) ->
  existing = getByKey key

  if typeof isAlive isnt "boolean"
    throw new Meteor.Error "invalid param", "isAlive must be a boolean"

  serverWatches.update {key:doc.key} , {$set: isAlive: isAlive} , upsert: true

serverWatch.getKeys = ->
  serverWatches.find({}, fields: key: 1).map (doc) ->
    doc.key


serverWatch.watch = (key, url, delay) ->

  existing = serverWatches.findOne key: key

  if typeof delay isnt "undefined"
    delay = Number delay

  if typeof key isnt "string" or key.trim().length is 0
    throw new Meteor.Error "invalid param", "key must be a non-empty string"

  if typeof url isnt "string" or url.trim().length is 0
    throw new Meteor.Error "invalid param", "url must be a non-empty string"

  if not (typeof delay is "undefined" or (typeof delay is "number" and delay > 0 ))
    throw new Meteor.Error "invalid param", "delay must be undefined or a
      number greater than 0"

  newDoc =
    key: key
    url: url
    delay: delay or (30 * 1000)
    isAlive: true

  serverWatches.upsert(key: key, newDoc)

  try
    sendOnePing newDoc, ->
      ping newDoc
  catch error
    serverWatch.stopWatching key
    throw error


serverWatch.stopWatching = (key) ->
  watch = getByKey key

  if handle
    Meteor.clearInterval handle
    delete handles[watch.key]

  serverWatches.remove watch.key


Meteor.startup ->
  serverWatches.find().forEach (doc) ->
    ping doc

  Meteor.publish "serverWatches", ->
    serverWatches.find {}, fields:
      key: 1
      isAlive: 1
