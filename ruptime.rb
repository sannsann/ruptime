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

def uptime_json(*input)
  
  if input.empty?
    uptime = `uptime`
  else
    uptime = input[0]
  end

  # Check if there was an empty result form `uptime` invoke. May occur if the ruptime.rb is not run on a UNIX platform
  if (uptime.strip.empty? || uptime.nil?)
    return -1
  end

  # Variables to be populated through parsing
  up_days = 0
  up_hours = 0
  up_minutes = 0
  num_users = 0

  begin
    # Get the load averages first. This portion of the string creates different cases between OS X and UNIX
    load_avgs = get_load_avgs(uptime)

    # Remove load averages from uptime result
    uptime = uptime.split(/load/).first.strip

    # Get the number of users
    num_users = get_num_users(uptime)

    # Cleave up remainder of uptime output and continue parsing
    uptimeArray = uptime.chomp.split(", ").reject { |c| c.strip.empty? }

    # Get the time of check; when uptime was invoked
    check_time = get_check_time(uptime)

    # Get the quantity of time system has been up
    qty_uptime = get_uptime_qty(uptime)

    # Parse qty_uptime for granularity
    uptime_hash = parse_uptime_qty(qty_uptime)

    # Populate proper variables from uptime_hash
    up_days = uptime_hash[:days]
    up_hours = uptime_hash[:hours]
    up_minutes = uptime_hash[:minutes]

  rescue
    puts "Uptime output may not have been formatted in an expected manner"
    puts "uptime: #{uptime}"
    return -1
  end
    # Create the JSON with a heredoc
    json = <<EOS
{
  "checkTime": "#{check_time}",
  "days": "#{up_days}",
  "hours": "#{up_hours}",
  "minutes": "#{up_minutes}",
  "users": "#{num_users}",
  "loads": #{load_avgs}
}
EOS
   
    json
end

def get_check_time(string)
  # string typical format: "16:29:43 up 23 days, 7:28, 1 user,"
  # Format of string should be such that it is the first entry from an `uptime` invoke.
  string.split("up").map { |x| x.strip }[0]
end

def get_num_users(string)
  # string typical format: "16:29:43 up 23 days, 7:28, 1 user,"
  string.split(',').map{ |x| x.strip }[-1].split(" ")[0]
end

def get_load_avgs(string)
  # string typical format:
  # => 16:29:43 up 23 days, 7:28, 1 user, load average: 0.13, 0.13, 0.14 (UNIX, note presence of commas in load avgs)
  # => 16:45 up 1 day, 3:31, 4 users, load averages: 2.69 7.92 5.87 (OS X, note lack of commas in load avgs)
  string[string.index('load')..-1].gsub(',', ' ').split(" ").map{ |i| i.to_f.to_s }[2..-1]
end

def get_uptime_qty(string)
  # string typical format:
  # => 16:29:43 up 23 days, 7:28, 1 user, load average: 0.13, 0.13, 0.14
  regexp_num_users = /[\d]*\suser[s]?,/

  left_boundary = string.index('up') + 'up '.length
  right_boundary = string.index(regexp_num_users) - 3

  # puts string[left_boundary..right_boundary]
  string[left_boundary..right_boundary].strip  
end

# Parses the input string into granules of time
def parse_uptime_qty(string)
  # string typical format: 23 days, 7:28
  result = {}

  # Parse for the number of days
  if (string =~ /day[s]?/)
    result[:days] = string.split(/day[s]/)[0].strip
  else
    result[:days] = "0"
  end

  # Look for presence of hh:mm pattern
  clock_time_index = string =~ /[\d]+:[\d]+/
  if (clock_time_index)
    clock_time = string[clock_time_index..-1]

    result[:hours] = clock_time.split(":")[0]
    result[:minutes] = clock_time.split(":")[1]
  else
    result[:hours] = "0"
  end

  # string = string.split(", ")[1]

  min_time_index = string =~ /[\d]+\smin[s]?/
  if (min_time_index)
    string = string[min_time_index..-1]
    string = string.split(" ")[0]

    result[:minutes] = string
  end

  sec_time_index = string =~ /[\d]+\ssec[s]?/
  if (sec_time_index)
    result[:minutes] = "1"
  end

  result
end

opt_parser.parse! 
puts uptime_json
uptime_json
