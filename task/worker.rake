namespace :lynr do

  namespace :worker do

    def start_workers(workers)
      pids = workers.flatten.map do |worker|
        fork &worker.method(:call)
      end

      [:TERM, :INT].each do |sig|
        Signal.trap(sig) do
          pids.each { |pid| Process.kill(:QUIT, pid) }
          log.info("told workers to QUIT from #{sig}")
          Process.exit(0)
        end
      end

      Process.wait
    end

  end

end
