# Commands:
#   @maruko test general lesson n - Test general questions in lesson number n.

sprintf          = require("sprintf-js").sprintf

api_urls         = require './common/api_urls'
http_request     = require './common/http_request'
static_strings   = require './common/static_strings'
helper_functions = require './common/helper_functions'
custom_types     = require './common/custom_types'
regex_patterns   = require './common/regex_patterns'

UserState        = require './model/user_state'

class GenralTest
  constructor: (@baseApiUrl) ->

  takeTestItemsInLesson: (lessonNo, callback) ->
    filterDataPart = '?orderBy="lessonNo"&equalTo=' + lessonNo
    apiUrl = @baseApiUrl + filterDataPart

    self = this
    http_request.getData apiUrl, (jsonData) ->
      callback jsonData

  formatQuestion: (item) ->
    formatedQuestion  = "*#{item.question.replace('<br/>', '*\n*')}*\n" +
                        "1. #{item.answera}\n" +
                        "2. #{item.answerb}\n"
    formatedQuestion += "3. #{item.answerc}\n" if item.answerc != undefined
    formatedQuestion += "4. #{item.answerd}\n" if item.answerd != undefined

    formatedQuestion

  isAnswering: (interactionType, interactionStatus) ->
    interactionType == custom_types.interaction.test.general and
    interactionStatus == custom_types.interaction_status.test.not_answered

module.exports = (robot) ->
  robot.respond regex_patterns.test.general, (responser) ->
    username = responser.message.user.name
    [userRequestQuery, selectedTestLesson] = [responser.match[0], responser.match[1]]

    robot.brain.set "#{username}_state",
                    new UserState username,
                                  custom_types.interaction.test.general,
                                  custom_types.interaction_status.test.not_answered

    robot.brain.set "#{username}_request_query", userRequestQuery
    robot.brain.set "#{username}_last_selected_test_lesson", selectedTestLesson

    responser.send static_strings.en.test.general.notice

    generalTest = new GenralTest api_urls.general_questions

    generalTest.takeTestItemsInLesson selectedTestLesson, (items) ->
      robot.brain.set "#{username}_test_general_items", items
      robot.brain.set "#{username}_test_general_current_question_no", 1

      firstItem = items[Object.keys(items)[0]]
      robot.messageRoom "@#{username}", generalTest.formatQuestion firstItem

  robot.hear regex_patterns.anything, (responser) ->
    username = responser.message.user.name
    answer = responser.match[1]

    return if answer == robot.brain.get "#{username}_request_query"

    userState = robot.brain.get "#{username}_state" || null
    if userState != null
      messageToSend = ''
      generalTest = new GenralTest api_urls.general_questions
      [interactionType, interactionStatus]   = [userState.getInteractionType(), userState.getInteractionStatus()]

      if generalTest.isAnswering interactionType, interactionStatus
        testItems = robot.brain.get "#{username}_test_general_items"
        currentQuestionNo = robot.brain.get "#{username}_test_general_current_question_no"

        if currentQuestionNo >= Object.keys(testItems).length
          robot.messageRoom "@#{username}", static_strings.en.test.out_of_questions
          userState.setInteractionStatus custom_types.interaction_status.test.out_of_questions

          robot.brain.set "#{username}_state", userState
          return

        currentTestItem = testItems[Object.keys(testItems)[currentQuestionNo - 1]]

        if answer.includes currentTestItem.correct
          messageToSend += static_strings.en.test.correct_message + '\n'
        else
          if regex_patterns.stop.test answer
            robot.messageRoom "@#{username}", static_strings.en.test.goodbye
            userState.setInteractionStatus custom_types.interaction_status.test.want_to_stop

            robot.brain.set "#{username}_state", userState
            return

          messageToSend += sprintf(static_strings.en.test.incorrect_message, currentTestItem.correct) + '\n'

        savedTestItems = robot.brain.get "#{username}_test_general_items"
        nextItem = savedTestItems[Object.keys(savedTestItems)[robot.brain.get "#{username}_test_general_current_question_no"]]

        robot.brain.set("#{username}_test_general_current_question_no",
                        robot.brain.get("#{username}_test_general_current_question_no") + 1)

        messageToSend += generalTest.formatQuestion(nextItem)

        robot.messageRoom("@#{username}", messageToSend) if messageToSend != ''
