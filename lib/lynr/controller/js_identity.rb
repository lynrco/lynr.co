require './lib/lynr/controller/base'

module Lynr::Controller

  # # `Lynr::Controller::JsIdentity`
  #
  # Get identity data for the currently logged in user as a Require.JS
  # module.
  #
  class JsIdentity < Lynr::Controller::Base

    get  '/identity.js', :get

    # ## `JsIdentity#headers`
    #
    # Overwrite the 'Content-Type' header so requests to '/identity.js'
    # are transferred with an appropriate content type.
    #
    def headers
      super.merge({
        'Content-Type' => 'text/javascript; charset=utf-8',
      })
    end

    # ## `JsIdentity#get(req)`
    #
    # Handle GET requests. The behavior varies depending on whether or
    # not a user is logged in. If logged in provide the identity
    # information but if not logged in provide nothing.
    #
    def get(req)
      dealer = session_user(req)
      props =
        if dealer.nil?
          { }
        else
          {
            id: dealer.id.to_s,
            email: dealer.identity.email,
          }
        end
      render 'identity.js.erb', data: { properties: props }
    end

    # ## `JsIdentity#render_options`
    #
    # Modify the `#render_options` from `Lynr::Controller::Base` to
    # remove `:layout`.
    #
    def render_options
      super.delete_if { |k,v| k == :layout }
    end

  end

end
