###
rsvp-throttle allows throttling promises

The MIT License (MIT)

Copyright (c) 2013 Meryn Stol
Copyright (c) 2014 Sjoerd de Jong

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
###

RSVP      = require 'rsvp'

module.exports = (concurrency, fn) ->
  throw new Error "Concurrency must be equal or higher than 1." unless concurrency >= 1
  throw new Error "Worker must be a function." unless typeof fn is "function"
  numRunning = 0
  queue = []

  startJobs = ->
    startJob job while numRunning < concurrency and job = queue.shift()

  startJob = (job) ->
    rejectedHandler = makeRejectedHandler job
    numRunning++
    try
      promise = fn.apply job.context, job.arguments
      promise.then makeFulfilledHandler(job), rejectedHandler
    catch error
      rejectedHandler error

  makeFulfilledHandler = (job) ->
    (result) ->
      numRunning--
      job.resolve result
      startJobs() if queue.length

  makeRejectedHandler = (job) ->
    (error) ->
      numRunning--
      job.reject error
      startJobs() if queue.length

  (args...) ->
    new RSVP.Promise (resolve, reject) =>
      queue.push
        context: @
        arguments: args
        resolve: resolve
        reject: reject
      startJobs()
