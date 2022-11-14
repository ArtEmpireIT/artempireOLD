'use strict';

var fs = require('fs'),
  config = require('../config/config'),
  ospath = require('path'),
  shell = require('shelljs'),
  gm = require('gm').subClass({imageMagick: true});

function makeThumb(slug, myFile) {
  var dir = ospath.join(config.uploads, slug);
  var thumbsdir = ospath.join(dir, 'thumbs');
  var target = ospath.join(dir, myFile.name);
  var thumb = ospath.join(thumbsdir, myFile.name + '_thumb.png')

  return new Promise(function(resolve, reject){

    try {
      shell.mkdir('-p', thumbsdir);

      var paginator = '';
      if (myFile.mimetype==='application/pdf') {
        paginator = '[0]';
      }

      gm(target + paginator).thumb(150, 150, thumb, 60, function(err){
        console.log("Done!");
        return resolve("Done");
      })

    } catch (e) {
      console.log(e);
      return reject(e);
    }

  });
}

module.exports = function(slug, myFile){
  var dir = ospath.join(config.uploads, slug);

  try {
    shell.mkdir('-p', dir);
    fs.writeFileSync(ospath.join(dir, myFile.name), myFile.data);

    return makeThumb(slug, myFile);
  } catch (e) {
    return Promise.reject(e);
  }
}