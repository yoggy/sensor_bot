#!/usr/bin/ruby
# -*- encoding: utf-8 -*-
#
# gruff_test.rb - create line charts & upload images to gyazo
#
#   $ sudo apt-get install rmagic libmagickcore-dev libmagickwand-dev
#   $ sudo gem install gruff
#   $ gem install gyazo
#
require 'rubygems'
require 'influxdb'
require 'gruff'
require 'gyazo'

# configure
influxdb_params = {
    :host     => 'influxdb.local',
    :username => 'user',
    :password => 'password',
}
database = 'sensorsdb'

influxdb = InfluxDB::Client.new(database, influxdb_params)


def usage
	puts "usage : #{$0} series_name"
	exit 0
end
usage if ARGV.size == 0
	
series_name = ARGV[0]
column_name = "cds"

query_str = "select time, max(#{column_name}) as #{column_name} from #{series_name} group by time(10m) where time > now() - 3d order asc"

gyazo = Gyazo::Client.new

#
# draw temperature line chart
#
g = Gruff::Line.new("640x360")
g.title = "series:" + series_name
g.title_font_size = 20
g.hide_dots = true
g.line_width = 3
g.marker_font_size = 14
g.legend_font_size = 14
#g.minimum_value = 0
#g.maximum_value = 1023
#g.y_axis_increment = 200
g.theme = {
	:colors =>  %w(#ff8800),
	:font_color => 'black',
	:marker_color => 'black',
	:background_colors => %w(white white)
}

idx = 0;
arr = []
influxdb.query query_str do |name, res|
  res.each do |h|
	t = Time.at(h["time"])
	if t.hour == 0 && t.min == 0
	  g.labels[idx] = Time.at(h["time"]).strftime("%m/%d")
	elsif t.hour % 12 == 0 && t.min == 0
	  g.labels[idx] = Time.at(h["time"]).strftime("%H")
	else
	  g.labels[idx] = " "
    end
    arr << h[column_name].round(2)
	idx += 1
  end
end
g.data column_name.to_sym, arr
g.write(".#{column_name}.png");
url = gyazo.upload(".#{column_name}.png", :raw => true);
puts url + ".png"

