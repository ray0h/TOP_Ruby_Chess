# Chessboard class
class Board
  attr_accessor :grid
  def initialize
    @grid = create_empty_grid
  end

  def print_board(grid = @grid)
    top = "   _ _ _ _ _ _ _ _\n"
    7.downto(0) do |i|
      row = "#{i + 1} |"
      0.upto(7) { |j| row += grid[i][j].nil? ? '_|' : "#{grid[i][j]}|" }
      top += row + "\n"
    end
    col = "   A B C D E F G H\n\n"
    top += col
    print top
  end

  def add(piece, square, grid = @grid)
    coord = parse_square(square)
    grid[coord[0]][coord[1]] = piece
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

  def parse_square(sq)
    sq = sq.split('')
    row = sq[1].to_i - 1
    col = sq[0].bytes[0] - 65
    [row, col]
  end
end
