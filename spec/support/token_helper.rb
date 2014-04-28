require './lib/lynr/model/token'
require './lib/lynr/persist/dao'

shared_context "spec/support/TokenHelper" do

  def token(data)
    dao = Lynr::Persist::Dao.new
    dao.create(Lynr::Model::Token.new(data))
  end

end
