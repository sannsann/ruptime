require_relative "ruptime"

uptime = "16:29:43 up 23 days, 7:28, 1 user, load average: 0.13, 0.13, 0.14"
uptime_qty = get_uptime_qty(uptime)
puts uptime_qty == "23 days, 7:28"

uptime_hash = parse_uptime_qty(uptime_qty)
puts uptime_hash[:days] == "23"
puts uptime_hash[:hours] == "7"
puts uptime_hash[:minutes] == "28"

uptime = "13:10  up 13 days, 4:30, 3 users, load averages: 1.29 1.34 1.33"
uptime_qty = get_uptime_qty(uptime)
puts uptime_qty == "13 days, 4:30"

uptime_hash = parse_uptime_qty(uptime_qty)
puts uptime_hash[:days] == "13"
puts uptime_hash[:hours] == "4"
puts uptime_hash[:minutes] == "30"

uptime = "15:51  up  2:37, 3 users, load averages: 14.40 8.22 4.08"
uptime_qty = get_uptime_qty(uptime)
puts uptime_qty == "2:37"

uptime_hash = parse_uptime_qty(uptime_qty)
puts uptime_hash[:days] == "0"
puts uptime_hash[:hours] == "2"
puts uptime_hash[:minutes] == "37"

uptime = "13:15  up 30 secs, 3 users, load averages: 3.89 0.96 0.35"
uptime_qty = get_uptime_qty(uptime)
puts uptime_qty == "30 secs"

uptime_hash = parse_uptime_qty(uptime_qty)
puts uptime_hash[:days] == "0"
puts uptime_hash[:hours] == "0"
puts uptime_hash[:minutes] == "1"


uptime = "13:15  up 1 min, 3 users, load averages: 2.60 1.06 0.42"
uptime_qty = get_uptime_qty(uptime)

puts uptime_qty == "1 min"

uptime_hash = parse_uptime_qty(uptime_qty)
puts uptime_hash[:days] == "0"
puts uptime_hash[:hours] == "0"
puts uptime_hash[:minutes] == "1"