regex_patterns = module.exports =
  anything: /^(.*)$/
  test:
    alphabet: /test.* alphabet.*? (hiragana|katakana)*/i
    general:  /test.* general.* lesson.* (\d+)/i
    vocabulary: /test.* vocabulary.* lesson.* (\d+)/
    simplify_text: /[～ 　	（）\(\)「」]/g
  translate:
    jap_to_vie: /trans (.*) to vi/i
  common:
    latin_chars: /^[a-z\s-\(\)\[\]]+$/i
  stop: /stop/i
