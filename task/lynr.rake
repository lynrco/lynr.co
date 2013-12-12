require './lib/lynr'

# This file contains a predefined set of Rake tasks that can be useful when
# developing Ramaze applications. You're free to modify these tasks to your
# liking, they will not be overwritten when updating Ramaze.

namespace :lynr do
  app = "#{Lynr.root}/lib/lynr/web"

  # Pry can be installed using `gem install pry`.
  desc 'Starts a Lynr console using Pry'
  task :pry do
    require app
    require 'pry'

    ARGV.clear
    Pry.start
  end

end
