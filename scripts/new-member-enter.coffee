module.exports = (robot) ->
	robot.enter (response) ->
     	robot.messageRoom '@' + response.message.user.name,
                'Hello ' + response.message.user.real_name + '\n' +
                'It\'s very nice to meet you! In order to know each other. I would like to introduce myself first.\n' +
                'My name is Maruko, let\'s call my Maruko chan or just Maruko o(^▽^)o\n' +
                'I\'m only 9 years old, but I\'m good at Japanese, so I will help you.\n' +
                'I live in Shizuoka, from my house, it\'s a place to enjoy good views of Mount Fuji!\n' +
                'Now let me know some information about you.\n' +
                'Which city do you live in?'
