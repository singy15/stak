
class TTaskRelChild < ActiveRecord::Base
  self.table_name = 't_task_task_rel'

  belongs_to :children, class_name: "TTask", foreign_key: "task_cd_b", primary_key: "task_cd"
end

