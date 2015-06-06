#
# scripts/sensor_bot.coffee
#
util = require('util')
spawn = require('child_process').spawn
cron = require('cron').CronJob

room_name = "sensor"

exec = (res, cmd, args) ->
	console.log "exec : cmd=" + cmd + ", args=" + util.inspect(args)
	p = spawn cmd, args
	p.stdout.on 'data', (data) ->
		str = data.toString 'UTF-8'  # Buffer -> String
		console.log "stdout : %s", str
		res.send str

cron_exec = (robot, cmd, args) ->
	console.log "cron_exec : cmd=" + cmd + ", args=" + util.inspect(args)
	p = spawn cmd, args
	p.stdout.on 'data', (data) ->
		str = data.toString 'UTF-8'  # Buffer -> String
		console.log "stdout : %s", str
		robot.send {room:room_name}, str

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

	robot.hear /office (rtx.*)$/i, (res) ->
		if res.message.room == room_name
			series = 'office_' + res.match[1]
			cmd = './gruff_rtx.rb'
			exec res, cmd, [series]

	robot.hear /office (nvr.*)$/i, (res) ->
		if res.message.room == room_name
			series = 'office_' + res.match[1]
			cmd = './gruff_rtx.rb'
			exec res, cmd, [series]

	robot.hear /office (backup*)$/i, (res) ->
		if res.message.room == room_name
			series = 'office_' + res.match[1]
			cmd = './gruff_backup.rb'
			exec res, cmd, [series]

	new cron '0 0 9,21 * * *', ()->
			cron_exec robot, './gruff_net.rb', ['office_net']
		, null, true, "Asia/Tokyo"

	new cron '0 1 9,21 * * *', ()->
			cron_exec robot, './gruff_rtx.rb', ['office_nvr500']
		, null, true

	new cron '0 2 9,21 * * *', ()->
			cron_exec robot, './gruff_rtx.rb', ['office_rtx1100']
		, null, true, "Asia/Tokyo"

	new cron '0 3 9,21 * * *', ()->
			cron_exec robot, './gruff_door.rb', ['office_door']
		, null, true, "Asia/Tokyo"

	new cron '0 4 9,21 * * *', ()->
			cron_exec robot, './gruff_pir.rb', ['office_pir']
		, null, true, "Asia/Tokyo"

	new cron '0 5 9,21 * * *', ()->
			cron_exec robot, './gruff_backup.rb', ['office_backup']
		, null, true, "Asia/Tokyo"

	new cron '0 0 22 * * *', ()->
			cron_exec robot, './gruff_pir.rb', ['home_door']
		, null, true

	new cron '0 1 22 * * *', ()->
			cron_exec robot, './gruff_pir.rb', ['home_pir']
		, null, true

