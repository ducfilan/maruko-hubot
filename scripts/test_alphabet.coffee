# Commands:
#   @maruko test alphabet hiragana - Test randomly Japanese character in Hiragana.
#   @maruko test alphabet katakana - Test randomly Japanese character in Katakana.

sprintf          = require("sprintf-js").sprintf

api_urls         = require './common/api_urls'
http_request     = require './common/http_request'
static_strings   = require './common/static_strings'
helper_functions = require './common/helper_functions'
custom_types     = require './common/custom_types'
regex_patterns   = require './common/regex_patterns'

UserState        = require './model/user_state'

class AlphabetTest
  constructor: (@baseApiUrl) ->

  takeRandomLetterItem: (callback) ->
    filterDataPart = '?shallow=true'
    apiUrl = @baseApiUrl + filterDataPart

    self = this
    http_request.getData apiUrl, (jsonData) ->
      numberOfTotalLetters = Object.keys(jsonData)?.length || -1
      randomPosition = helper_functions.randomNumber 1, numberOfTotalLetters

      filterDataPart = '?orderBy="id"&equalTo=' + randomPosition
      apiUrl = self.baseApiUrl + filterDataPart
      http_request.getData apiUrl, (jsonData) ->
        callback jsonData

  isAnswering: (interactionType, interactionStatus) ->
    (
      interactionType == custom_types.interaction.test.alphabet.hiragana or
      interactionType == custom_types.interaction.test.alphabet.katakana
    ) and
    interactionStatus == custom_types.interaction_status.test.not_answered

module.exports = (robot) ->
  robot.respond regex_patterns.test.alphabet, (responser) ->
    username = responser.message.user.name
    userRequestQuery = responser.match[0]
    selectedTestKind = responser.match[1]

    robot.brain.set "#{username}_state",
                    new UserState(username,
                                  custom_types.interaction.test.alphabet[selectedTestKind],
                                  custom_types.interaction_status.test.not_answered)

    robot.brain.set "#{username}_request_query", userRequestQuery
    robot.brain.set "#{username}_last_selected_test_kind", selectedTestKind

    responser.send static_strings.en.test.alphabet.notice

    alphabet = new AlphabetTest api_urls.alphabet

    alphabet.takeRandomLetterItem (item) ->
      letter = item[Object.keys(item)[0]]
      robot.messageRoom "@#{username}",
                        sprintf(static_strings.en.test.alphabet.ask_a_letter,
                                username,
                                letter[selectedTestKind])
      robot.brain.set "#{username}_last_question_answer", letter['romaji']

  robot.hear regex_patterns.anything, (responser) ->
    username = responser.message.user.name
    answer = responser.match[1]

    return if answer == robot.brain.get("#{username}_request_query")

    userState = robot.brain.get "#{username}_state" || null
    if userState != null
      messageToSend = ''
      alphabet = new AlphabetTest api_urls.alphabet
      interactionType   = userState.getInteractionType()
      interactionStatus = userState.getInteractionStatus()

      if alphabet.isAnswering interactionType, interactionStatus
        if answer.includes robot.brain.get("#{username}_last_question_answer")
          messageToSend += static_strings.en.test.correct_message + '\n'
        else
          if regex_patterns.stop.test answer
            robot.messageRoom "@#{username}", static_strings.en.test.goodbye
            userState.setInteractionStatus custom_types.interaction_status.test.want_to_stop

            robot.brain.set "#{username}_state", userState
            return

          messageToSend += sprintf(static_strings.en.test.incorrect_message,
                                   robot.brain.get "#{username}_last_question_answer") + '\n'

        alphabet.takeRandomLetterItem (item) ->
          letter = item[Object.keys(item)[0]]

          messageToSend += sprintf(static_strings.en.test.alphabet.ask_a_letter,
                                   username,
                                   letter[robot.brain.get "#{username}_last_selected_test_kind"])

          robot.messageRoom("@#{username}", messageToSend) if messageToSend != ''

          robot.brain.set "#{username}_last_question_answer", letter['romaji']
