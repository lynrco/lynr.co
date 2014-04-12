namespace :lynr do

  namespace :worker do

    desc 'Start the Lynr event processors'
    task :events do

      require './lib/lynr'
      require './lib/lynr/events'

      include Lynr::Logging

      @logger = Log4r::Logger.new('rake:lynr:worker:events')
      @logger.outputters << Log4r::StdoutOutputter.new("console", OPTS)

      count = ENV.fetch("lynr_workers_events", 1).to_i
      workers = (1..count).map do |n|
        Lynr::Events::Consumer.new
      end

      pids = workers.flatten.map do |worker|
        fork &worker.method(:call)
      end

      [:TERM, :INT].each do |sig|
        Signal.trap(sig) do
          pids.each { |pid| Process.kill(:QUIT, pid) }
          log.info("told `Events::Consumer`s to QUIT from #{sig}")
          Process.exit(0)
        end
      end

      Process.wait

    end

  end

end
