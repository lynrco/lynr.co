require './lib/lynr/controller'

module Lynr::Controller

  # # `Lynr::Controller::Signout`
  #
  # Handle requests to signout.
  #
  class Signout < Lynr::Controller::Base

    get  '/signout', :get

    # ## `Signout#get(req)`
    #
    # Process GET request to the signout resource.
    #
    # 1. Destroy session
    # 2. Redirect to root resource
    #
    def get(req)
      req.session.destroy
      redirect '/'
    end

  end

end
