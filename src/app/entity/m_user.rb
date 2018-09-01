
class MUser < ActiveRecord::Base
  self.table_name = "m_user"

  def self.json(src)
    src.to_json()
  end
end

