(function() {
  var logInfo, minimatch, parseArgs, passesGlobFilters, path, spawn, substitutePath, usage, watch;
  path = require('path');
  spawn = require('child_process').spawn;
  minimatch = require('minimatch');
  watch = require('./wach');
  this.run = function(args) {
    var command, commandRunning, help, only, _ref;
    _ref = parseArgs(args), help = _ref.help, command = _ref.command, only = _ref.only;
    if (help) {
      console.log(usage);
      process.exit(0);
    }
    if (command.length === 0) {
      console.log(usage);
      process.exit(1);
    }
    logInfo("Will run: " + command);
    logInfo("when any files added or updated.");
    commandRunning = false;
    return watch(process.cwd(), function(changedPath) {
      var child;
      changedPath = path.relative(process.cwd(), changedPath);
      if (commandRunning) {
        return;
      }
      if (!path.existsSync(changedPath)) {
        return;
      }
      if (!passesGlobFilters(path, only)) {
        return;
      }
      logInfo("changed: " + changedPath + " ");
      logInfo("running command");
      logInfo("");
      child = spawn('sh', ['-c', substitutePath(command, changedPath)]);
      commandRunning = true;
      child.stdout.pipe(process.stdout);
      return child.on('exit', function(code) {
        commandRunning = false;
        logInfo("");
        return logInfo("command exited");
      });
    });
  };
  parseArgs = function(raw) {
    var arg, command, help, i, only;
    help = false;
    command = [];
    only = [];
    while (arg = raw.shift()) {
      switch (arg) {
        case '--help':
        case '-h':
          help = true;
          break;
        case '--only':
        case '-o':
          only = (function() {
            var _i, _len, _ref, _results;
            _ref = raw.shift().split(',');
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              i = _ref[_i];
              if (i !== '') {
                _results.push(i);
              }
            }
            return _results;
          })();
          break;
        default:
          command.push(arg);
      }
    }
    command = command.join(' ');
    return {
      help: help,
      command: command,
      only: only
    };
  };
  substitutePath = function(command, path) {
    return command.replace('@', path);
  };
  passesGlobFilters = function(path, filters) {
    var exp, pass, _i, _len;
    if (filters.length === 0) {
      return true;
    } else {
      pass = false;
      for (_i = 0, _len = only.length; _i < _len; _i++) {
        exp = only[_i];
        if (minimatch(changedPath, exp)) {
          pass = true;
        }
      }
      return pass;
    }
  };
  logInfo = function(msg) {
    return console.log("- " + msg);
  };
  usage = "Usage:\n  wach [options] <command>\n\nRequired:\n  <command>\n    Run every time an update occurs in the directory being monitored.\n    The `@` will be subsituted with the path that changed.\n\nOptions:\n  -o|--only <glob>\n    Only run <command> when the path that changed matches <glob>. Quote the\n    glob or add a trailing comma to prevent your shell from automatically\n    expanding it.\n\nExamples:\n  wach make\n  wach -o *.c, make\n  wach -o *.coffee, coffee @\n  TEST_DIR=generators wach -o **/*.rb, bundle exec rake test";
}).call(this);
