
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
    @entity.find('00-0000-00')
  end

  def update_first_content(content)
    fir = select_first()
    fir.content = content
    fir.save()
  end
end

