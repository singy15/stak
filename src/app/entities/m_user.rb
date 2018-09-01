
class MUser < ActiveRecord::Base
  self.table_name = "m_user"

  scope :default_order, -> {
    order("user_cd")
  }

  def self.json(src)
    src.to_json()
  end
end

