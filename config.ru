require './app'

Lynr::App.setup

Ramaze.start(:root => Ramaze.options.roots, :started => true)

run Ramaze