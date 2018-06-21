
require 'json'
require 'pg'
require 'active_record'

ActiveRecord::Base.logger = Logger.new("log/sql.log", 'daily')

ActiveRecord::Base.establish_connection(
    adapter: 'postgresql',  
    encoding: 'unicode', 
    database: 'stak', 
    pool: 20, 
    username: 'stakuser', 
    password: 'stakuserpasswd',
    reconnect: true
)

class TTask < ActiveRecord::Base
  @@where_prm = nil
  @@order_prm = nil

  def self.set_where_prm(prm)
    @@where_prm = prm
  end

  def self.set_order_prm(prm)
    @@order_prm = prm
  end

  self.table_name = 't_task'
  belongs_to :solution_info, class_name: "TSolution", foreign_key: "solution_cd"
  has_many :t_task_task_rel, class_name: "TTaskTaskRel", foreign_key: "task_cd_a", primary_key: "task_cd"
  belongs_to :parent_task, class_name: "TTask", foreign_key: "parent_cd", primary_key: "task_cd"
  has_many :children, ->{cur_where().cur_order()}, class_name: "TTask", foreign_key: "parent_cd", primary_key: "task_cd"
  has_many :children_all, ->{cur_order()}, class_name: "TTask", foreign_key: "parent_cd", primary_key: "task_cd"

  scope :cur_where, -> {
    if (@@where_prm != nil) && (@@where_prm.length != 0)
      where(task_cd: @@where_prm)
    end
  }

  scope :cur_order, -> {
    order(@@order_prm)
  }

  scope :with_rels, -> {
    includes(
      :solution_info,
      :parent_task,
      :children,
      :children_all
    )
  }

  def self.json(src)
    nested = {
        :solution_info => {},
        :t_task_task_rel => {:include => [:t_task]},
        :parent_task => {},
        :children => {},
        :children_all => {}
      }
    for i in 0...10
      nested = {
        :solution_info => {},
        :t_task_task_rel => {:include => [:t_task]},
        :parent_task => {},
        :children => {:include => nested.deep_dup},
        :children_all => {:include => nested.deep_dup}
      }
    end

    src.to_json(:include => nested.deep_dup)
  end
end

class TSolution < ActiveRecord::Base
  self.table_name = 't_solution'
  belongs_to :solution_status_info, class_name: "CType", foreign_key: "status_type", primary_key: "type_cd"
end

class CType < ActiveRecord::Base
  self.table_name = 'c_type'
end

class VTypeTaskType < ActiveRecord::Base
  self.table_name = 'v_type_task_type'
end

class VTypeTaskStatus < ActiveRecord::Base
  self.table_name = 'v_type_task_status'
end

class VTypeSolutionStatus < ActiveRecord::Base
  self.table_name = 'v_type_solution_status'
end

class VTypeTaskPriority < ActiveRecord::Base
  self.table_name = 'v_type_task_priority'
end

class TTaskAlias < ActiveRecord::Base
  self.table_name = 't_task'
end

class TTaskTaskRel < ActiveRecord::Base
  self.table_name = 't_task_task_rel'

  belongs_to :t_task, class_name: "TTaskAlias", foreign_key: "task_cd_b", primary_key: "task_cd"
end

class TTaskRelParent < ActiveRecord::Base
  self.table_name = 't_task_task_rel'
end

class TTaskRelChild < ActiveRecord::Base
  self.table_name = 't_task_task_rel'

  belongs_to :children, class_name: "TTask", foreign_key: "task_cd_b", primary_key: "task_cd"
end

class VTaskTaskRelChild < ActiveRecord::Base
  self.table_name = 'v_task_task_rel_child'

  belongs_to :children, class_name: "TTask", foreign_key: "task_cd_b", primary_key: "task_cd"
end

class VTaskTaskRelParent < ActiveRecord::Base
  self.table_name = 'v_task_task_rel_parent'
end

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

class TWorkplan2 < ActiveRecord::Base
  self.table_name = 't_workplan2'

  # def self.json(src)
  #   src.to_json(:include => {:id => {}, :parent => {}})
  # end
end

class MUser < ActiveRecord::Base
  self.table_name = "m_user"

  def self.json(src)
    src.to_json()
  end
end

