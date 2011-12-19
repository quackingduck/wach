(function() {
  var spawn;

  spawn = require('child_process').spawn;

  this.watch = function(dir, callback) {
    var watcherProcess;
    watcherProcess = spawn('./watchdir', [__dirname]);
    watcherProcess.stdout.on('data', function(data) {
      var changedPaths, path, _i, _len, _results;
      changedPaths = data.toString().split('\n').slice(0, -1);
      _results = [];
      for (_i = 0, _len = changedPaths.length; _i < _len; _i++) {
        path = changedPaths[_i];
        _results.push(callback(path));
      }
      return _results;
    });
    return watcherProcess.on('exit', function(code) {
      return process.stderr.write(("Unable to start watcher for \"" + __dirname + "\".\nThis is probably a bug.") + '\n');
    });
  };

}).call(this);
