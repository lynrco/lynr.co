module Lynr; module Controller;

  # # `Lynr::Controller::FormHelpers`
  #
  # `FormHelpers` is a module containing methods specifically targetted
  # at simplifying view operations that have to do with form fields and form
  # errors. The methods in this module rely on the presence of a `Hash` called
  # `@errors`. The `Hash` has the form:
  #
  #     {
  #       'field_name1' => 'error message for field_name1',
  #       'field_name2' => 'error message for field name2'
  #     }
  #
  module FormHelpers

    # ## `Lynr::Controller::FormHelpers#error_class`
    #
    # Provides an error class for a field in the markup which has an error
    # associated with the given field.
    #
    # ### Params
    # 
    # * `field` to check `@errors` for
    #
    # ### Returns
    #
    # 'fs-error' if there is an error for `field` empty string otherwise
    #
    def error_class(field)
      if has_error?(field) then 'fs-error' else '' end
    end

    def error_message(field)
      if has_error?(field) then @errors[field] else "" end
    end

    def has_error?(field)
      has_errors? && @errors.include?(field)
    end

    def has_errors?
      !(@errors.nil? || @errors.empty?)
    end

    # ## `Lynr::Controller::FormHelpers#posted`
    #
    # Attribute reader for the `@posted` instance value that sets a default
    # empty `Hash` if the value hasn't yet been defined.
    #
    # ### Returns
    #
    # The value of `@posted` or an empty `Hash`
    #
    def posted
      @posted ||= {}
    end

    # ## `Lynr::Controller::FormHelpers#card_data`
    #
    # Retrieve credit card data from the card processor in order to safely
    # display it back to the customer.
    #
    # ### Returns
    #
    # An empty `Hash` if there is no stripeToken otherwise a `Hash` with the form
    #
    #     {
    #       'card_number' => '**** **** **** 0000',
    #       'card_expiry_month' => '00',
    #       'card_expiry_year' => '00',
    #       'card_cvv' => '***'
    #     }
    #
    def card_data
      return {} if !posted['stripeToken']
      return @card_data if !@card_data.nil?
      log.debug({ type: 'notice', message: 'Retrieving card for Stripe token' })
      data = Stripe::Token.retrieve(posted['stripeToken'])
      card = data['card']
      card_num = case card['type']
                 when 'American Express'
                   card['last4'].rjust(17, '**** ****** *****')
                 when 'Diner\'s Club'
                   card['last4'].rjust(16, '**** ****** ****')
                 else
                   card['last4'].rjust(19, '**** **** **** ****')
                 end
      @card_data = {
        'card_number' => card_num,
        'card_expiry_month' => card['exp_month'].to_s.rjust(2, '0'),
        'card_expiry_year' => card['exp_year'].to_s.slice(2,4),
        'card_cvv' => '***'
      }
    end

  end

end; end;
