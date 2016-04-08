#!/usr/bin/env ruby

require 'optparse'

options = {}

opt_parser = OptionParser.new do |opt|  
  opt.banner = "Usage: ruptime.rb [--file] [file ...]"
  opt.separator  ""
  opt.separator  "Options"

  opt.on("-f", "--file [FILE]", "saves output to the specified filename.\n\t\t\t\t\tDefaults to 'ruptime.json'") do |file|
    options[:file] = file || "ruptime.json"
    puts "saving to file: #{options[:file]}"
    File.write(options[:file], uptime_json)
    exit
  end

  opt.on("-h","--help","prints this help message") do
    puts opt_parser
    exit
  end
end

def uptime_json
  uptime = `uptime`
  uptimeArray = uptime.chomp.split(", ")

  up_days = 0
  up_hours = 0
  up_minutes = 0

  # resultArray.length will change depending on the the actual uptime duration. See notes below
  # If the system has been on for longer than 24 hours:
  # => number of days take place of the hh:mm
  # => hh:mm gets separated into a subsequent array entry
  check_time = uptimeArray[0].split(" ")[0]

  # Get the load averages
  load_avgs = uptimeArray[-1].split(": ")[1].split(" ").map{ |i| i.to_f.to_s }

  # Get the number of users
  num_users = uptimeArray[-2].split(" ")[0]

# Notes:
# Different cases where the units of time vary
# 13:10  up 13 days,  4:30, 3 users, load averages: 1.29 1.34 1.33
# 15:51  up  2:37, 3 users, load averages: 14.40 8.22 4.08
# 13:15  up 30 secs, 3 users, load averages: 3.89 0.96 0.35
# 13:15  up 1 min, 3 users, load averages: 2.60 1.06 0.42
  
  # uptimeArray will vary in length depending on uptime reported
  if (uptimeArray.length == 3)
    # Case uptime has not exceeded 24 hours / 1 day
    up_info_array = uptimeArray[0].split(" ") # Contains uptime info until the first comma from uptime

    if (up_info_array.include?("min")) # Only minutes have been outputted.
      up_minutes = up_info_array[-2]
    elsif (up_info_array.find { |e| /sec/ =~ e })  # Corner case where uptime is executed before minute mark
      up_minutes = 1 # Round uptime to 1 minute. We can update this if greater granularity is required for seconds
    else # up_info_array contains uptime in Hours and minutes outputted as hh:mm
      up_hours = up_info_array[2].split(":")[0]
      up_minutes = up_info_array[2].split(":")[1]
    end

  elsif (uptimeArray.length == 4)
    # Case where uptime exceeds 24 hours
    up_days = up_info_array[2]
  else
    puts "We've encountered an unexpected scenario. Please email sann.c.chhan@gmail.com for assistance."
    exit
  end


  # Create the JSON with a heredoc
  json = <<EOS
{
  checkTime: "#{check_time}",
  days: "#{up_days}",
  hours: "#{up_hours}",
  minutes: "#{up_minutes}"
  users: "#{num_users}",
  loads: #{load_avgs}
}
EOS

  json
end

opt_parser.parse! 
puts uptime_json
uptime_json
