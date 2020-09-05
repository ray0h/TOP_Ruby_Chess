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
  attr_reader :player1, :player2, :board, :p1_pieces, :p2_pieces
  def initialize
    @player1, @player2 = create_players
    @board = Board.new
    @p1_pieces = assign_pieces('white', @player1.id)
    @p2_pieces = assign_pieces('black', @player2.id)
  end

  private

  def create_players
    player1 = Player.new('player1')
    player2 = Player.new('player2')
    [player1, player2]
  end

  def assign_pieces(player_id, color)
    king = King.new(color, player_id)
    queen = Queen.new(color, player_id)
    rook = [Rook.new(color, player_id), Rook.new(color, player_id)]
    bishop = [Bishop.new(color, player_id), Bishop.new(color, player_id)]
    knight = [Knight.new(color, player_id), Knight.new(color, player_id)]
    pawn = []
    8.times { pawn.push(Pawn.new(color, player_id)) }
    [king, queen, rook, bishop, knight, pawn]
  end
end
