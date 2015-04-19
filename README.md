Server Watch
===

Enables third party server pinging functionality.

# Example Usage

Use the following code to watch a server:

  ````coffeescript
  if Meteor.isServer
    # Start "pinging" the indicated url every 30 seconds
    serverWatch.watch "SomeServer", "http://path/to/some/server", 30 * 1000

    # Check to see if the server responded on the latest "ping"
    if serverWatch.isAlive "SomeServer"
      # Celebrate!
    else
      # Uh oh, do something!

    # Returns an array of keys - ie: ["SomeServer"]
    keys = serverWatch.getKeys()
    serverWatch.stopWatching keys[0]

    # Between "pings" I might discover that the server is down/up
    serverWatch.overrideStatus "SomeServer", true

    # Force a refresh
    serverWatch.refresh "SomeServer"


  if Meteor.isClient
    # This is reactive
    if serverWatch.isAlive "SomeServer"
      # Celebrate!
    else
      # Uh oh, do something!
  ````
