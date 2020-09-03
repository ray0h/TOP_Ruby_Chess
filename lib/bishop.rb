require_relative './piece'

# Bishop piece class
class Bishop < Piece
  attr_reader :symbol
  def initialize(color, player_id)
    super(color, player_id)
    @symbol = @color == 'white' ? "\u2657" : "\u265D"
    @history = []
  end

  def possible_moves(board)
    current_square = @history.last
    current_coords = parse_coord(current_square)
    bishop_moves(current_coords, board)
  end

  private

  def parse_square(coord)
    row = (coord[0] + 1).to_s
    col = (coord[1] + 65).chr
    col + row
  end

  def possible_diagonal(coord, row_coef, col_coef, board)
    inc = 1
    diagonals = []
    square = parse_square(coord)
    while on_board?(square)
      square = parse_square([coord[0] + (inc * row_coef), coord[1] + (inc * col_coef)])
      break if square_occupied?(square, board)

      diagonals.push(square) if on_board?(square)
      inc += 1
    end
    diagonals
  end

  def bishop_moves(coord, board)
    nw = possible_diagonal(coord, 1, -1, board)
    ne = possible_diagonal(coord, 1, 1, board)
    sw = possible_diagonal(coord, -1, -1, board)
    se = possible_diagonal(coord, -1, 1, board)
    possible_moves = nw + ne + sw + se
    possible_moves
  end
end
