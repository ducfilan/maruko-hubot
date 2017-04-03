
Promise = require('bluebird')

module.exports = (robot) ->
  pattern = new RegExp('read news', 'i')
  # read news
  # -----------------------------
  robot.respond pattern, (msg) ->

    responseMsg = (list) ->
      if list.length < 10
        return false
      message = ""
      for i in [0...list.length]
        title = list[i].result.title.replace(/(<ruby>|<rt>.*?<\/rt><\/ruby>)/g, '')
        link = list[i].result.link.replace(/(<ruby>|<rt>.*?<\/rt><\/ruby>)/g, '')

        message += '[' + list[i].result.pubDate + ']' + title + '\n'
        message += '\tLink: ' + link + '\n'

      return message

    msg.http("http://mazii.net/api/news/1/10")
      .header('User-Agent', 'Mozilla/5.0')
      .get() (err, res, body) ->
        data = null
        try
          data = JSON.parse body

          newslist = []
          requests = []
          msg2 = msg
          for i in [0...data.results.length]
            id = data.results[i].id

            msg2.http("http://mazii.net/api/news/#{id}")
            .header('User-Agent', 'Mozilla/5.0')
            .get() (err, res, body) ->
              news = JSON.parse body
              newslist.push(news)
              content = responseMsg(newslist)
              if content
                msg2.send content

        catch err
          robot.emit 'error', err
          msg.send "I don't find any mean"
