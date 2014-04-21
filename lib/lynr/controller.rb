require './lib/lynr'

module Lynr

  module Controller

    autoload :Base,      './lib/lynr/controller/base'
    autoload :Paginated, './lib/lynr/controller/component/paginated'

  end

end
