module.exports = class UserState
  constructor: (@username, @interactionType, @interactionStatus) ->

  getInteractionType: ->
    @interactionType

  getInteractionStatus: ->
    @interactionStatus

  setInteractionStatus: (@interactionStatus) ->

  setInteractionType: (@interactionType) ->
