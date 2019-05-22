var exec = require('cordova/exec');

function GrpcWrapper(){};

GrpcWrapper.prototype.coolMethod = function(arg0, success, error) {
  exec(success, error, "GrpcWrapper", "coolMethod", [arg0]);
};

GrpcWrapper.prototype.onHold = function(arg0, success, error) {
  exec(success, error, "GrpcWrapper", "onHold", [arg0]);
};

GrpcWrapper.prototype.onRelease = function(arg0, success, error) {
  exec(success, error, "GrpcWrapper", "onRelease", [arg0]);
};

GrpcWrapper.prototype.onTap = function(arg0, success, error) {
  console.log("GrpcWrapper.js - OnTap() - Called");
  exec(success, error, "GrpcWrapper", "onTap", [arg0]);
};

GrpcWrapper.prototype.startVoice = function(arg0, success, error) {
  exec(success, error, "GrpcWrapper", "onStartGrpcTextToSpeech", [arg0]);
};

GrpcWrapper.prototype.onSpeaking = function(arg0, success, error) {
  exec(success, error, "GrpcWrapper", "onSpeaking", [arg0]);
};

if (typeof module != 'undefined' && module.exports) {
  module.exports = GrpcWrapper;
}
