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

query_str = "select time, mean(temperature) as temperature, mean(humidity) as humidity from #{series_name} group by time(180m) where time > now() - 7d order asc"

gyazo = Gyazo::Client.new

#
# draw temperature line chart
#
g = Gruff::Line.new("640x240")
g.title = "series:" + series_name
g.title_font_size = 20
g.dot_radius = 2
g.line_width = 2
g.marker_font_size = 16
g.legend_font_size = 16
g.theme = {
	:colors =>  %w(orange),
	:font_color => 'black',
	:marker_color => 'black',
	:background_colors => %w(white white)
}

idx = 0;
arr = []
influxdb.query query_str do |name, res|
  res.each do |h|
	t = Time.at(h["time"])
	if t.hour == 0
	  g.labels[idx] = Time.at(h["time"]).strftime("%m/%d")
	elsif
	  g.labels[idx] = " "
    end
    arr << h["temperature"].round(2)
	idx += 1
  end
end
g.data :temperature, arr
g.minimum_value = arr.min.round() - 1
g.maximum_value = arr.max.round() + 1
g.y_axis_increment = 1 
g.write("temperature.png");
url = gyazo.upload("temperature.png", :raw => true);
puts url + ".png"

#
# draw humidity line chart
#
g = Gruff::Line.new("640x240")
g.title = "series:" + series_name
g.title_font_size = 20
g.dot_radius = 2
g.line_width = 2
g.marker_font_size = 16
g.legend_font_size = 16
g.theme = {
	:colors =>  %w(cyan),
	:font_color => 'black',
	:marker_color => 'black',
	:background_colors => %w(white white)
}

idx = 0;
arr = []
influxdb.query query_str do |name, res|
  res.each do |h|
	t = Time.at(h["time"])
	if t.hour == 0
	  g.labels[idx] = Time.at(h["time"]).strftime("%m/%d")
	elsif
	  g.labels[idx] = " "
    end
    arr << h["humidity"].round(2)
	idx += 1
  end
end
g.data :humidity, arr
g.write("humidity.png");
url = gyazo.upload("humidity.png", :raw => true);
puts "#{series_name} : #{url}.png"

