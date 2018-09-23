
class BaseSvc
  def initialize()
    @numbering_type = nil
    @entity = nil
  end

  def select_all()
    @entity.all()
  end

  def select_all_order()
    rows = select_all().default_order
    ResultSetGrid.new(rows, rows.length)
  end

  def select_first()
    @entity.first
  end

  def delete_by_cd(cd)
    @entity.delete(cd)
    ResultSet.new(nil, true, "Delete success.")
  end

  def fetch_new_cd(parent_cd)
    ActiveRecord::Base.connection.select_value(
      ActiveRecord::Base.send(
        :sanitize_sql_array,
        [ 'select sp_numbering(:numbering_type, :parent_cd)', 
          numbering_type: @numbering_type,
          parent_cd: parent_cd]))
  end
end

