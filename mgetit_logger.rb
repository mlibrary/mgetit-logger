require_relative 'lib/event_query'
require 'yaml'
require 'time'

# Set up configs
config = {}
config_file = File.join(__dir__, 'config.yml')
if File.exist?(config_file)
  config = YAML.load_file(config_file)
end

db_file = config['database_file'] || 'database.yml'
ts_file = config['timestamp_file'] || 'timestamp.yml'

db_config = {}
if File.exist?(db_file)
  db_config = YAML.load_file(db_file)
end

last_time = nil
if File.exist?(ts_file)
  last_time = YAML.load_file(ts_file)['last_time']
end


# Set boundary times, run query, and log events to standard output
start_time = last_time || Time.parse('2016-01-01 00:00:00 Z')
end_time   = Time.now.utc

eq = EventQuery.new(db_config)
puts eq.event_log(start_time, end_time)
File.write(ts_file, {'last_time' => end_time}.to_yaml)

