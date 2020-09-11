require_relative './piece'

# Rook piece class
class Rook < Piece
  attr_reader :symbol
  attr_accessor :history
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

  def opponent_square?(piece)
    piece && !my_piece?(piece)
  end

  def valid_empty_square?(piece, next_square)
    !piece && on_board?(next_square)
  end

  def possible_line(coord, row_coef, col_coef, board)
    inc = 1
    line = []
    loop do
      next_square = parse_square([coord[0] + (inc * row_coef), coord[1] + (inc * col_coef)])
      piece = square_occupied?(next_square, board)
      line.push(next_square) if opponent_square?(piece) || valid_empty_square?(piece, next_square)
      inc += 1
      break if piece || !on_board?(next_square)
    end
    line
  end

  def rook_moves(coord, board)
    # coefficients in directions radiate horiz/vert from rook position
    possible_moves = []
    plus_directions = [[1, 0], [0, 1], [0, -1], [-1, 0]]
    plus_directions.each { |coeffs| possible_moves += possible_line(coord, coeffs[0], coeffs[1], board) }

    possible_moves
  end
end
