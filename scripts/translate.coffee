wanakana         = require 'wanakana'

regex_patterns   = require './common/regex_patterns'

module.exports = (robot) ->
  # translate jp to vi
  # -----------------------------
  robot.respond regex_patterns.translate.jap_to_vie, (msg) ->
    keyword = msg.match[1]
    if regex_patterns.common.latin_chars.test keyword
      keyword = wanakana.toHiragana(keyword)

    keywordEncode = encodeURIComponent(keyword)
    # msg.send keyword
    msg.http("http://mazii.net/api/search/#{keywordEncode}/20/1")
      .header('User-Agent', 'Mozilla/5.0')
      .get() (err, res, body) ->
        data = null
        try
          data = JSON.parse body

          meaning = ""
          for i in [0...data.data.length]
            if data.data[i].phonetic in [keyword]
              for j in [0...data.data[i].means.length]
                meaning += '*(' + data.data[i].means[j].kind + ') ' + data.data[i].means[j].mean + '*\n'
                if data.data[i].means[j].examples
                    meaning += '>' + data.data[i].means[j].examples[0].content + '\n'
                    meaning += '>' + data.data[i].means[j].examples[0].mean + '\n'
          msg.send meaning
        catch err
          robot.emit 'error', err
          msg.send "I don't find any mean"
  # ------------------------------------------
  # translate to jp
  # ------------------------------------------
  jppattern = new RegExp('trans (.*) to jp', 'i')
  robot.respond jppattern, (msg) ->
    keyword = msg.match[1]
    keywordEncode = encodeURIComponent(keyword)
    # msg.send keyword
    msg.http("http://mazii.net/api/search/#{keywordEncode}/20/1")
      .header('User-Agent', 'Mozilla/5.0')
      .get() (err, res, body) ->
        data = null
        try
          data = JSON.parse body

          meaning = ""
          for i in [0...data.data.length]
            if data.data[i].word in [keyword]
              for j in [0...data.data[i].means.length]
                meaning += '**(' + data.data[i].means[j].kind + ') ' + data.data[i].means[j].mean + '\n'
                if data.data[i].means[j].examples.length > 0
                    meaning += '\t' + data.data[i].means[j].examples[0].content + '\n'
                    meaning += '\t' + data.data[i].means[j].examples[0].mean + '\n'
          msg.send meaning
        catch err
          robot.emit 'error', err
          msg.send "I don't find any mean"

  # ------------------------------------------
  # Search kanji
  # ------------------------------------------
  kjpattern = new RegExp('search kanji of (.*)', 'i')
  robot.respond kjpattern, (msg) ->
    keyword = msg.match[1]
    keywordEncode = encodeURIComponent(keyword)
    # msg.send keyword
    msg.http("http://mazii.net/api/mazii/#{keywordEncode}/10")
      .header('User-Agent', 'Mozilla/5.0')
      .get() (err, res, body) ->
        data = null
        try
          data = JSON.parse body
          meaning = ""

          for i in [0...data.results.length]
            meaning += '** Kanji: ' + data.results[i].kanji + '\n'
            meaning += '\t+, 訓: ' + data.results[i].kun + '\n'
            meaning += '\t+, 音: ' + data.results[i].on + '\n'
            # if data.data[i].means[j].examples.length > 0
            #     meaning += '\t' + data.data[i].means[j].examples[0].content + '\n'
            #     meaning += '\t' + data.data[i].means[j].examples[0].mean + '\n'
          msg.send meaning
        catch err
          robot.emit 'error', err
          msg.send "I don't find any mean"
