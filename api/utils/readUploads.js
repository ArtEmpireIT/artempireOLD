'use strict';

var config = require('../config/config');
var ospath = require('path');
var walk   = require('walk');

module.exports = function(req, res) {

  var slug = req.slug;
  var id = req.params.id;

  var dir = ospath.join(config.uploads, slug, id);

  var thumbs = [];
  walk.walkSync(dir, {
    followLinks: false,
    listeners: {
      file: function(root, myFile) {
        console.log(root);

        var target = ospath.join('/uploads', slug, id, myFile.name);
        var thumb = ospath.join('/uploads', slug, id, 'thumbs', myFile.name + '_thumb.png');
        var pat = /thumbs$/;

        if (!(pat.exec(root))) {
          console.log(thumb);
          thumbs.push({
            filename: myFile.name,
            image: target,
            thumb: thumb
          });
        }
      }
    }
  });

  res.send(thumbs);
}