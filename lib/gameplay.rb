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
    checkmate = false
    stalemate = false

    until checkmate || stalemate
      p1_moves = get_moves(@player1, @board)
      break if p1_moves == 'Q'

      move_piece(p1_moves, @p2_pieces, @board)

      p2_moves = get_moves(@player2, @board)
      break if p2_moves == 'Q'

      move_piece(p2_moves, @p1_pieces, @board)
    end
  end

  private

  def get_moves(player, board)
    p_moves = 'X'
    while p_moves == 'X'
      init_move = player.start_move(board)
      p_moves = player.finish_move(init_move, board)
      puts 'Canceling move' if p_moves == 'X'
    end
    p_moves
  end

  def move_piece(p_moves, opp_pieces, board)
    # check if piece is captured
    my_piece = get_piece(p_moves[0], board)
    my_piece.history.push(p_moves[1])
    opp_piece = square_occupied?(p_moves[1], @board)
    # remove opp piece from board/piece list
    opp_pieces.delete_at(opp_pieces.find_index { |piece| piece.class.name == opp_piece.class.name }) if opp_piece
    # move piece
    board.move_piece(p_moves[0], p_moves[1])
  end

  def parse_coord(square)
    square = square.split('')
    row = square[1].to_i - 1
    col = square[0].bytes[0] - 65
    [row, col]
  end

  def parse_square(coord)
    row = (coord[0] + 1).to_s
    col = (coord[1] + 65).chr
    col + row
  end

  def get_piece(square, board)
    coord = parse_coord(square)
    board.grid[coord[0]][coord[1]]
  end

  def square_occupied?(square, board)
    coord = parse_coord(square)
    space = board.grid[coord[0]][coord[1]]
    space.nil? ? false : space
  end

  def create_players
    player1 = Player.new('player1')
    player2 = Player.new('player2')
    [player1, player2]
  end

  def assign_pieces(player_id, color)
    backrow = [Rook.new(color, player_id), Knight.new(color, player_id), Bishop.new(color, player_id)]
    backrow.push(Queen.new(color, player_id))
    backrow.push(King.new(color, player_id))
    backrow += [Bishop.new(color, player_id), Knight.new(color, player_id), Rook.new(color, player_id)]
    frontrow = []
    8.times { frontrow.push(Pawn.new(color, player_id)) }

    backrow + frontrow
  end

  def setup_pieces(pieces, back_row, front_row)
    # back row
    0.upto(7) do |col|
      @board.grid[back_row][col] = pieces[col]
      pieces[col].history.push(parse_square([back_row, col]))
      @board.grid[front_row][col] = pieces[col + 8]
      pieces[col + 8].history.push(parse_square([front_row, col]))
    end
  end

  def setup_board
    setup_pieces(@p2_pieces, 7, 6)
    setup_pieces(@p1_pieces, 0, 1)
  end
end

# game = Gameplay.new
# game.play
