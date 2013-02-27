require 'bundler/setup'
require 'ramaze'

Ramaze.options.roots = [__DIR__]
Ramaze.options.views = ["views"]

require './lib/lynr/logging'
require './lib/lynr/controller/root'

module Lynr

  class App

    include Lynr::Logging

    ROOT = '/api'
    VERSION = 'v1'
    BASE = "#{ROOT}/#{VERSION}"

  end

end
