require 'ramaze'

module Lynr; module Controller;

  class Base < Ramaze::Controller

    include Lynr::Logging

    engine :erb
    helper :xhtml

  end

end; end;
