
class TSolution < ActiveRecord::Base
  self.table_name = 't_solution'
  belongs_to :solution_status_info, class_name: "CType", foreign_key: "status_type", primary_key: "type_cd"
end

