source 'https://rubygems.org'
source 'https://code.stripe.com'

ruby '1.9.3'

gem 'bcrypt',           '3.1.7'
gem 'bson_ext',         '1.9.2'
gem 'bunny',            '1.1.3'
gem 'elasticsearch',    '1.0.1'
gem 'geocoder',         '1.1.9'
gem 'georuby',          '2.2.1'
gem 'kramdown',         '1.3.2'
gem 'librato-rack',     '0.4.4'
gem 'libxml-ruby',      '2.7.0'
gem 'log4r',            '1.1.10'
gem 'mongo',            '1.9.2'
gem 'nokogiri',         '1.6.1'
gem 'premailer',        '1.8.1'
gem 'rack-ssl',         '1.3.3'
gem 'stripe',           '1.10.1'
gem 'yajl-ruby',        '1.2.0'

group :development do
  gem 'guard'
  gem 'guard-shell'
  gem 'guard-bundler'
  gem 'guard-rake'
  gem 'guard-rspec'

  gem 'pry'
  gem 'pry-debugger'

  gem 'rb-fchange', :require => false
  gem 'rb-fsevent', :require => false
  gem 'rb-inotify', :require => false

  group :local do
    gem 'shotgun',      '0.9'
  end
end

group :test do
  gem 'rspec'

  gem 'codeclimate-test-reporter'
end

group :heroku do
  gem 'unicorn',        '4.8.2'
end
