module Lynr::Controller

  class Auth::Signup

    module Demo

      # ## `Auth::Signup::Demo#validate_signup(posted)`
      #
      # Verify the validity of data in `posted` and return a `Hash` of
      # field names to error strings if there are any. Otherwise return an
      # empty `Hash`.
      #
      def validate_signup(posted)
        errors = validate_required(posted, ['email', 'password'])
        email = posted['email']

        errors['email'] ||= error_for_email(dealer_dao, email)

        errors.delete_if { |k,v| v.nil? }
      end

      # ## `Auth::Signup#post_signup(req)`
      #
      # Create a `Lynr::Model::Identity` and a `Stripe::Customer` and use them
      # to create and save a `Lynr::Model::Dealership` instance and then log
      # the new customer in.
      #
      def post_signup(req)
        # Create account
        identity = Lynr::Model::Identity.new(@posted['email'], @posted['email'])
        dealer = create_dealership(identity, customer)
        Lynr::Events.emit(type: 'dealership.created', data: {
          dealership_id: dealer.id.to_s,
          cookies: req.cookies,
        })
        # Create and Save dealership
        req.session['dealer_id'] = dealer.id
        # Send to admin pages?
        send_to_admin(req, dealer)
      end

    end

  end

end
