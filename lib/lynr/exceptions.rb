require './lib/sly/exceptions'

module Lynr

  # # `Lynr::DataError`
  #
  # Raise to indicate there was a problem with data processing.
  #
  class DataError < StandardError

    attr_reader :cause, :field, :value

    # ## `DataError.new(field, value, msg, cause)`
    #
    # Creates an error specific to a set of data. The piece of data is labeled
    # by `field` and contained `value`. `msg` is the human readable message
    # for the purposes of logging. `cause` is meant to be the `Error` instance
    # which was converted into this error if one exists.
    #
    def initialize(field, value, msg=nil, cause=nil)
      @cause = cause
      @field = field
      @value = value
      super(msg)
    end

  end

  # # `Lynr::HttpError`
  #
  # Raise to indicate there was a problem generating a 200 response for the
  # current request. `HttpError` instances are created with a `status` and an
  # optional `msg`.
  #
  class HttpError < Sly::HttpError; end

  # # `Lynr::UnauthenticatedError`
  #
  # Raise to indicate there is no authenticated user.
  #
  class UnauthenticatedError < HttpError
    def initialize(msg=nil)
      super(200, msg)
    end
  end

end

require './lib/lynr/persist/exceptions'
