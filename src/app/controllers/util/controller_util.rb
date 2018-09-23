
class ControllerUtil
  def self.response(success, message, data)
    {success: success, message: message, data: data}.to_json
  end

  # def json_grid(total, rows)
  #   ({total: total, rows: rows}).to_json()
  # end

  def self.response_grid(total, rows)
    ({total: total, rows: rows}).to_json()
  end

  def self.to_response_grid(result_set_grid)
    {total: result_set_grid.total, rows: result_set_grid.rows}.to_json()
  end
end
