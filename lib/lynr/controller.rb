require './lib/lynr'

module Lynr

  module Controller

    autoload :Authentication, './lib/lynr/controller/component/authentication'
    autoload :Authorization, './lib/lynr/controller/component/authorization'
    autoload :Base, './lib/lynr/controller/base'
    autoload :Paginated, './lib/lynr/controller/component/paginated'

  end

end
