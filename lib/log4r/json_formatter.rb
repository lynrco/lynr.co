require 'singleton'
require 'log4r/base'
require 'yajl/json_gem'

module Log4r

  ##
  # `Log4r::Formatter` which logs information as a block of pretty printed
  # JSON. Accepts a hash of parameters, all optional.
  #
  # * `date_pattern`, passed to `Time.now.strftime` to create the timestamp
  #   Defaults to ISO-8601 ("%Y-%m-%d %H:%M:%S")
  # * `info`, hash to be merged with data from Log4r::LogEvent`
  #   Defaults to a value which skips merging
  class JsonFormatter < Log4r::BasicFormatter

    # default date format
    ISO8601 = "%Y-%m-%d %H:%M:%S"

    # TODO: Figure out a way to configure what data shows up
    def initialize(hash={})
      super(hash)
      @opts = hash
      @info = (@opts['info'] or @opts[:info] or false)
      @date_pattern = (hash['date_pattern'] or hash[:date_pattern] or ISO8601)
    end

    def format(event)
      info = {
        level: Log4r::LNAMES[event.level],
        time: format_date,
        context: event.fullname,
        pid: Process.pid,
        data: event.data
      }
      info = @info.merge(info) { |key,old_val,new_val| [old_val, new_val] } if @info
      JSON.pretty_generate(info) << "\n"
    end

    def format_date
      Time.now.strftime @date_pattern
    end

  end

end
