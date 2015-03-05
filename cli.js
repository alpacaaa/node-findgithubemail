#!/usr/bin/env node

if (process.argv.length !== 3) {
  console.log("USAGE \nfindgithubemail <username>");
  process.exit();
}

var username = process.argv[2];

console.log('Looking for ' + username);

require('./index').find(username)
.then(console.log)
.catch(function(error) {
  return console.log(error.message);
});
