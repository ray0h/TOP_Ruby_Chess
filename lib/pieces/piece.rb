require './lib/modules/board_helpers'

# Generic Chess Piece Class
class Piece
  include BoardHelpers

  attr_accessor :color, :player_id, :history, :opponent
  def initialize(color, player_id)
    @color = color
    @player_id = player_id
    @history = []
    @opponent = @color == 'white' ? 'black ' : 'white'
  end

  def first_move?
    @history.length < 2
  end

  private

  def my_piece?(piece)
    return false unless piece

    piece.color == @color
  end
end
