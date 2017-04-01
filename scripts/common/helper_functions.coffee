helper_functions = module.exports =
  randomNumber: (from, to) ->
    return -1 if from > to
    Math.floor(Math.random() * to) + from
