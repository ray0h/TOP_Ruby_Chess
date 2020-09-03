require_relative './piece'

# Queen piece class
class Queen < Piece
  attr_reader :symbol
  def initialize(color, player_id)
    super(color, player_id)
    @symbol = @color == 'white' ? "\u2655" : "\u265B"
    @history = []
  end
end
