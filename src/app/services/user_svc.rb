
class UserSvc < BaseSvc
  def initialize()
    super()
    @entity = MUser
    @numbering_type = 'UR'
  end

  def fetch_new_cd()
    super("")
  end
end

