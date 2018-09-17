
class TaskSvc < BaseSvc
  def initialize()
    super()
    @entity = TTask
    @numbering_type = 'TK'
  end

  def fetch_new_cd(solution_cd)
    super(solution_cd)
  end

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

  def select_by_cd_no_json(cd)
    TTask.set_order_prm("")
    TTask.set_where_prm(nil)
    return TTask.with_rels().find_by(task_cd: cd)
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
    whiteboard_svc = WhiteboardSvc.new()
    task = TTask.with_rels().find(cd)
    recursive_delete(task.children_all)
    TTask.delete(cd)
    whiteboard_svc.delete_by_cd_if_exist(cd)
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

  def batch_delete(params)
    params.each do |e|
      TTask.destroy(e["task_cd"])
      TTaskTaskRel.where(task_cd_a: e["task_cd"]).delete_all()
      TTaskTaskRel.where(task_cd_b: e["task_cd"]).delete_all()
    end
  end

  def batch_update(target)
    target["rows"].each do |e|
      task = TTask.find(e["task_cd"])
      if((target["diff"]["task_type"] != nil) && (target["diff"]["task_type"] != ""))
        task.task_type = target["diff"]["task_type"]
      end
      if((target["diff"]["status_type"] != nil) && (target["diff"]["status_type"] != ""))
        task.status_type = target["diff"]["status_type"]
      end
      if((target["diff"]["name"] != nil) && (target["diff"]["name"] != ""))
        task.name = target["diff"]["name"]
      end
      if((target["diff"]["description"] != nil) && (target["diff"]["description"] != ""))
        task.description = target["diff"]["description"]
      end
      if((target["diff"]["priority_type"] != nil) && (target["diff"]["priority_type"] != ""))
        task.priority_type = target["diff"]["priority_type"]
      end
      if((target["diff"]["start_dt"] != nil) && (target["diff"]["start_dt"] != ""))
        task.start_dt = target["diff"]["start_dt"]
      end
      if((target["diff"]["end_dt"] != nil) && (target["diff"]["end_dt"] != ""))
        task.end_dt = target["diff"]["end_dt"]
      end
      task.save()
    end
  end

  def upsert(target)
    if (target["solution_cd"] == nil) || (target["solution_cd"] == "")
      return ControllerUtil.response(false, "Solution is not designated.", target)
    end

    p target
    task = TTask.where(task_cd: target["task_cd"])

    if(task.length == 0) 
      task = TTask.new()

      task["task_cd"] = fetch_new_cd(target["solution_cd"])
      task["created"] = Time.now
      task["updated"] = Time.now
      task["created_by"] = ""
      task["updated_by"] = ""
    else
      task = task[0]
    end


    task["solution_cd"] = target["solution_cd"]
    task["task_type"] = target["task_type"]
    task["name"] = target["name"]
    task["status_type"] = target["status_type"]
    task["priority_type"] = target["priority_type"]
    task["description"] = target["description"]
    task["parent_cd"] = (target["parent_cd"] != nil)? target["parent_cd"] : ""
    task["root_parent_cd"] = ""
    task["path"] = ""
    task["start_dt"] = target["start_dt"]
    task["end_dt"] = target["end_dt"]
    task["user_cd"] = target["user_cd"]

    task.save()
    if(task.parent_cd != "")
      link(task.task_cd, task.parent_cd, "TR02PR")
    else
      set_parent_root(task.task_cd)
    end

    return ControllerUtil.response(true, "Register success", task)
  end

  def select_workplans_by_task(hideClosed)
    con = ActiveRecord::Base.connection
    sql = ""
    sql += "select"
    sql += " pl.*,"
    sql += " task_cd as id,"
    sql += " task_cd as work_plan_cd,"
    sql += " parent_cd as parent,"
    sql += " pl.name as text,"
    sql += " pl.name as name,"
    sql += " start_dt as start_date,"
    sql += " end_dt as end_date,"
    sql += " pl.sort_order as sort_order"
    sql += " from t_task pl"
    if(hideClosed)
      sql += " where pl.status_type <> 'TS06CL'"
    end
    sql += " order by pl.sort_order asc"
    rows = con.select_all(sql)
    rows
  end

  def upsert_workplan(target)
    p target
    task = TTask.where(task_cd: target["task_cd"])

    if(task.length == 0) 
      task = TTask.new()

      task["task_cd"] = fetch_new_cd(target["solution_cd"])
      task["created"] = Time.now
      task["updated"] = Time.now
      task["created_by"] = ""
      task["updated_by"] = ""
    else
      task = task[0]
    end

    task["solution_cd"] = target["solution_cd"]
    # task["task_type"] = "TT01TS"
    task["task_type"] = target["task_type"]
    task["name"] = target["name"]
    task["status_type"] = target["status_type"]
    task["priority_type"] = target["priority_type"]
    task["description"] = ""
    task["parent_cd"] = (target["parent_cd"] != nil)? target["parent_cd"] : ""
    task["root_parent_cd"] = ""
    task["path"] = ""
    task["start_dt"] = target["start_date"]
    task["end_dt"] = target["end_date"]
    if ((target["task_cd"] != nil) && (target["task_cd"] != ""))
      task.sort_order = target["sort_order"]
    end
    task["progress"] = target["progress"]
    task["user_cd"] = target["user_cd"]
    task["description"] = target["description"]

    task.save()
    if(task.parent_cd != "")
      link(task.task_cd, task.parent_cd, "TR02PR")
    else
      set_parent_root(task.task_cd)
    end

    {success: true, message: "Register success", data: task}.to_json

    # target.to_json()
    task.to_json()
  end
end

