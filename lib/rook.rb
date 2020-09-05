require_relative './piece'

# Rook piece class
class Rook < Piece
  attr_reader :symbol
  def initialize(color, player_id)
    super(color, player_id)
    @symbol = @color == 'white' ? "\u2656" : "\u265C"
    @history = []
  end

  def possible_moves(board)
    current_square = @history.last
    current_coords = parse_coord(current_square)
    rook_moves(current_coords, board)
  end

  private

  def possible_line(coord, row_coef, col_coef, board)
    inc = 1
    line = []
    loop do
      next_square = parse_square([coord[0] + (inc * row_coef), coord[1] + (inc * col_coef)])
      piece = square_occupied?(next_square, board)
      line.push(next_square) if (piece && !my_piece?(piece)) || (!piece && on_board?(next_square))
      inc += 1
      break if piece || !on_board?(next_square)
    end
    line
  end

  def rook_moves(coord, board)
    n = possible_line(coord, 1, 0, board)
    e = possible_line(coord, 0, 1, board)
    w = possible_line(coord, 0, -1, board)
    s = possible_line(coord, -1, 0, board)
    possible_moves = n + e + w + s
    possible_moves
  end
end
