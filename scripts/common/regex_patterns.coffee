regex_patterns = module.exports =
  anything: /^(.*)$/
  test:
    alphabet: /test.* alphabet.*? (hiragana|katakana)*/i
    general:  /test.* general.* lesson.* (\d+)/i
  stop: /stop/i