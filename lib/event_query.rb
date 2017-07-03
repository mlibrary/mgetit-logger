require 'mysql2'
require 'json'

class EventQuery
  attr_reader :config

  def initialize(config = {})
    @config = database_defaults.merge config
  end

  def event_log(start_time, end_time)
    events(start_time, end_time).each do |event|
      fix_dates(event)
      yield serialize(event)
    end
  end

  # None of the attempts to get the JSON or Oj gems to render the dates
  # as proper ISO8601 strings worked, so we force it with this hack.
  def fix_dates(event)
    if event['request_time']
      event['request_time'] = event['request_time'].iso8601
    end
    if event['click_time']
      event['click_time'] = event['click_time'].iso8601
    end
  end

  def serialize(data)
    JSON.dump data
  end

  def events(start_time, end_time)
    between(start_time, end_time)
  end

  def between(start_time, end_time)
    client.query(between_query(mysql_time(start_time), mysql_time(end_time)), stream: true, cache_rows: false)
  end

  def mysql_time(time)
    time.utc.strftime("%Y-%m-%d %H:%M:%S")
  end

  def between_query(start_time, end_time)
    ALL_EVENTS + " WHERE c.created_at >= '#{client.escape(start_time)}' AND c.created_at < '#{client.escape(end_time)}'"
  end

  ALL_EVENTS =<<~EOQ
    SELECT
    req.id request_id, req.session_id, req.referrer_id, req.client_ip_addr,
    ref.id referrent_id, ref.title, ref.issn, ref.year, ref.volume,
    sr.id service_response_id, sr.service_id, sr.service_type_value_name,
    req.created_at request_time, c.created_at click_time
    FROM clickthroughs c
    INNER JOIN service_responses sr ON c.service_response_id = sr.id
    INNER JOIN requests req ON c.request_id = req.id
    INNER JOIN referents ref ON req.referent_id = ref.id
  EOQ

  def client
    @client ||= Mysql2::Client.new(config)
  end

  def database_defaults
    {
      host: 'localhost', username: 'root', database: 'mgetit',
      database_timezone: :utc, application_timezone: :local, stream: true
    }
  end
end

