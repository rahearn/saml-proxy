let defaults = require("./pa11y.js");

// set chrome path for github actions
defaults.defaults.chromeLaunchConfig = {
  
  "executablePath": "/usr/bin/chromium",
  "args": ["--no-sandbox"]
  
};

module.exports = defaults;
