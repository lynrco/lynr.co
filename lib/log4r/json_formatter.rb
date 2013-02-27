require 'singleton'
require 'log4r/base'
require 'yajl/json_gem'

module Log4r

  class JsonFormatter < Log4r::BasicFormatter

    # default date format
    ISO8601 = "%Y-%m-%d %H:%M:%S"

    # TODO: Figure out a way to configure what data shows up
    # TODO: Figure out how to merge block data with info
    def initialize(hash={})
      super(hash)
      @opts = hash
      @date_pattern = (hash['date_pattern'] or hash[:date_pattern] or ISO8601)
    end

    def format(event)
      info = {
        level: Log4r::LNAMES[event.level],
        time: format_date,
        context: event.fullname,
        pid: Process.pid.to_s,
        data: event.data
      }
      JSON.pretty_generate(info) << "\n"
    end

    def format_date
      Time.now.strftime @date_pattern
    end

  end

end
