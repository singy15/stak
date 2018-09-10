
class WhiteboardSvc < BaseSvc
  def initialize()
    super()
    @entity = TWhiteboard
    @numbering_type = ''
  end

  def fetch_new_cd()
    super("")
  end

  def select_first()
    @entity.find('00-0000')
  end

  def select_by_cd(cd)
    @entity.find(cd)
  end

  def select_exist_by_cd(cd)
    if(@entity.find_by(whiteboard_cd: cd))
      true
    else
      false
    end
  end

  def delete_by_cd_if_exist(cd)
    r = @entity.find_by(whiteboard_cd: cd)
    if(r != nil)
      r.delete()
    end
  end

  def select_insert_by_cd(cd)
    r = @entity.find_by(whiteboard_cd: cd)
    if(r == nil)
      new_r = @entity.new()
      new_r["whiteboard_cd"] = cd
      new_r["task_cd"] = cd
      new_r.save()
      new_r
    else
      r
    end
  end

  def update_first_content(content)
    fir = select_first()
    fir.content = content
    fir.save()
  end

  def update_content(cd, content)
    fir = select_by_cd(cd)
    fir.content = content
    fir.save()
  end
end

