require 'rack'
require 'rack/ssl'
require 'librato-rack'

require './lib/lynr/web'
require './lib/rack/middleware/logger'
require './lib/rack/middleware/timer'

Lynr::Web.setup

statics = 'public'
statics = 'dist' if Lynr.env == 'heroku'

use Rack::SSL
use Librato::Rack
use Rack::Static, :urls => ["/css", "/js", "/img", "/robots.txt"], :root => statics
if Lynr.env == 'development' then use Rack::Static, :urls => ["/less"], :root => statics end
use Rack::Middleware::Timer, Lynr::Web.instance.log
# Uncomment for logs of every request start and end
# use Rack::Middleware::Logger, Lynr::Web.instance.log
use Rack::Session::Cookie,  :key          => '_lynr',
                            :domain       => Lynr::Web.instance.config['domain'],
                            :path         => '/',
                            :expire_after => 604800, # 7 days
                            :secret       => Lynr::Web.instance.config['session']['secret'],
                            :old_secret   => Lynr::Web.instance.config['session']['old_secret']

run Lynr::Web.instance
