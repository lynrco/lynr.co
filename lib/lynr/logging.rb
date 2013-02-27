require 'log4r'
require './lib/log4r/json_formatter'

module Lynr

  # Based on code from https://gist.github.com/mindscratch/1145954
  module Logging

    FORMATTER = Log4r::JsonFormatter.new
    OPTS = { formatter: FORMATTER }
    
    # Get an instance to a logger configured for the class that includes it.
    # This allows log messages to include the class name
    def log
      return @logger if @logger
      
      @logger = Log4r::Logger.new(self.class.name)
      @logger.outputters << Log4r::StdoutOutputter.new("console", OPTS)
      if (ENV['logfile'])
        opts = OPTS.merge({ filename: ENV['logfile'] })
        @logger.outputters << Log4r::FileOutputter.new("file", opts)
      end
   
      @logger
     end
  end

end
