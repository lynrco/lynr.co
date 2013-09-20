namespace :worker do

  basedir = File.expand_path("#{File.dirname(__FILE__)}/..")
  libdir = "#{basedir}/lib"
  $LOAD_PATH.unshift(basedir) unless $LOAD_PATH.include?(basedir)
  $LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

  queues = ['development.test']

  task :all do

    require 'lynr/worker'

    workers = queues.map do |queue_name|
      Lynr::Worker.new(queue_name)
    end

    begin

      pids = workers.map do |worker|
        fork &worker.method(:call)
      end

      Process.wait

    rescue Interrupt

      pids.each do |pid|
        Process.kill(:USR1, pid)
      end

    end

  end

end
