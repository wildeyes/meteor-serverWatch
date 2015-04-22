Package.describe({
  name: "bjwiley2:server-watch",
  version: "0.0.6",
  // Brief, one-line summary of the package.
  summary: "Enables third party server pinging functionality",
  // URL to the Git repository containing the source code for this package.
  git: "https://github.com/NewSpring/meteor-serverWatch.git",
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: "README.md"
});

Package.onUse(function(api) {
  api.use("meteor-platform@1.2.2");
  api.use("http@1.1.0");
  api.use("coffeescript@1.0.6");

  api.addFiles("shared.coffee");
  api.addFiles("server.coffee", "server");
  api.addFiles("client.coffee", "client");

  api.export("serverWatch");
});
