require './app'
require './lib/rack/middleware/logger'

Lynr::App.setup

Ramaze.start(:root => Ramaze.options.roots, :started => true)

use Rack::Middleware::Logger, Lynr::App.instance.log
#use Sly::App

run Ramaze.core
