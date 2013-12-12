# Defines tasks to start Queue consumer Workers

namespace :worker do

  queues = ['email', 'stripe']

  require './lib/lynr'
  require './lib/lynr/logging'
  require './lib/lynr/worker'

  task :all do

    include Lynr::Logging

    workers = queues.map do |queue_name|
      Lynr::Worker.new("#{Lynr.env}.#{queue_name}")
    end

    pids = workers.map do |worker|
      fork &worker.method(:call)
    end

    [:TERM, :INT].each do |sig|
      Signal.trap(sig) do
        pids.each { |pid| Process.kill(:QUIT, pid) }
        log.info("`rake worker:all` told Workers to QUIT from #{sig}")
        Process.exit(0)
      end
    end

    Process.wait

  end

  desc 'Starts a Worker console using Pry'
  task :pry do
    require 'pry'

    ARGV.clear
    Pry.start
  end

end
