require_relative "ruptime"
require 'json'

puts "Case: uptime (OS X) invokation returns an empty response from the shell. Error caught."
uptime = uptime_json("")
puts uptime == -1
puts

puts "Case: uptime invokation returns a non-standard response from the shell. Error caught."
uptime = uptime_json("No command 'uptime' recognized.")
puts uptime == -1
puts

puts "Case: uptime exceeds 1 day. (OS X)"
# Setup
uptime = uptime_json("13:10  up 13 days,  4:30, 3 users, load averages: 1.29 1.34 1.33")
result = JSON.parse(uptime)

# Tests
puts result["checkTime"] == "13:10" 
puts result["days"] == "13"
puts result["hours"] == "4"
puts result["minutes"] == "30"
puts result["users"] == "3"
puts result["loads"].eql? ["1.29", "1.34", "1.33"]
puts

puts "Case: uptime does not exceed 1 day."
# Setup
uptime = uptime_json("15:51  up  2:37, 3 users, load averages: 14.40 8.22 4.08")
result = JSON.parse(uptime)

# Tests
puts result["days"] == "0"
puts result["hours"] == "2"
puts result["minutes"] == "37"

# Testing incorrect results
puts result["days"] != "1"
puts

puts "Case: uptime does not exceed one hour. Has minute values"
uptime = uptime_json("13:15  up 1 min, 3 users, load averages: 2.60 1.06 0.42")
result = JSON.parse(uptime)

# Tests
puts result["days"] == "0"
puts result["hours"] == "0"
puts result["minutes"] == "1"

# Testing incorrect results
puts result["days"] != "1"
puts result["hours"] != "10"
puts

puts "Case: uptime does not exceed 1 minute. The key minute will output to nearest full minute."
uptime = uptime_json("13:15  up 30 secs, 3 users, load averages: 3.89 0.96 0.35")
result = JSON.parse(uptime)

# Tests
puts result["minutes"] == "1"

# Test incorrect results
puts result["minutes"] != "0"
puts

puts "Case: uptime outputs to file - file name unspecified"
`ruby ruptime.rb -f`
puts File.exist?('./ruptime.json')
`rm ruptime.json`
puts

puts "Case: uptime outputs to file - file name specified"
`ruby ruptime.rb -f test.json`
puts File.exist?('./test.json')
puts !File.exist?('./text.json')
`rm test.json`
puts

puts "Case: uptime, UNIX (Ubuntu)"
# Setup
uptime = uptime_json("16:29:43 up 23 days, 7:28, 1 user, load average: 0.13, 0.13, 0.14")
result = JSON.parse(uptime)

# Tests
puts result["days"] == "23"
puts result["hours"] == "7"
puts result["minutes"] == "28"
puts result["users"] == "1"
puts result["loads"].eql? ["0.13", "0.13", "0.14"]

# Test incorrect results
puts result["days"] != "0"
puts result["hours"] != "0"
puts result["minutes"] != "0"
puts result["users"] != "0"
puts !result["loads"].eql?(["0.00", "0.00", "0.00"])