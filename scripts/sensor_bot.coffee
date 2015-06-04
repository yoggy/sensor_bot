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
	robot.hear /(.*) (dht.*)$/i, (res) ->
		if res.message.room == room_name
			series = res.match[1] + '_' + res.match[2]
			cmd = './gruff_dht.rb'
			exec res, cmd, [series]

	robot.hear /(.*) pir$/i, (res) ->
		if res.message.room == room_name
			series = res.match[1] + '_pir'
			cmd = './gruff_pir.rb'
			exec res, cmd, [series]

	robot.hear /(.*) cds$/i, (res) ->
		if res.message.room == room_name
			series = res.match[1] + '_cds'
			cmd = './gruff_cds.rb'
			exec res, cmd, [series]

	robot.hear /(.*) door$/i, (res) ->
		if res.message.room == room_name
			series = res.match[1] + '_door'
			cmd = './gruff_door.rb'
			exec res, cmd, [series]

	robot.hear /(.*) net$/i, (res) ->
		if res.message.room == room_name
			series = res.match[1] + '_net'
			cmd = './gruff_net.rb'
			exec res, cmd, [series]

	robot.hear /office rtx1100$/i, (res) ->
		if res.message.room == room_name
			series = 'office_rtx1100'
			cmd = './gruff_rtx.rb'
			exec res, cmd, [series]

