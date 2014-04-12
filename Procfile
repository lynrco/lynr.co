web: bundle exec unicorn -p $PORT -c config/unicorn.heroku.conf.rb
worker: bundle exec rake lynr:worker:queues
events: bundle exec rake lynr:worker:events
queues: bundle exec rake lynr:worker:queues
