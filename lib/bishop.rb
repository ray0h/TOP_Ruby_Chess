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

  def possible_diagonal(coord, row_coef, col_coef, board)
    inc = 1
    diagonals = []
    loop do
      next_square = parse_square([coord[0] + (inc * row_coef), coord[1] + (inc * col_coef)])
      piece = square_occupied?(next_square, board)
      diagonals.push(next_square) if (piece && !my_piece?(piece)) || (!piece && on_board?(next_square))
      inc += 1
      break if piece || !on_board?(next_square)
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
