#!/usr/bin/env node
 
var Bitly = require('bitly');
var bitly = new Bitly(process.env.BITLY_API_KEY);
 
bitly.shorten('http://www.fieldtriptoolbox.org')
  .then(function(response) {
    var short_url = response.data.url
    console.log(short_url);
  }, function(error) {
    throw error;
  });
