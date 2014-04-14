# Defines tasks to start Queue consumer Workers
namespace :lynr do

  namespace :worker do

    queues = ['job']

    desc 'Starts the Lynr queue processors'
    task :queues do

      require './lib/lynr'
      require './lib/lynr/logging'
      require './lib/lynr/worker'

      include Lynr::Logging

      @logger = Log4r::Logger.new('rake:lynr:worker:queues')
      @logger.outputters << Log4r::StdoutOutputter.new("console", OPTS)

      workers = queues.map do |queue_name|
        count = ENV.fetch("lynr_workers_#{queue_name}", 1).to_i
        (1..count).map do |n|
          Lynr::Worker::Job.new("#{Lynr.env}.#{queue_name}")
        end
      end

      # `start_workers` is defined in the `lynr:worker` namespace
      start_workers(workers)

    end

  end

end
