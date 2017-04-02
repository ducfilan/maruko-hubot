sprintf          = require("sprintf-js").sprintf

static_strings   = require './common/static_strings'
constants        = require './common/constants'
http_request     = require './common/http_request'

module.exports = (robot) ->
  robot.enter (responser) ->
    responser.send sprintf static_strings.en.new_member.welcome, responser.message.user.real_name
    robot.messageRoom "@#{responser.message.user.name}",
                      sprintf static_strings.en.new_member.self_introduction, responser.message.user.real_name
