
class UserSvc < BaseSvc
  def initialize()
    super()
    @entity = MUser
    @numbering_type = 'UR'
  end

  def fetch_new_cd()
    super("")
  end

  def upsert(target)
    if (target["name"] == nil) || (target["name"] == "")
      return {success: false, message: "User name should not be blank.", data: target}.to_json
    end

    p target
    user = MUser.where(user_cd: target["user_cd"])

    if(user.length == 0) 
      user = MUser.new()

      user["user_cd"] = fetch_new_cd()
      user["created"] = Time.now
      user["updated"] = Time.now
      user["created_by"] = ""
      user["updated_by"] = ""
    else
      user = user[0]
    end

    user["name"] = target["name"]

    user.save()

    {success: true, message: "Register success", data: user}.to_json
  end
end

