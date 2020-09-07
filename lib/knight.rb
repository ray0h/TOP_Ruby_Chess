require_relative './piece'

# knight piece class
class Knight < Piece
  attr_reader :symbol
  def initialize(color, player_id)
    super(color, player_id)
    @symbol = @color == 'white' ? "\u2658" : "\u265E"
    @history = []
  end

  def possible_moves(board)
    current_square = @history.last
    current_coords = parse_coord(current_square)

    knight_moves(current_coords, board)
  end

  private

  def valid_empty_square?(piece, square)
    !piece && on_board?(square)
  end

  def opponent_piece?(piece)
    piece && !my_piece?(piece)
  end

  def eval_move(coords, row_inc, col_inc, board)
    move = parse_square([(coords[0] + row_inc), (coords[1] + col_inc)])
    piece = square_occupied?(move, board)
    opponent_piece?(piece) || valid_empty_square?(piece, move) ? move : false
  end

  def knight_moves(coords, board)
    poss_moves = []
    (-2..2).each do |i|
      (-2..2).each do |j|
        next if i.abs == j.abs || i.zero? || j.zero?

        move = eval_move(coords, i, j, board)
        poss_moves.push(move) if move
      end
    end
    poss_moves
  end
end
