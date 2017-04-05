# Commands:
#   @maruko test vocabulary lesson n - Test vocabulary in Minna no Nihongo lesson number n.
#   @maruko show vocabulary lesson n - Show all words in Minna no Nihongo lesson number n.

sprintf          = require("sprintf-js").sprintf
wanakana         = require 'wanakana'

api_urls         = require './common/api_urls'
http_request     = require './common/http_request'
static_strings   = require './common/static_strings'
helper_functions = require './common/helper_functions'
custom_types     = require './common/custom_types'
regex_patterns   = require './common/regex_patterns'

UserState        = require './model/user_state'

class VocabularyTest
  constructor: (@baseApiUrl) ->

  takeVocabItemsInLesson: (lessonNo, callback) ->
    filterDataPart = '?orderBy="lessonNo"&equalTo=' + lessonNo
    apiUrl = @baseApiUrl + filterDataPart

    http_request.getData apiUrl, (jsonData) ->
      callback jsonData

  formatQuestion: (item) ->
    sprintf static_strings.en.test.vocabulary.ask_a_term, item.meaning

  formatLessonItems: (items) ->
    formatedLessonString = static_strings.en.show.vocabulary.list_prefix
    formatedLessonString += '```'

    for itemKey in Object.keys items
      item = items[itemKey]
      formatedLessonString += "#{item.term} (#{item.type}): #{item.meaning}\n"

    formatedLessonString += '```'

    formatedLessonString

  simplifyText: (term) ->
    wanakana.toHiragana term.replace regex_patterns.test.simplify_text, ''

  isAnswering: (interactionType, interactionStatus) ->
    interactionType == custom_types.interaction.test.vocabulary and
    interactionStatus == custom_types.interaction_status.test.not_answered

module.exports = (robot) ->
  robot.respond regex_patterns.test.vocabulary, (responser) ->
    username = responser.message.user.name
    [userRequestQuery, selectedTestLesson] = [responser.match[0], responser.match[1]]

    robot.brain.set "#{username}_state",
                    new UserState username,
                                  custom_types.interaction.test.vocabulary,
                                  custom_types.interaction_status.test.not_answered

    robot.brain.set "#{username}_request_query", userRequestQuery
    robot.brain.set "#{username}_last_selected_vocabulary_lesson", selectedTestLesson

    responser.send static_strings.en.test.vocabulary.notice

    vocabularyTest = new VocabularyTest api_urls.lessons.vocabulary

    vocabularyTest.takeVocabItemsInLesson selectedTestLesson, (items) ->
      robot.brain.set "#{username}_vocabulary_items", items
      robot.brain.set "#{username}_vocabulary_current_item_no", 1

      firstItem = items[Object.keys(items)[0]]
      robot.messageRoom "@#{username}", vocabularyTest.formatQuestion firstItem

  robot.respond regex_patterns.show.vocabulary, (responser) ->
    username = responser.message.user.name
    [userRequestQuery, selectedLesson] = [responser.match[0], responser.match[2]]

    robot.brain.set "#{username}_state",
                    new UserState username,
                                  custom_types.interaction.show.vocabulary,
                                  custom_types.interaction_status.show.not_shown

    responser.send static_strings.en.show.vocabulary.notice

    vocabularyTest = new VocabularyTest api_urls.lessons.vocabulary

    vocabularyTest.takeVocabItemsInLesson selectedLesson, (items) ->
      robot.messageRoom "@#{username}", vocabularyTest.formatLessonItems items

  robot.hear regex_patterns.anything, (responser) ->
    username = responser.message.user.name
    answer = responser.match[1]

    return if answer == robot.brain.get "#{username}_request_query"

    userState = robot.brain.get "#{username}_state" || null
    if userState != null
      messageToSend = ''
      vocabularyTest = new VocabularyTest api_urls.lessons.vocabulary
      [interactionType, interactionStatus] = [userState.getInteractionType(), userState.getInteractionStatus()]

      if vocabularyTest.isAnswering interactionType, interactionStatus
        testItems = robot.brain.get "#{username}_vocabulary_items"
        currentQuestionNo = robot.brain.get "#{username}_vocabulary_current_item_no"

        if currentQuestionNo >= Object.keys(testItems).length
          robot.messageRoom "@#{username}", static_strings.en.test.out_of_questions
          userState.setInteractionStatus custom_types.interaction_status.test.out_of_questions

          robot.brain.set "#{username}_state", userState
          return

        currentTestItem = testItems[Object.keys(testItems)[currentQuestionNo - 1]]

        simplifiedAnswer = vocabularyTest.simplifyText answer if regex_patterns.common.latin_chars.test answer
        if simplifiedAnswer.includes vocabularyTest.simplifyText(currentTestItem.term)
          messageToSend += static_strings.en.test.correct_message + '\n'
        else
          if regex_patterns.stop.test answer
            robot.messageRoom "@#{username}", static_strings.en.test.goodbye
            userState.setInteractionStatus custom_types.interaction_status.test.want_to_stop

            robot.brain.set "#{username}_state", userState
            return

          messageToSend += sprintf(static_strings.en.test.incorrect_message, currentTestItem.term) + '\n'

        savedVocabularyItems = robot.brain.get "#{username}_vocabulary_items"
        nextIndex = Object.keys(savedVocabularyItems)[robot.brain.get "#{username}_vocabulary_current_item_no"]
        nextItem = savedVocabularyItems[nextIndex]

        robot.brain.set("#{username}_vocabulary_current_item_no",
                        robot.brain.get("#{username}_vocabulary_current_item_no") + 1)

        messageToSend += vocabularyTest.formatQuestion(nextItem) + '\n'

        robot.messageRoom("@#{username}", messageToSend) if messageToSend != ''
