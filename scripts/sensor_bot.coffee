#
# scripts/sensor_bot.coffee
#
util = require('util')
spawn = require('child_process').spawn
cronJob = require('cron').CronJob

room_name = "sensor"

exec = (msg, cmd, args) ->
	p = spawn cmd, args
	p.stdout.on 'data', (data) ->
		str = data.toString 'UTF-8'  # Buffer -> String
		console.log("stdout : %s", str)
		msg.send str

module.exports = (robot) ->
	robot.hear /office dht11$/i, (msg) ->
		if msg.message.room == room_name
			#console.log(util.inspect(msg))
			exec msg, './gruff_dht.rb', ['office_dht11']


