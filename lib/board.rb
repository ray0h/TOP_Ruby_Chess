# Chessboard class
class Board
  attr_accessor :grid
  def initialize
    @grid = create_empty_grid
  end

  private

  def create_empty_grid
    grid = []
    0.upto(7) do
      row = Array.new(8) { nil }
      grid.push(row)
    end
    grid
  end
end
 