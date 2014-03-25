require './lib/lynr/model/dealership'
require './lib/lynr/model/identity'

module ModelHelper

  def identity
    return @identity unless @identity.nil?
    @identity = Lynr::Model::Identity.new('bryan@lynr.co', 'this is a fake password')
  end

  def empty_dealership
    return @empty_dealership unless @empty_dealership.nil?
    @empty_dealership = Lynr::Model::Dealership.new({ 'identity' => identity, })
  end

  def saved_empty_dealership
    return @saved_empty_dealership unless @saved_empty_dealership.nil?
    @saved_empty_dealership = subject.dealer_dao.save(empty_dealership)
  end

end
