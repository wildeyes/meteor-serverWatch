Package.describe({
  name: "xwildeyes:server-watch",
  version: "0.0.7",
  summary: "Fork:Enables third party server pinging functionality",
  git: "https://github.com/wildeyes/meteor-serverWatch.git",
  documentation: "README.md"
});

Npm.depends({
  "net-ping": "1.1.11"
})

Package.onUse(function(api) {
  api.use("meteor-platform@1.2.2");
  api.use("http@1.1.0");
  api.use("coffeescript@1.0.6");

  api.addFiles("shared.coffee");
  api.addFiles("server.coffee", "server");
  api.addFiles("client.coffee", "client");

  api.export("serverWatch");
});
