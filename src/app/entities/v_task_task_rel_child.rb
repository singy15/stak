
class VTaskTaskRelChild < ActiveRecord::Base
  self.table_name = 'v_task_task_rel_child'

  belongs_to :children, class_name: "TTask", foreign_key: "task_cd_b", primary_key: "task_cd"
end

