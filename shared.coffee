@.serverWatches = new Mongo.Collection "serverWatches"
serverWatch = {}

serverWatch.isAlive = (key) ->
  watch = serverWatches.findOne key: key
  return watch and watch.isAlive
