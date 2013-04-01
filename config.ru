require 'rack'

require './app'
require './lib/rack/middleware/logger'
require './lib/rack/middleware/timer'

Lynr::App.setup

Ramaze.start(:root => Ramaze.options.roots, :started => true)

use Rack::Middleware::Logger, Lynr::App.instance.log
use Rack::Middleware::Timer, Lynr::App.instance.log
use Sly::App, root: __DIR__, cascade: [404, 405]

run Ramaze.core
