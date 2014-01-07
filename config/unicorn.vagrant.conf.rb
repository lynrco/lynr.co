worker_processes 3
timeout 15

listen "/tmp/lynr.unicorn.sock", :backlog => 64
listen 8080

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end
end

pid "/tmp/lynr.unicorn.pid"
