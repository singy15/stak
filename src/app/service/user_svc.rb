
class UserSvc
  def select_all()
    MUser.json(MUser.all().order("user_cd"))
  end

  def fetch_new_cd()
    ActiveRecord::Base.connection.select_value(
      ActiveRecord::Base.send(
        :sanitize_sql_array,
        [ 'select sp_numbering(:numbering_type, :parent_cd)', 
          numbering_type: 'UR',
          parent_cd: '']))
  end
end

