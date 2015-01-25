Package.describe({
  name: 'bjwiley2:server-watch',
  version: '0.0.2',
  // Brief, one-line summary of the package.
  summary: 'Enables third party server pinging functionality',
  // URL to the Git repository containing the source code for this package.
  git: 'https://github.com/NewSpring/meteor-serverWatch.git',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.use('meteor-platform@1.2.1');
  api.use('http@1.0.10');
  api.addFiles('bjwiley2:server-watch.js');
});

Package.onTest(function(api) {
  api.use('tinytest');
  api.use('bjwiley2:server-watch');
  api.addFiles('bjwiley2:server-watch-tests.js');
});
