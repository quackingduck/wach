(function() {
  var exit, localTime, logInfo, minimatch, npmVersion, passesGlobFilters, path, spawn, substitutePath, support, termColor, termColorWrap, usage, watch;
  path = require('path');
  spawn = require('child_process').spawn;
  minimatch = require('minimatch');
  support = require('./support');
  watch = require('./wach');
  this.run = function(args) {
    var command, commandRunning, help, only, version, _ref;
    _ref = support.parseArgs(args), help = _ref.help, version = _ref.version, command = _ref.command, only = _ref.only;
    if (help != null) {
      exit(0, usage);
    }
    if (version != null) {
      exit(0, npmVersion());
    }
    if (command == null) {
      exit(1, usage);
    }
    logInfo("Will run: " + command);
    if (only.length === 0) {
      logInfo("when any files added or updated.");
    } else {
      logInfo("when files matching {" + (only.join(',')) + "} added or updated");
    }
    commandRunning = false;
    return watch(process.cwd(), function(changedPath) {
      var child, commandWithPathSubsitution;
      changedPath = path.relative(process.cwd(), changedPath);
      if (commandRunning) {
        return;
      }
      if (!path.existsSync(changedPath)) {
        return;
      }
      if (!passesGlobFilters(changedPath, only)) {
        return;
      }
      commandWithPathSubsitution = substitutePath(command, changedPath);
      logInfo("");
      logInfo("changed: " + changedPath + " (" + (localTime()) + ")");
      logInfo("running: " + commandWithPathSubsitution);
      logInfo("");
      child = spawn('sh', ['-c', commandWithPathSubsitution]);
      commandRunning = true;
      child.stdout.pipe(process.stdout);
      child.stderr.pipe(process.stderr);
      return child.on('exit', function(code) {
        return commandRunning = false;
      });
    });
  };
  substitutePath = function(command, path) {
    return command.replace('{}', path);
  };
  passesGlobFilters = function(path, filters) {
    var exp, pass, _i, _len;
    if (filters.length === 0) {
      return true;
    } else {
      pass = false;
      for (_i = 0, _len = filters.length; _i < _len; _i++) {
        exp = filters[_i];
        if (minimatch(path, exp)) {
          pass = true;
        }
      }
      return pass;
    }
  };
  logInfo = function(msg) {
    return console.error(termColorWrap('0;38;5;246', "- " + msg));
  };
  termColorWrap = function(code, str) {
    return termColor(code) + str + termColor();
  };
  termColor = function(code) {
    if (code == null) {
      code = '';
    }
    return '\033' + '[' + code + 'm';
  };
  localTime = function() {
    return (new Date).toTimeString().split(' ')[0];
  };
  exit = function(status, message) {
    if (message != null) {
      console.log(message);
    }
    return process.exit(status);
  };
  npmVersion = function() {
    return JSON.parse(require('fs').readFileSync(__dirname + '/../package.json')).version;
  };
  usage = "Usage:\n  wach [options] <command>\n\nRequired:\n  <command>\n    Run every time an update occurs in the directory being monitored.\n    The `@` will be subsituted with the path that changed.\n\nOptions:\n  -o|--only <glob>\n    Only run <command> when the path that changed matches <glob>. Quote the\n    glob or add a trailing comma to prevent your shell from automatically\n    expanding it.\n\nExamples:\n  wach make\n  wach -o *.c, make\n  wach -o *.coffee, coffee @\n  TEST_DIR=generators wach -o **/*.rb, bundle exec rake test";
  this._test = {
    passesGlobFilters: passesGlobFilters
  };
}).call(this);
