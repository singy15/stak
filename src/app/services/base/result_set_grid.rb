
class ResultSetGrid
  attr_accessor :rows, :total

  def initialize(rows, total)
    @rows = rows
    @total = total
  end
end

