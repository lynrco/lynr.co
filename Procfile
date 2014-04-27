web: bundle exec unicorn -p $PORT -c config/unicorn/unicorn.heroku.conf.rb
events: bundle exec rake lynr:worker:events
queues: bundle exec rake lynr:worker:queues
