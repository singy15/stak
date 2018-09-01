
class TWorkplan < ActiveRecord::Base
  self.table_name = 't_workplan'

  belongs_to :user_info, class_name: "MUser", foreign_key: "user_cd", primary_key: "user_cd"

  scope :with_rels, -> {
    includes(
      :user_info
    )
  }

  # def self.json(src)
  #   src.to_json(:include => {:id => {}, :parent => {}})
  # end
end

