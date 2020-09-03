require_relative './piece'

# knight piece class
class Knight < Piece
  attr_reader :symbol
  def initialize(color, player_id)
    super(color, player_id)
    @symbol = @color == 'white' ? "\u2658" : "\u265E"
    @history = []
  end

  def possible_moves
    current_square = @history.last
    current_coords = parse_coord(current_square)

    knight_moves(current_coords)
  end

  private

  def parse_move(coord)
    row = (coord[0] + 1).to_s
    col = (coord[1] + 65).chr
    col + row
  end

  def knight_moves(coords)
    poss_moves = []
    (-2..2).each do |i|
      (-2..2).each do |j|
        next if i.abs == j.abs || i.zero? || j.zero?

        move = parse_move([(coords[0] + i), (coords[1] + j)])
        poss_moves.push(move) if on_board?(move)
      end
    end
    poss_moves
  end
end
