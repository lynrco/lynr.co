namespace :worker do

  basedir = File.expand_path("#{File.dirname(__FILE__)}/..")
  libdir = "#{basedir}/lib"
  $LOAD_PATH.unshift(basedir) unless $LOAD_PATH.include?(basedir)
  $LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

  queues = ['development.test']

  task :all do

    require 'lynr/logging'
    require 'lynr/worker'

    include Lynr::Logging

    workers = queues.map do |queue_name|
      Lynr::Worker.new(queue_name)
    end

    pids = workers.map do |worker|
      fork &worker.method(:call)
    end

    Signal.trap(:TERM) do
      pids.each { |pid| Process.kill(:QUIT, pid) }
      log.info('`rake worker:all` told Workers to QUIT')
      Process.exit(0)
    end

    Process.wait

  end

end
