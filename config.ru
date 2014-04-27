require 'rack'
require 'rack/ssl'
require 'librato-rack'

require './lib/lynr/web'
require './lib/rack/middleware/logger'
require './lib/rack/middleware/timer'

Lynr::Web.setup

config = Lynr.config('app')

use Rack::Deflater
use Rack::SSL if Lynr.features.force_ssl?
use Rack::Static, :urls => [
    "/css", "/js", "/img", "/favicon.ico", "/robots.txt"
  ], :root => if Lynr.env == 'heroku' then 'out/build' else 'public' end
use Librato::Rack if Lynr.env == 'heroku' && Lynr.metrics.configured?
use Rack::Middleware::Timer, Lynr::Web.instance.log
use Rack::Session::Cookie,  :key          => '_lynr',
                            :domain       => config['domain'],
                            :path         => '/',
                            :expire_after => 604800, # 7 days
                            :secret       => config['session']['secret'],
                            :old_secret   => config['session']['old_secret']

run Lynr::Web.instance
