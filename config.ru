require 'rack'

require 'rack/middleware/logger'
require 'rack/middleware/timer'
require './lib/web'

Lynr::Web.setup

Ramaze.start(:root => Ramaze.options.roots, :started => true)

use Rack::Middleware::Timer, Lynr::Web.instance.log
use Rack::Middleware::Logger, Lynr::Web.instance.log
use Rack::Session::Cookie,  :key          => '_lynr',
                            :domain       => Lynr::Web.instance.config['domain'],
                            :path         => '/',
                            :expire_after => 604800, # 7 days
                            :secret       => Lynr::Web.instance.config['session']['secret'],
                            :old_secret   => Lynr::Web.instance.config['session']['old_secret']

use Sly::App, root: __DIR__, cascade: true

run Ramaze.core
