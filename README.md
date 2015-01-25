Server Watch
===

Enables third party server pinging functionality.

# Example Usage

Use the following code to watch a server:

  ````coffeescript
  if Meteor.isServer
    serverWatch.watch "SomeServer", "http://path/to/some/server", 30 * 1000

    if serverWatch.isAlive "SomeServer"
      # Celebrate!
    else
      # Uh oh, do something!

    keys = serverWatch.getKeys()
    serverWatch.stopWatching keys[0]


  if Meteor.isClient
    if serverWatch.isAlive "SomeServer"
      # Celebrate!
    else
      # Uh oh, do something!
  ````
