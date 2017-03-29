module.exports = (robot) ->
  pattern = new RegExp('trans', 'i')

  robot.hear pattern, (msg) ->
    msg.http("http://mazii.net/api/search/%E9%A3%9F%E3%81%B9%E3%82%8B/20/1")
      .header('User-Agent', 'Mozilla/5.0')
      .get() (err, res, body) ->
        if err
          msg.send "Failed to connect to API"
          robot.emit 'error', err, res
          return

        data = null
        try
          data = JSON.parse body
          msg.send data.data[0].means[0].mean
        catch err
          msg.send "Failed to parse API response"
          robot.emit 'error', err