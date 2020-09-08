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
  attr_reader :player1, :player2, :board, :p1_pieces, :p2_pieces, :p1_check, :p2_check
  def initialize
    @player1, @player2 = create_players
    @board = Board.new
    @p1_pieces = create_pieces(@player1.id, 'white')
    @p2_pieces = create_pieces(@player2.id, 'black')
    @p1_check = false
    @p2_check = false
    setup_board(@p1_pieces, @p2_pieces, @board)
  end

  def play
    checkmate = false
    stalemate = false
    @board.print_board

    until checkmate || stalemate
      p1_turn = player_turn(@player1, @p1_pieces, @p2_pieces, @board)
      break if p1_turn == 'Q'

      p2_turn = player_turn(@player2, @p2_pieces, @p1_pieces, @board)
      break if p2_turn == 'Q'
    end
  end

  private

  def check?(player_pieces, opponent_pieces, board)
    opp_king_square = opponent_pieces[4].history.last
    # piece = get_piece(p_moves[1], board)
    player_pieces.each do |piece|
      next if piece.class.name == 'King'
      return true if piece.possible_moves(board).include?(opp_king_square)
    end
    false
  end

  def get_moves(player, board)
    p_moves = 'X'
    while p_moves == 'X'
      init_move = player.start_move(board)
      p_moves = player.finish_move(init_move, board)
      puts 'Canceling move' if p_moves == 'X'
    end
    p_moves
  end

  def update_move_history(p_moves, board)
    my_piece = get_piece(p_moves[0], board)
    my_piece.history.push(p_moves[1])
  end

  def capture_piece(p_moves, opp_pieces, board)
    # check if opponent piece is in the square
    opp_piece = square_occupied?(p_moves[1], board)
    # capture and remove piece
    opp_index = opp_pieces.find_index { |piece| piece.class.name == opp_piece.class.name } if opp_piece
    opp_pieces.delete_at(opp_index) if opp_piece
  end

  def move_piece(p_moves, opp_pieces, board)
    update_move_history(p_moves, board)
    capture_piece(p_moves, opp_pieces, board) # if opponent piece is in the square
    board.move_piece(p_moves[0], p_moves[1])
    board.print_board
  end

  def player_turn(player, player_pieces, opp_pieces, board)
    p_moves = get_moves(player, board)
    return p_moves if p_moves == 'Q'

    move_piece(p_moves, opp_pieces, board)
    puts('Check') if check?(player_pieces, opp_pieces, board)
    (player == 'player1' ? @p2_check = true : @p1_check = true) if check?(player_pieces, opp_pieces, board)
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

  def create_pieces(player_id, color)
    backrow = [Rook.new(color, player_id), Knight.new(color, player_id), Bishop.new(color, player_id)]
    backrow.push(Queen.new(color, player_id))
    backrow.push(King.new(color, player_id))
    backrow += [Bishop.new(color, player_id), Knight.new(color, player_id), Rook.new(color, player_id)]
    frontrow = []
    8.times { frontrow.push(Pawn.new(color, player_id)) }

    backrow + frontrow
  end

  def setup_pieces(pieces, back_row, front_row, board)
    0.upto(7) do |col|
      back_half = col + 8
      board.grid[back_row][col] = pieces[col]
      pieces[col].history.push(parse_square([back_row, col]))
      board.grid[front_row][col] = pieces[back_half]
      pieces[back_half].history.push(parse_square([front_row, col]))
    end
  end

  def setup_board(p1_pieces, p2_pieces, board)
    setup_pieces(p1_pieces, 0, 1, board)
    setup_pieces(p2_pieces, 7, 6, board)
  end
end

