
class TypeSvc
  def fetch_type_kv(category)
    return CType
      .where(type_category: category)
      .order("sort_order")
      .map {|r| {value: r["type_cd"], text: r["name"]} }
      .to_json
  end

  def kv_task_status()
    fetch_type_kv(ConstTypeCategory::TASK_STATUS)
  end

  def kv_task_type()
    fetch_type_kv(ConstTypeCategory::TASK_TYPE)
  end

  def kv_task_priority()
    fetch_type_kv(ConstTypeCategory::TASK_PRIORITY)
  end

  def kv_task_task_relation()
    fetch_type_kv(ConstTypeCategory::TASK_TASK_RELATION)
  end

  def kv_work_type()
    fetch_type_kv(ConstTypeCategory::WORK_TYPE)
  end

  def kv_solution_status_type()
    fetch_type_kv(ConstTypeCategory::SOLUTION_STATUS)
  end

  def kv_solution()
    TSolution
      .all
      .map { |r| {value: r["solution_cd"], text: r["name"]} }
      .to_json
  end

  def kv_user()
    MUser
      .all
      .order("user_cd")
      .map { |r| {value: r["user_cd"], text: r["name"]} }
      .to_json
  end
end
