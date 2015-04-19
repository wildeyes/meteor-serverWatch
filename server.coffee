handles = {}
callOptions = timeout: 5000


sendOnePing = (doc, callback) ->
  HTTP.get doc.url, callOptions, (error, result) ->
    isAlive = (not error) and result and result.statusCode is 200

    serverWatches.update
      _id: doc._id
    ,
      $set:
        isAlive: isAlive

    if typeof callback is "function"
      callback()


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


serverWatch.refresh = (key) ->
  doc = getByKey key
  sendOnePing doc


serverWatch.overrideStatus = (key, isAlive) ->
  existing = getByKey key

  if typeof isAlive isnt "boolean"
    throw new Meteor.Error "invalid param", "isAlive must be a boolean"

  serverWatches.update
    _id: existing._id
  ,
    $set:
      isAlive: isAlive


serverWatch.getKeys = ->
  serverWatches.find({}, fields: key: 1).map (doc) ->
    doc.key


serverWatch.watch = (key, url, delay) ->
  existing = serverWatches.findOne key: key

  if typeof delay isnt "undefined"
    delay = Number delay

  if existing
    throw new Meteor.Error "key-exists-already", "There is already a server
      associated with that key"

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

  id = serverWatches.insert newDoc
  newDoc._id = id

  try
    sendOnePing newDoc, ->
      ping newDoc
  catch error
    serverWatch.stopWatching key
    throw error


serverWatch.stopWatching = (key) ->
  watch = getByKey key
  handle = handles[watch._id]

  if handle
    Meteor.clearInterval handle
    delete handles[watch._id]

  serverWatches.remove watch._id


Meteor.startup ->
  serverWatches.find().forEach (doc) ->
    ping doc

  Meteor.publish "serverWatches", ->
    serverWatches.find {}, fields:
      key: 1
      isAlive: 1
