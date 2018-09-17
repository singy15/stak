
class ControllerUtil
  def self.response(success, message, data)
    {success: success, message: message, data: data}.to_json
  end
end
