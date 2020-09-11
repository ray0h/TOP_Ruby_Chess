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

  def opponent_square?(piece)
    piece && !my_piece?(piece)
  end

  def valid_empty_square?(piece, next_square)
    !piece && on_board?(next_square)
  end

  def possible_diagonal(coord, row_coef, col_coef, board)
    inc = 1
    diagonals = []
    loop do
      next_square = parse_square([coord[0] + (inc * row_coef), coord[1] + (inc * col_coef)])
      piece = square_occupied?(next_square, board)
      diagonals.push(next_square) if opponent_square?(piece) || valid_empty_square?(piece, next_square)
      inc += 1
      break if piece || !on_board?(next_square)
    end
    diagonals
  end

  def bishop_moves(coord, board)
    # coefficients in directions radiate diagonally from bishop position
    possible_moves = []
    x_directions = [[1, -1], [1, 1], [-1, -1], [-1, 1]]
    x_directions.each { |coeffs| possible_moves += possible_diagonal(coord, coeffs[0], coeffs[1], board) }

    possible_moves
  end
end
