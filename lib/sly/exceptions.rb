require 'rack'

module Sly

  class HttpError < StandardError; end

  class TooManyRoutesError < StandardError; end

  class InternalServerError < HttpError; end

end
