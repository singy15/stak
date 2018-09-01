
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

