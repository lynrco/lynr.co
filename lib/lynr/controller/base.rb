require 'ramaze'

module Lynr; module Controller;

  class Base < Ramaze::Controller

    include Lynr::Logging

    engine :erb

    # Executed after each `Innate::Action`. Every render_* method creates an
    # `Innate::Action`. So don't do anything complex in here.
    after_all do
      response['Server'] = 'Lynr.co Application Server'
    end

  end

end; end;
