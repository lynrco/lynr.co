worker_processes 1

listen "/tmp/.lynr.unicorn.sock", :backlog => 64
listen 8080

timeout 30

pid         "/home/action/pids/unicorn.pid"
stderr_path "/home/action/logs/unicorn.log"
stdout_path "/home/action/logs/unicorn.log"

ENV['LOGDIR'] = '/home/action/logs'
ENV['whereami'] = 'nitrous'
