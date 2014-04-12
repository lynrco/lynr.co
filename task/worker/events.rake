# Defines tasks to start Event consumer Workers
namespace :lynr do

  namespace :worker do

    desc 'Start the Lynr event processors'
    task :events do

      require './lib/lynr'
      require './lib/lynr/events'
      require './lib/lynr/logging'

      include Lynr::Logging

      @logger = Log4r::Logger.new('rake:lynr:worker:events')
      @logger.outputters << Log4r::StdoutOutputter.new("console", OPTS)

      count = ENV.fetch("lynr_workers_events", 1).to_i
      workers = (1..count).map do |n|
        Lynr::Events::Consumer.new
      end

      # `start_workers` is defined in the `lynr:worker` namespace
      start_workers(workers)

    end

  end

end
