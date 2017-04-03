request = require 'request'

http_request = module.exports =
  make: (apiUrl, callback, errorMessage) ->
    msg.http(apiUrl)
      .header('User-Agent', 'Mozilla/5.0')
      .get() (err, res, body) ->
        if err
          msg.send "Failed to connect to API"
          return

        jsonData = null
        try
          jsonData = JSON.parse body
          callback && callback jsonData

          return jsonData
        catch err
          msg.send errorMessage || ''

  getData: (apiUrl, callback) ->
    request apiUrl, (error, response, body) ->
      if !error and response.statusCode == 200
        jsonData = JSON.parse body
        callback jsonData