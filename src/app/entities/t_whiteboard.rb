
class TWhiteboard < ActiveRecord::Base
  self.table_name = 't_whiteboard'

  def self.json(src)
    src.to_json()
  end
end

