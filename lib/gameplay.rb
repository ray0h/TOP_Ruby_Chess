require_relative './player'
require_relative './board'
require_relative './piece'
require_relative './pawn'
require_relative './knight'
require_relative './bishop'
require_relative './rook'
require_relative './queen'
require_relative './king'

# Gameplay class
class Gameplay
  attr_reader :player1, :player2, :board
  def initialize
    @player1, @player2 = create_players
    @board = Board.new
  end

  private

  def create_players
    player1 = Player.new('player1')
    player2 = Player.new('player2')
    [player1, player2]
  end
end
