module Sly

  # # `Sly::HttpError`
  #
  # Raise to indicate there was a problem generating a 200 response for the
  # current request. `HttpError` instances are created with a `status` and an
  # optional `msg`.
  #
  class HttpError < StandardError

    attr_reader :status

    def initialize(status, msg=nil)
      @status = status
      super(msg)
    end

  end

  # # `Sly::InternalServerError`
  #
  # Raise to indicate an unrecoverable, internal error occurred while processing.
  #
  class InternalServerError < HttpError

    def initialize(msg=nil)
      super(500, msg)
    end

  end

  # # `Sly::NotFoundError`
  #
  # Raise to indicate a request can not be processed because the necessary
  # resources can not be found.
  #
  class NotFoundError < HttpError

    def initialize(msg=nil)
      super(404, msg)
    end

  end

  class TooManyRoutesError < StandardError; end

end
