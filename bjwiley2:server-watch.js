var serverWatches = new Mongo.Collection("serverWatches");
var serverWatch = {};

serverWatch.isAlive = function (key) {
  var watch = serverWatches.findOne({ key: key });
  return watch && watch.isAlive;
};

if(Meteor.isClient) {
  Meteor.subscribe("serverWatches");
}

if(Meteor.isServer) {
  var handles = {};

  var callOptions = {
    timeout: 5000
  };

  var sendOnePing = function (doc, callback) {
    HTTP.get(doc.url, callOptions, function (error, result) {
      var isAlive = !error && result && result.statusCode === 200;
      serverWatches.update({ _id: doc._id }, { $set: { isAlive: isAlive } });

      if(typeof callback === "function") {
        callback();
      }
    });
  };

  var ping = function (doc) {
    var handle = Meteor.setInterval(function () {
      sendOnePing(doc);
    }, doc.delay);

    handles[doc._id] = handle;
  };

  serverWatch.getKeys = function () {
    return serverWatches.find({}, { fields: { key: 1 } }).map(function (doc) {
      return doc.key;
    });
  };

  serverWatch.watch = function (key, url, delay) {
    var existing = serverWatches.findOne({ key: key });

    if(existing) {
      throw new Meteor.Error("key-exists-already",
        "There is already a server associated with that key");
    }

    var newDoc = {
      key: key,
      url: url,
      delay: delay,
      isAlive: true
    };

    id = serverWatches.insert(newDoc);
    newDoc._id = id;

    try {
      sendOnePing(newDoc, function () {
        ping(newDoc);
      });
    }
    catch(error) {
      serverWatch.stopWatching(key);
      throw error;
    }
  };

  serverWatch.stopWatching = function (key) {
    var watch = serverWatches.findOne({ key: key });
    var handle = handles[watch._id];

    if(handle) {
      Meteor.clearInterval(handle);
      handles[watch._id] = undefined;
    }

    serverWatches.remove(watch._id);
  };

  serverWatches.find().forEach(function (doc) {
    ping(doc);
  });

  Meteor.publish("serverWatches", function () {
    return serverWatches.find({}, { fields: { key: 1, isAlive: 1 } });
  });
}

this.serverWatch = serverWatch;
