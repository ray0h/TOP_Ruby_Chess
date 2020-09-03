require_relative './piece'

# Bishop piece class
class Bishop < Piece
  attr_reader :symbol
  def initialize(color, player_id)
    super(color, player_id)
    @symbol = @color == 'white' ? "\u2657" : "\u265D"
    @history = []
  end
end
