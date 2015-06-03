#
# scripts/sensor_bot.coffee
#
util = require('util')
spawn = require('child_process').spawn
cronJob = require('cron').CronJob

room_name = "sensor"

exec = (res, cmd, args) ->
	console.log "exec : cmd=" + cmd + ", args=" + util.inspect(args)
	p = spawn cmd, args
	console.log p
	p.stdout.on 'data', (data) ->
		str = data.toString 'UTF-8'  # Buffer -> String
		console.log "stdout : %s", str
		res.send str

module.exports = (robot) ->
	robot.hear /office (dht.*)$/i, (res) ->
		if res.message.room == room_name
			series = 'office_' + res.match[1]
			cmd = './gruff_dht.rb'
			exec res, cmd, [series]

	robot.hear /home (dht.*)$/i, (res) ->
		if res.message.room == room_name
			series = 'home_' + res.match[1]
			cmd = './gruff_dht.rb'
			exec res, cmd, [series]


