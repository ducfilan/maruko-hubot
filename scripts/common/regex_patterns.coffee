regex_patterns = module.exports =
  anything: /^(.*)$/
  test:
    alphabet: /.*test.* alphabet.*? (hiragana|katakana)/i
    general:  /.*test.* general.* lesson.* (\d+)/i
    vocabulary: /.*test.* vocabulary.* lesson.* (\d+)/
    simplify_text: /[～ 　	（）\(\)「」]/g
  show:
    vocabulary: /.*(show|view).* vocabulary.* lesson.* (\d+)/
  translate:
    jap_to_vie: /.*trans\w* (.*) to vi/i
    vie_to_jap: /.*trans\w* (.*) to ja/i
    explain_kanji: /.*(explain|search).* kanji[a-z\s　"'\(\)]+(.)/i
  common:
    latin_chars: /^[a-z\s-\(\)\[\]]+$/i
  stop: /stop/i
