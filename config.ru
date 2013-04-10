require 'rack'

basedir = File.expand_path(File.dirname(__FILE__))
libdir = "#{basedir}/lib"
$LOAD_PATH.unshift(basedir) unless $LOAD_PATH.include?(basedir)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'app'
require 'rack/middleware/logger'
require 'rack/middleware/timer'

Lynr::App.setup

Ramaze.start(:root => Ramaze.options.roots, :started => true)

use Rack::Middleware::Timer, Lynr::App.instance.log
use Rack::Middleware::Logger, Lynr::App.instance.log
use Rack::Session::Cookie,  :key          => '_lynr',
                            :domain       => Lynr::App.instance.config['domain'],
                            :path         => '/',
                            :expire_after => 604800, # 7 days
                            :secret       => Lynr::App.instance.config['session']['secret'],
                            :old_secret   => Lynr::App.instance.config['session']['old_secret']
use Sly::App, root: __DIR__, cascade: [404, 405]

run Ramaze.core
