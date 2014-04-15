namespace :lynr do

  namespace :stripe do

    require 'stripe'
    require './lib/lynr'
    require './lib/lynr/persist/dealership_dao'

    if Lynr.config('app').include?('stripe')
      Stripe.api_key = Lynr.config('app').stripe.key
      Stripe.api_version = Lynr.config('app').stripe.version
    end

    desc 'Starts a Pry session with `Stripe` configured'
    task :pry do
      require 'pry'

      ARGV.clear
      Pry.start
    end

  end

end
