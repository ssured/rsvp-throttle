rsvp-throttle
=============

Throttles (RSVP) promises, implemented in CoffeeScript

This library is derived from https://github.com/meryn/f-throttle

Sample usage:

```
fs       = require 'fs'
RSVP     = require 'rsvp'
throttle = require 'rsvp-throttle'

readFile = RSVP.denodeify fs.readFile

readFileThrottled = throttle 2, readFile
```

`readFileThrottled()` will now limit execution to a maximum of 2 concurrent reads.