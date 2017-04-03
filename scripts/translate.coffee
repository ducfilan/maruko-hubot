wanakana         = require 'wanakana'

regex_patterns   = require './common/regex_patterns'
constants        = require './common/constants'

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
            if data.data[i].phonetic in [keyword] || data.data[i].word in [keyword]
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
  robot.respond regex_patterns.translate.vie_to_jap, (msg) ->
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
                meaning += '*(' + (data.data[i].means[j].kind || '-') + ') ' + data.data[i].means[j].mean + '*\n'
                if data.data[i].means[j].examples.length > 0
                  meaning += '>' + data.data[i].means[j].examples[0].content + ': '
                  meaning += data.data[i].means[j].examples[0].mean + '\n'

          msg.send meaning
        catch err
          robot.emit 'error', err
          msg.send "I don't find any mean"

  # ------------------------------------------
  # Search kanji
  # ------------------------------------------
  robot.respond regex_patterns.translate.explain_kanji, (msg) ->
    keyword = msg.match[2]
    keywordEncode = encodeURIComponent(keyword)
    # msg.send keyword
    msg.http("http://mazii.net/api/mazii/#{keywordEncode}/10")
      .header('User-Agent', 'Mozilla/5.0')
      .get() (err, res, body) ->
        data = null
        try
          data = JSON.parse body
          meaning = ""
          exp = constants.exampleKanjiNumber
          
          for i in [0...data.results.length]
            meaning += '*Kanji: ' + data.results[i].kanji + '*\n'
            meaning += '>*訓*: ' + data.results[i].kun + '\n'
            meaning += '>*音*: ' + data.results[i].on + '\n'
            if data.results[i].examples.length < 5
              exp = data.results[i].examples.length
            for j in [1...exp+1]
              meaning += '>*例' + j + '*: ' + data.results[i].examples[j].p + ' - ' + data.results[i].examples[j].m + '\n'

          msg.send meaning
        catch err
          robot.emit 'error', err
          msg.send "I don't find any mean"
