util = require('util')
spawn = require('child_process').spawn
cronJob = require('cron').CronJob

room_name = "sensor"

module.exports = (robot) ->
	robot.hear /office dht11$/i, (msg) ->
		if msg.room == room_name
			cmd = spawn 'gruff_dht.rb', ['office_dht11']
			cmd.stdout.on 'data', (data) ->
				console.log("stdout : %s", data)
				msg.send data
			
