# methods to help navigate boards/pieces
module BoardHelpers
  # methods to help define general movement logic

  # translate [row][col] coords from 'A2' move
  def parse_coord(square)
    square = square.split('')
    row = square[1].to_i - 1
    col = square[0].bytes[0] - 65
    [row, col]
  end

  # translate 'A2' type move from [row][col] coords
  def parse_square(coord)
    row = (coord[0] + 1).to_s
    col = (coord[1] + 65).chr
    col + row
  end

  def on_board?(square)
    coord = parse_coord(square)
    coord[0].between?(0, 7) && coord[1].between?(0, 7)
  end

  def get_piece(square, board)
    coord = parse_coord(square)
    board.grid[coord[0]][coord[1]]
  end

  def square_occupied?(square, board)
    return false unless on_board?(square)

    coord = parse_coord(square)
    space = board.grid[coord[0]][coord[1]]
    space.nil? ? false : space
  end
end
