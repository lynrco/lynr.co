source 'https://rubygems.org'
source 'https://code.stripe.com'

ruby '1.9.3'

gem 'ramaze',           '2012.12.08'
gem 'log4r',            '1.1.10'
gem 'bson_ext',         '1.8.2'
gem 'mongo',            '1.8.2'
gem 'bcrypt-ruby',      '3.0.1'
gem 'yajl-ruby',        '1.1.0'
gem 'stripe',           '1.7.11'
gem 'kramdown',         '1.2.0'
gem 'bunny',            '0.10.6'
gem 'libxml-ruby',      '2.7.0'

group :development do
  gem 'guard'
  gem 'guard-shell'
  gem 'guard-bundler'
  gem 'guard-rake'

  gem 'rb-inotify', :require => false
  gem 'rb-fsevent', :require => false
  gem 'rb-fchange', :require => false

  gem 'pry'
end

group :local do
  gem 'shotgun',        '0.9'
end

group :vagrant do
  gem 'unicorn',        '4.5.0'
end

group :heroku do
  gem 'less',           '2.3.1'
  gem 'therubyracer'
  gem 'unicorn',        '4.5.0'
end

group :test do
  gem 'rspec',          '2.12'

  gem 'codeclimate-test-reporter'

  gem 'guard-rspec'
end
