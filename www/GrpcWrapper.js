//var exec = require('cordova/exec');

module.exports.echo = function(arg0, success, error) {
  cordova.exec(success, error, "GrpcWrapper", "echo", [arg0]);
};

module.exports.onHold = function(arg0, success, error) {
  cordova.exec(success, error, "GrpcWrapper", "onHold", [arg0]);
};

module.exports.onRelease = function(arg0, success, error) {
  cordova.exec(success, error, "GrpcWrapper", "onRelease", [arg0]);
};

module.exports.onTap = function(arg0, success, error) {
  cordova.exec(success, error, "GrpcWrapper", "onTap", [arg0]);
};

module.exports.startVoice = function(arg0, success, error) {
  cordova.exec(success, error, "GrpcWrapper", "onStartGrpcTextToSpeech", [arg0]);
};

module.exports.onSpeaking = function(arg0, success, error) {
  cordova.exec(success, error, "GrpcWrapper", "onSpeaking", [arg0]);
};



exports.echojs = function(arg0, success, error) {
  if (arg0 && typeof(arg0) === 'string' && arg0.length > 0) {
    success(arg0);
  } else {
    error('Empty message!');
  }
};