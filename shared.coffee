@.serverWatches = new Mongo.Collection "serverWatches"
serverWatch = {}

serverWatch.isAlive = (key) ->
  watch = serverWatches.findOne key: key

  if not watch
    throw new Meteor.Error "key-doesn't-exist", "There is no server associated
      with that key"

  return watch.isAlive

serverWatch.onChange = (key, cb) ->
  if typeof cb isnt "function"
    throw new Meteor.Error "invalid-callback", "The callback param must be a
      function"

  cursor = serverWatches.find
    key: key
  ,
    fields: isAlive: 1

  if cursor.count() is 0
    throw new Meteor.Error "key-doesn't-exist", "There is no server associated
      with that key"

  handle = cursor.observeChanges
    changed: (id, fields) ->
      cb fields.isAlive
    removed: (id) ->
      handle.stop()

  cb cursor.fetch()[0].isAlive
  return handle
