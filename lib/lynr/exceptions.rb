require './lib/sly/exceptions'

module Lynr

  # # `Lynr::HttpError`
  #
  # Raise to indicate there was a problem with data processing.
  #
  class DataError < StandardError

    attr_reader :field

    def initialize(field, msg=nil)
      @field = field
      super(msg)
    end

  end

  # # `Lynr::HttpError`
  #
  # Raise to indicate there was a problem generating a 200 response for the
  # current request. `HttpError` instances are created with a `status` and an
  # optional `msg`.
  #
  class HttpError < Sly::HttpError
  end

end
