module.exports = (robot) ->
  pattern = new RegExp('wt', 'i')

  robot.hear pattern, (msg) ->
    msg.http("http://api.openweathermap.org/data/2.5/weather?q=Tokyo&appid=8790de8a9ce79ea51d2fe506dd051aca")
      .header('User-Agent', 'Mozilla/5.0')
      .get() (err, res, body) ->
        data = JSON.parse body
        msg.send data.weather[0].description
        if res.getHeader('Content-Type') isnt 'application/json'
          msg.send "Didn't get back JSON :("
          return

        if err
          msg.send "Failed to connect to API"
          robot.emit 'error', err, res
          return

        data = null
        try
          data = JSON.parse body
          msg.send data.weather[0].description
        catch err
          msg.send "Failed to parse API response"
          robot.emit 'error', err