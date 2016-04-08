# ruptime

ruptime is a Ruby wrapper for the `uptime` UNIX command.

Returns a JSON of the various information outputted by uptime.

ruptime options:
 - -f, --file [file ...]
   * Outputs the JSON to the file name specified. Defaults to `ruptime.json` if no file name is specified.
 - -h, --help
   * Displays the help menu.

JSON keys include:
 - checkTime - The time at which `uptime` was invoked.
 - days - Number of days the system has been up.
 - hours - Number of hours the system has been up. Note: this is not total hours but number of hours that have not yet summed to another day.
 - minutes - Number of minutes the system has been up. Same note as hours.
 - users - Number of users.
 - loads - An array containing the average loads from the previous 1, 5, and 15 minutes.
