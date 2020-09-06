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
    @p1_pieces = assign_pieces(@player1.id, 'white')
    @p2_pieces = assign_pieces(@player2.id, 'black')
    setup_board
  end

  def play
    init_move = @player1.start_move(@board)
    moves = @player1.finish_move(init_move, @board)
    board.move_piece(moves[0], moves[1])
  end

  private

  def parse_square(coord)
    row = (coord[0] + 1).to_s
    col = (coord[1] + 65).chr
    col + row
  end

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

    [king, queen, bishop, knight, rook, pawn]
  end

  def place_single(piece, row, square)
    @board.grid[row][square] = piece
    piece.history.push(parse_square([square, row]))
  end

  def place_pair(pair, row, inc_from_end)
    @board.grid[row][0 + inc_from_end] = pair[0]
    @board.grid[row][7 - inc_from_end] = pair[1]
    pair[0].history.push(parse_square([0 + inc_from_end, row]))
    pair[1].history.push(parse_square([7 - inc_from_end, row]))
  end

  def setup_pieces(pieces, back_row, front_row)
    # king
    place_single(pieces[0], back_row, 4)
    # queen
    place_single(pieces[1], back_row, 3)
    # bishops
    place_pair(pieces[2], back_row, 2)
    # knights
    place_pair(pieces[3], back_row, 1)
    # rooks
    place_pair(pieces[4], back_row, 0)
    # pawns
    0.upto(7) do |i|
      @board.grid[front_row][i] = pieces[5][i]
      pieces[5][i].history.push(parse_square([front_row, i]))
    end
  end

  def setup_board
    setup_pieces(@p2_pieces, 7, 6)
    setup_pieces(@p1_pieces, 0, 1)
  end
end

# game = Gameplay.new
# game.play
