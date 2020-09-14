# Chessboard class
class Board
  attr_accessor :grid
  def initialize
    @grid = create_empty_grid
  end

  def print_board(grid = @grid)
    system 'clear'
    top = "   _ _ _ _ _ _ _ _\n"
    7.downto(0) do |i|
      row = "#{i + 1} |"
      0.upto(7) { |j| row += grid[i][j].nil? ? '_|' : "#{grid[i][j].symbol}|" }
      top += row + "\n"
    end
    bot = "   A B C D E F G H\nEnter 'Q'/'S' anytime to (Q)uit/(S)ave game\n\n"
    top += bot
    print top
  end

  def add_piece(piece, square, grid = @grid)
    coord = parse_coord(square)
    grid[coord[0]][coord[1]] = piece
  end

  def remove_piece(square, grid = @grid)
    coord = parse_coord(square)
    grid[coord[0]][coord[1]] = nil
  end

  def move_piece(start, final, grid = @grid)
    start_coord = parse_coord(start)
    final_coord = parse_coord(final)
    piece = grid[start_coord[0]][start_coord[1]]
    grid[start_coord[0]][start_coord[1]] = nil
    grid[final_coord[0]][final_coord[1]] = piece
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

  def parse_coord(square)
    square = square.split('')
    row = square[1].to_i - 1
    col = square[0].bytes[0] - 65
    [row, col]
  end
end
