worker_processes 1

listen "/tmp/.quicklist.unicorn.sock", :backlog => 64
listen 8080

timeout 30

pid         "/home/vagrant/pids/unicorn.pid"
stderr_path "/home/vagrant/logs/unicorn.log"
stdout_path "/home/vagrant/logs/unicorn.log"

ENV['LOGDIR'] = '/home/vagrant/logs'
