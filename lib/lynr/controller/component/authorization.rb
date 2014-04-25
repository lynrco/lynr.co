require 'bson'

require './lib/lynr/controller'

module Lynr::Controller

  # # `Lynr::Controller::Authorization`
  #
  # Provide methods to check if a particular identity is permitted to
  # perform an action specified by a role.
  #
  # Roles are specified by strings in the form "#{role_type}:#{dealership_id}".
  # `role_type` may have sub-types, for example 'admin.vehicle.delete'
  # could signify the ability to remove vehicles from the inventory.
  # In this case an identity with the any of the roles 'admin', 'admin.vehicle'
  # or 'admin.vehicle.delete' would be authorized to perform this action.
  #
  module Authorization

    # ## `Authorization#authorized?(role, dealership)`
    #
    # Check if the `Identity` for `dealership` has the specified `role`.
    # `role` must be of the form "#{role_type}:#{dealership_id}". The
    # `role` is split apart and checked for validity and then authorization
    # is determined.
    #
    def authorized?(role, dealership)
      return false unless role.is_a?(String)
      type, id = role.split(':')
      id = BSON::ObjectId.legal?(id) && BSON::ObjectId.from_string(id)
      dealership.id == id
    end

  end

end
