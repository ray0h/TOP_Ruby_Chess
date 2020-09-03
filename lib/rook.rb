require_relative './piece'

# Rook piece class
class Rook < Piece
  attr_reader :symbol
  def initialize(color, player_id)
    super(color, player_id)
    @symbol = @color == 'white' ? "\u2656" : "\u265C"
    @history = []
  end
end
