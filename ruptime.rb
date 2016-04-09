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

    # Clean up remainder of uptime output and continue parsing
    uptimeArray = uptime.chomp.split(", ").reject { |c| c.strip.empty? }

    # Get the time of check; when uptime was invoked
    check_time = get_check_time(uptime)

    # Parse data bef 
    up_info_array = uptimeArray[0].split
    
    # resultArray.length will change depending on the the actual uptime duration. See notes below
    # If the system has been on for longer than 24 hours:
    # => number of days take place of the hh:mm
    # => hh:mm gets separated into a subsequent array entry

    if (uptimeArray.length == 2)
      # Case uptime has not exceeded 24 hours / 1 day
      if (up_info_array.find { |e| /min/ =~ e }) 
      # Only minutes have been outputted.
        up_minutes = up_info_array[-2]
      elsif (up_info_array.find { |e| /sec/ =~ e })  
      # Corner case where uptime is executed before minute mark
      # Round uptime to 1 minute. We can update this if greater granularity is required for seconds
        up_minutes = 1 
      else # up_info_array contains uptime in hours and minutes outputted as hh:mm
        up_hours = up_info_array[2].split(":")[0]
        up_minutes = up_info_array[2].split(":")[1]
      end

    elsif (uptimeArray.length == 3)
      # Case where uptime exceeds 24 hours
      up_days = up_info_array[2]

      if (uptimeArray[1].split.find{ |e| /:/ =~ e })
        up_hours = uptimeArray[1].split(":")[0].strip
        up_minutes = uptimeArray[1].split(":")[1].strip
      elsif (uptimeArray[1].split.find{ |e| /min/ =~ e })
        up_minutes = uptimeArray[1].split(" ")[0]
      end
    end

  rescue
    puts "something happened"
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
  string.split(" ")[0]
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

opt_parser.parse! 
puts uptime_json
uptime_json
