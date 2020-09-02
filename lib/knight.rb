require_relative './piece'

# knight piece class
class Knight < Piece
  attr_reader :symbol
  def initialize(color, player_id)
    super(color, player_id)
    @symbol = @color == 'white' ? "\u2658" : "\u265E"
    @history = []
  end

end
