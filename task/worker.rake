# Defines tasks to start Queue consumer Workers

namespace :lynr do

  queues = ['job']

  desc 'Starts the Lynr queue processors'
  task :workers do

    require './lib/lynr'
    require './lib/lynr/logging'
    require './lib/lynr/worker'

    include Lynr::Logging

    workers = queues.map do |queue_name|
      Lynr::Worker::Job.new("#{Lynr.env}.#{queue_name}")
    end

    pids = workers.map do |worker|
      fork &worker.method(:call)
    end

    [:TERM, :INT].each do |sig|
      Signal.trap(sig) do
        pids.each { |pid| Process.kill(:QUIT, pid) }
        log.info("`rake lynr:workers` told Workers to QUIT from #{sig}")
        Process.exit(0)
      end
    end

    Process.wait

  end

end
