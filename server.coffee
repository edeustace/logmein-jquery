fs = require('fs')
express = require('express')
stitch  = require('stitch')

# express server
app = express.createServer()
app.use express.bodyParser()


###
Get a simple json response
###
getResponse = (status, msg) ->
  status = status or "success"
  msg = msg or ""
  """
  { 
  "status" : "#{status}",
  "msg" : "#{msg}"
  }
  """

app.configure 'development', ->
  app.use express.static(__dirname + "/example" )

  ###
  Login..
  ###
  app.post '/login', (req, res) ->
    username = req.param('username', null)   
    if !username? or username == "bad_username"
      status = "failed"
      msg = "unknown failure"

    res.send getResponse(status, msg)

  ###
  Logout
  ###
  app.get '/logout', (req, res) -> res.send getResponse()

  port = process.env.PORT || 8000;
  app.listen port, ->
    console.log "server started on http://#{app.address().address}:#{port}/"
