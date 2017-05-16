require_relative 'lib/event_query'
require 'yaml'

config     = YAML.load_file('config.yml')
ts_file    = config['timestamp_file']

start_time = YAML.load_file(ts_file)['last_time']
end_time   = Time.now.utc

eq = EventQuery.new(config)
puts eq.event_log(start_time, end_time)
File.write(ts_file, {'last_time' => end_time}.to_yaml)

### Sample timestamp.yml:
# ---
# last_time: 2016-01-01 00:00:00 Z

