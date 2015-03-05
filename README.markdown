
# Find Github user emails

This is a simple node.js module that scans email addresses in commits and takes a guess as to what might be the user's main email.

It's based on [FindGitHubEmail](https://github.com/hodgesmr/FindGitHubEmail/) by [@hodgesmr](https://github.com/hodgesmr) (**Matt Hodges**). As noted there, it makes it easy to get in contact with open source developers. Please use it for good, not evil.


### Install

    npm install findgithubemail


### Usage

```javascript
var findgithubemail = require('findgithubemail');
var username = 'alpacaaa';

findgithubemail.find(username)
.then (function(result) {
  console.log(result);
});

// {
//   best_guess: 'babbonatale@alpacaaa.net',
//   gravatar_match: true,
//   alternatives: []
// }
```


If you want, you can set a custom access token and authenticate your requests

```javascript
findgithubemail.access_token = 'token'
```


### Command line usage

You can install this module globally with the `-g` flag and use it from the command line.

    findgithubemail alpacaaa


### Testing

    npm test


### License


> Copyright (c) 2015, Marco Sampellegrini <babbonatale@alpacaaa.net>


> Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

> THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
