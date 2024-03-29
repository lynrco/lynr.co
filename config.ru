require 'rack'
require 'rack/ssl'
require 'rack-timeout'
require 'librato-rack'

require './lib/lynr/web'
require './lib/rack/middleware/logger'
require './lib/rack/middleware/redirect'
require './lib/rack/middleware/timer'

app = Lynr::Web.new
config = Lynr.config('app')
Rack::Timeout.timeout = 5

use Rack::Timeout
use Rack::Deflater
use Rack::SSL if Lynr.features.force_ssl?
if !config.assets.nil? && !config.assets.empty?
  use Rack::Middleware::Redirect, [
      { test: %r(\A/((css|js|html|img).*)), target: "#{config.assets}/\\1" },
    ]
  use Rack::Static, urls: ['/favicon.ico', '/robots.txt'], root: 'public'
else
  use Rack::Static, :urls => [
      '/css', '/html', '/js', '/img', '/favicon.ico', '/robots.txt'
    ], :root => if Lynr.features.precompiled? then 'out/build' else 'public' end
end
use Librato::Rack if Lynr.features.rack_metrics? && Lynr.metrics.configured?
use Rack::Middleware::Timer, app.log if Lynr.features.rack_timer?
use Rack::Session::Cookie,  :key          => '_lynr',
                            :domain       => config['domain'],
                            :path         => '/',
                            :expire_after => 604800, # 7 days
                            :secret       => config['session']['secret'],
                            :old_secret   => config['session']['old_secret']

run app
