
class TTaskTaskRel < ActiveRecord::Base
  self.table_name = 't_task_task_rel'

  belongs_to :t_task, class_name: "TTaskAlias", foreign_key: "task_cd_b", primary_key: "task_cd"
end

