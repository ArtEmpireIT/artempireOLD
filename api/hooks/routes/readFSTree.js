'use strict';

const walker = require('walk');
function readFSTree(baseDir, exclude) {
  exclude = exclude || ['thumbs'];
  const tree = {};
  return new Promise((resolve, reject) => {
    walker.walk(baseDir, {filters: exclude})
    .on('names', (root, names, next) => {
      if (root !== baseDir) {
        const dirName = root.replace(`${baseDir}/`, '');
        const okNames = names.filter(n => exclude.indexOf(n) === -1);
        tree[dirName] = okNames;
      }
      next();
    })
    .on('end', () => resolve(tree))
    .on('errors', (_, nodeStatsArray) => reject(nodeStatsArray));
  }).catch(err => {
    console.error('[readFSTree.js]: ERROR \n', err)
    return {}
  })
}

module.exports = readFSTree;
