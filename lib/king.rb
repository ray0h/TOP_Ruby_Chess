require_relative './piece'

# King piece class
class King < Piece
  attr_reader :symbol
  def initialize(color, player_id)
    super(color, player_id)
    @symbol = @color == 'white' ? "\u2654" : "\u265A"
    @history = []
  end
end
