
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
      .map { |r| {value: r["user_cd"], text: r["name"]} }
      .to_json
  end
end

class TaskSvc
  def recursive_get_parent_cd(cds, task)
    if task["parent_cd"] != ""
      cds << task["parent_cd"]
      recursive_get_parent_cd(cds, TTask.find(task["parent_cd"]))
    end
  end

  def all_parent_cd(src_ls)
    cds = []
    src_ls.each do |r|
      recursive_get_parent_cd(cds, r)
    end
    cds
  end

  def gen_where_prm(params)
    if ((params == nil) || (params["filterRules"] == nil))
      return ""
    end

    where_prm = []
    if params["filterRules"]
      filter_rules = JSON.parse(params["filterRules"])

      filter_rules.select {|f| f["op"] == "contains" }.each do |r|
        case r["field"]
        when "name"
          where_prm << ActiveRecord::Base.send(:sanitize_sql_array, ["("+ "(t_task.task_cd || ' ' || t_task.name) ilike :str" + ")", str: "%" + r["value"] + "%" ])
        when "task_cd"
          if((r["value"])[0] === "@")
            cd = r["value"].slice(1..-1)
            p "***"
            p cd.split(",")
            cond = []
            cd.split(",").each do |c|
              cond << ActiveRecord::Base.send(:sanitize_sql_array, ["("+"(t_task.task_cd || ' ' || t_task.path) ilike :str" + ")", str: "%" + c + "%"])
            end
            if cond.length > 0
              where_prm << "( " + cond.join(" or ") + " ) "
            end
            # where_prm << ActiveRecord::Base.send(:sanitize_sql_array, ["("+"(t_task.task_cd || ' ' || t_task.path) ilike :str" + ")", str: "%" + r["value"].slice(1..-1) + "%"])
          else
            cd = r["value"].slice(1..-1)
            p "***"
            p cd.split(",")
            cond = []
            cd.split(",").each do |c|
              cond << ActiveRecord::Base.send(:sanitize_sql_array, ["("+"t_task." + r["field"] + " ilike :str" + ")", str: "%" + c + "%"])
            end
            if cond.length > 0
              where_prm << "( " + cond.join(" or ") + " ) "
            end
            # where_prm << ActiveRecord::Base.send(:sanitize_sql_array, ["("+"t_task." + r["field"] + " ilike :str" + ")", str: "%" + r["value"] + "%"])
          end
        else
          where_prm << ActiveRecord::Base.send(:sanitize_sql_array, ["("+"t_task." + r["field"] + " ilike :str" + ")", str: "%" + r["value"] + "%"])
        end
      end

      filter_rules.select {|f| f["op"] == "in" }.each do |r|
        where_prm << ActiveRecord::Base.send(:sanitize_sql_array, ["("+ "t_task." + r["field"] + " in (:cds)" + ")", cds: r["value"].split(",")] )
      end
    end

    return where_prm.join(" and ")
  end

  def gen_order_prm(params)
    prm_sort = (params["sort"])? params["sort"].split(",") : []
    prm_order = (params["order"])? params["order"].split(",") : []

    sort_prm = prm_sort.zip(prm_order).map{|x| x[0] + " " + x[1]}.join(", ")

    return sort_prm
  end

  def recursive_pagination_child(cnt, children, pagesize, offset, offset_ls)
    ls = []
    children.each do |r|
      if(offset_ls.length < offset)
        offset_ls << r
        r["children"] = recursive_pagination_child(cnt, r["children"], pagesize, offset, offset_ls)
      elsif(cnt.length < pagesize)
        ls << r
        cnt << r
        r["children"] = recursive_pagination_child(cnt, r["children"], pagesize, offset, offset_ls)
      end
    end
    ls
  end

  def pagination(cnt, ls, pagesize, offset, offset_ls)
    rslt = []
    ls.each do |r|
      if(offset_ls.length < offset)
        offset_ls << r
        r["children"] = recursive_pagination_child(cnt, r["children"], pagesize, offset, offset_ls)
      elsif(cnt.length < pagesize)
        rslt << r
        cnt << r
        r["children"] = recursive_pagination_child(cnt, r["children"], pagesize, offset, offset_ls)
      end
    end
    rslt
  end

  def recursive_total(cnt,ls)
    ls.each do |r|
      cnt << r
      recursive_total(cnt, r["children"])
    end
    cnt.length
  end

  def select_by_condition(params)
    # start_tm = Time.now
    TTask.set_order_prm("")
    TTask.set_where_prm(nil)

    order_prm = gen_order_prm(params)
    where_prm = gen_where_prm(params)

    con = ActiveRecord::Base.connection
    matches_count = con.select_value('SELECT count(*) as cnt FROM t_task WHERE ' + where_prm)
    sql = 'SELECT task_cd, parent_cd, root_parent_cd FROM t_task WHERE ' + where_prm + ((order_prm != "")? " order by " + order_prm + ", path asc" : " order by path asc") + " limit " + params["rows"].to_s() + " offset " + (params["rows"].to_i() * (params["page"].to_i() - 1)).to_s()
    p "*** sql ***"
    p sql
    matches = con.select_all(sql).to_hash

    p matches.map{|r| r["task_cd"]}

    cds = (matches.map{|r| r["task_cd"]} + all_parent_cd(matches)).uniq()
    TTask.set_where_prm(cds)
    TTask.set_order_prm(order_prm)

    #tasks = TTask.where("t_task.task_cd in (?)", tasks.map{|r| (r.parent_cd != "")? r.root_parent_cd : r.task_cd})
    tasks = TTask.where(task_cd: matches.map{|r| (r["root_parent_cd"] != "")? r["root_parent_cd"] : r["task_cd"]}.uniq()).cur_order()


    
    
    # tasks = tasks.with_rels().order(TTask.gen_sort_prm())

    # p tasks.to_sql

    # if (params["rows"] != nil) && (params["page"] != nil)
    #   total = tasks.count
    #   tasks = tasks.offset(params["rows"].to_i() * (params["page"].to_i() - 1)).take(params["rows"].to_i)
    # end
  
    tasks = TTask.json(tasks)
    tasks = JSON.parse(tasks)

    # total = recursive_total([],tasks)
    # offset_ls = []
    # cnt_ls = []
    # tasks = pagination(cnt_ls, tasks, params["rows"].to_i, params["rows"].to_i() * (params["page"].to_i() - 1), offset_ls)
    # p "*** offset ***"
    # p offset_ls.map{|r| r["task_cd"]}
    # p "*** cnt ***"
    # p cnt_ls.map{|r| r["task_cd"]}

    # end_tm = Time.now
    # p "*** elapsed """
    # p end_tm - start_tm

    total = matches_count
    return ({total: total, rows: tasks}).to_json()
    # return tasks.to_json()
  end

  def select_by_cd(cd)
    TTask.set_order_prm("")
    TTask.set_where_prm(nil)
    return TTask.json(TTask.with_rels().find(cd))
  end

  def recursive_delete(children_all)
    children_all.each do |r|
      recursive_delete(TTask.all.with_rels().find(r.task_cd).children_all)
      TTask.delete(r.task_cd)
    end
  end

  def delete_by_cd(cd)
    task = TTask.with_rels().find(cd)
    recursive_delete(task.children_all)
    TTask.delete(cd)
    TTaskTaskRel.where(task_cd_a: cd).delete_all()
    TTaskTaskRel.where(task_cd_b: cd).delete_all()
  end

  def recursive_calc_path(str, parent)
    if(parent.parent_cd != "") 
      str
    else
      recursive_calc_path(parent.parent_cd + "-" + str, TTask.find(parent.parent_cd))
    end
  end

  def recursive_path_update(str, children)
      children.each do |r|
        task = TTask.find(r.task_cd)
        task.path = str
        task.save()
        recursive_path_update(str + ((str != "")? "-" : "") + task.task_cd, task.children_all)
      end
  end

  def link(cd_a, cd_b, rel_type)
    if(rel_type == "TR02PR") 
      task = TTask.all.with_rels.find(cd_a)
      parent = TTask.all.with_rels.find(cd_b)

      task.parent_cd = cd_b
      task.path = parent.path + ((parent.path != "")? "-" : "") + parent.task_cd
      if parent.parent_cd != ""
        task.root_parent_cd = parent.root_parent_cd
      else
        task.root_parent_cd = cd_b
      end

      # parent.has_children = true

      task.save()
      parent.save()
      recursive_root_parent_cd_update(task.root_parent_cd, task.children_all)
      recursive_path_update(task.path + ((task.path != "")? "-" : "") + task.task_cd, task.children_all)
    end

    if(rel_type == "TR03CH") 
      tmp = cd_b
      cd_b = cd_a
      cd_a = tmp

      task = TTask.all.with_rels.find(cd_a)
      parent = TTask.all.with_rels.find(cd_b)

      task.parent_cd = cd_b
      task.path = parent.path + ((parent.path != "")? "-" : "") + parent.task_cd
      if parent.parent_cd != ""
        task.root_parent_cd = parent.root_parent_cd
      else
        task.root_parent_cd = cd_b
      end

      # parent.has_children = true

      task.save()
      parent.save()
      recursive_root_parent_cd_update(task.root_parent_cd, task.children_all)
      recursive_path_update(task.path + ((task.path != "")? "-" : "") + task.task_cd, task.children_all)
    end

    if(rel_type == "TR01RR") 
      exist = TTaskTaskRel.find_by(
        task_cd_a: cd_a,
        task_cd_b: cd_b,
        rel_type: rel_type
      )
      if(exist) 
        return {success: false, message: "Link already exist!", data: target}.to_json
      end

      exist = TTaskTaskRel.find_by(
        task_cd_a: cd_b,
        task_cd_b: cd_a,
        rel_type: rel_type
      )
      if(exist) 
        return {success: false, message: "Link already exist!", data: target}.to_json
      end

      rel = TTaskTaskRel.new()
      rel.task_cd_a = cd_a
      rel.task_cd_b = cd_b
      rel.rel_type = rel_type
      rel.save()

      rel = TTaskTaskRel.new()
      rel.task_cd_a = cd_b
      rel.task_cd_b = cd_a
      rel.rel_type = rel_type
      rel.save()
    end
  end

  def recursive_root_parent_cd_update(root_parent_cd, children_all)
    children_all.each do |r|
      r.root_parent_cd = root_parent_cd
      r.save()
      recursive_root_parent_cd_update(root_parent_cd, TTask.all.with_rels.find(r.task_cd).children_all)
    end
  end

  def unlink(cd_a, cd_b, rel_type)
    if(rel_type == "TR01RR") 
      TTaskTaskRel.where( task_cd_a: cd_a, task_cd_b: cd_b, rel_type: rel_type).delete_all()
      TTaskTaskRel.where( task_cd_a: cd_b, task_cd_b: cd_a, rel_type: rel_type).delete_all()
    end

    if(rel_type == "TR02PR") 
      task = TTask.with_rels().find(cd_a)
      task.parent_cd = ""
      task.root_parent_cd = ""
      task.path = ""
      task.save()
      recursive_root_parent_cd_update(task.task_cd, task.children_all)
      recursive_path_update(task.task_cd, task.children_all)
    end

    if(rel_type == "TR03CH") 
      tmp = cd_b
      cd_b = cd_a
      cd_a = tmp
      task = TTask.with_rels().find(cd_a)
      task.parent_cd = ""
      task.root_parent_cd = ""
      task.path = ""
      task.save()
      recursive_root_parent_cd_update(task.task_cd, task.children_all)
      recursive_path_update(task.task_cd, task.children_all)
    end
  end

  def set_parent_root(task_cd)
    task = TTask.with_rels().find(task_cd)
    task.parent_cd = ""
    task.root_parent_cd = ""
    task.path = ""
    task.save()
    recursive_root_parent_cd_update(task.task_cd, task.children_all)
    recursive_path_update(task.task_cd, task.children_all)
  end

  def fetch_new_cd(solution_cd)
    ActiveRecord::Base.connection.select_value(
      ActiveRecord::Base.send(
        :sanitize_sql_array,
        [ 'select sp_numbering(:numbering_type, :parent_cd)', 
          numbering_type: 'TK',
          parent_cd: solution_cd]))
  end
end

class UserSvc
  def select_all()
    MUser.json(MUser.all())
  end
end

