require 'mysql2'
require 'json'

class EventQuery
  def initialize(config = nil)
    configure(config) if config
  end

  def event_log(start_time, end_time)
    events(start_time, end_time).map do |event|
      serialize(event)
    end
  end

  def serialize(data)
    JSON.dump data
  end

  def events(start_time, end_time)
    between(start_time, end_time)
  end

  def between(start_time, end_time)
    between_query.execute(start_time, end_time)
  end

  def between_query
    @query ||= client.prepare(ALL_EVENTS + " WHERE c.created_at >= ? AND c.created_at < ? ")
  end

  ALL_EVENTS =<<~EOQ
    SELECT
    req.id request_id, req.referrer_id, req.client_ip_addr,
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

  def config
    @config ||= {host: 'localhost', username: 'root', database: 'mgetit'}
  end

  private
  
    def configure(config)
      @config = config['database']
    end
end

