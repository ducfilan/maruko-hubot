constants        = require './constants'

api_urls = module.exports =
  alphabet: "#{constants.firebaseUrl}/alphabet.json"
  general_questions: "#{constants.firebaseUrl}/test_general.json"
  lessons:
    vocabulary: "#{constants.firebaseUrl}/vocabulary_lessons.json"