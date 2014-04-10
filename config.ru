require 'rack'
require 'rack/ssl'
require 'librato-rack'
require 'new_relic/rack/agent_hooks'
require 'new_relic/rack/browser_monitoring'
require 'new_relic/rack/error_collector'

require './lib/lynr/web'
require './lib/rack/middleware/logger'
require './lib/rack/middleware/timer'

Lynr::Web.setup

config = Lynr.config('app')

statics = 'public'
statics = 'dist' if Lynr.env == 'heroku'

use NewRelic::Rack::AgentHooks if Lynr.env == 'heroku'
use NewRelic::Rack::BrowserMonitoring if Lynr.env == 'heroku'
use NewRelic::Rack::ErrorCollector if Lynr.env == 'heroku'
use Rack::Deflater
use Rack::SSL if Lynr.features.force_ssl?
use Rack::Static, :urls => ["/css", "/js", "/img", "/robots.txt"], :root => statics
use Librato::Rack if Lynr.env == 'heroku'
use Rack::Middleware::Timer, Lynr::Web.instance.log
use Rack::Session::Cookie,  :key          => '_lynr',
                            :domain       => config['domain'],
                            :path         => '/',
                            :expire_after => 604800, # 7 days
                            :secret       => config['session']['secret'],
                            :old_secret   => config['session']['old_secret']

run Lynr::Web.instance
