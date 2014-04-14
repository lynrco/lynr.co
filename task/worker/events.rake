# Defines tasks to start Event consumer Workers
namespace :lynr do

  namespace :worker do

    desc 'Start the Lynr event processors'
    task :events do

      require './lib/lynr'
      require './lib/lynr/events'
      require './lib/lynr/logging'

      Dir.glob(File.expand_path("#{Lynr.root}/lib/lynr/events/handler/**/*.rb", __FILE__)) { |task|
        require task
      }

      include Lynr::Logging

      @logger = Log4r::Logger.new('rake:lynr:worker:events')
      @logger.outputters << Log4r::StdoutOutputter.new("console", OPTS)

      events = Lynr.config('events').to_hash.map do |type, handlers|
        [type, handlers.map { |h| Lynr::Events::Handler.from(h) }]
      end

      count = ENV.fetch("lynr_workers_events", 1).to_i
      workers = (1..count).map do |n|
        consumer = Lynr::Events::Consumer.new
        events.each do |event|
          type, handlers = event
          handlers.each { |handler| consumer.add(type, handler) }
        end
        consumer
      end

      # `start_workers` is defined in the `lynr:worker` namespace
      start_workers(workers)

    end

  end

end
