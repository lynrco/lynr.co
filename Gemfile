source 'https://rubygems.org'
ruby '1.9.3'

gem 'ramaze',          '2012.12.08'
gem 'log4r',           '1.1.10'
gem 'bson_ext',        '1.8.2'
gem 'mongo',           '1.8.2'
gem 'bcrypt-ruby',     '3.0.1'
gem 'yajl-ruby',       '1.1.0'

group :development do
  gem 'guard'
  gem 'guard-shell'
  gem 'guard-bundler'

  gem 'rb-inotify', :require => false
  gem 'rb-fsevent', :require => false
  gem 'rb-fchange', :require => false

  gem 'pry'
end

group :local do
  gem 'shotgun',       '0.9'
end

group :vagrant do
  gem 'unicorn',       '4.5.0'
end

group :test do
  gem 'rspec',      '2.12'

  gem 'guard-rspec'
end
