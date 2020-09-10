require_relative './player'
require_relative './board'
require_relative './setup_board'
require 'pry'

# Gameplay class
class Gameplay
  attr_reader :player1, :player2, :board, :p1_pieces, :p2_pieces, :p1_check, :p2_check
  def initialize
    @player1, @player2 = create_players
    @p1_pieces = []
    @p2_pieces = []
    @p1_check = false
    @p2_check = false
    @board = Board.new
    @setup_board = SetupBoard.new
  end

  def setup_new_game
    @p1_pieces, @p2_pieces = @setup_board.new_game(@player1, @player2, @board)
  end

  def setup_in_progress_game(p1_pieces, p2_pieces)
    @p1_pieces, @p2_pieces = @setup_board.in_progress_game(p1_pieces, p2_pieces, @board)
    # update check state if a player was in check
    toggle_check(@player1) if opp_check?(@p1_pieces, @p2_pieces, @board)
    toggle_check(@player2) if opp_check?(@p2_pieces, @p1_pieces, @board)
  end

  def play
    checkmate = checkmate?(@player2, @p2_pieces, @board)
    stalemate = stalemate?(@player2, @p2_pieces, @board)
    @board.print_board

    until checkmate || stalemate
      p1_turn = player_turn(@player1, @p1_pieces, @p2_pieces, @board)
      checkmate = checkmate?(@player2, @p2_pieces, @board)
      stalemate = stalemate?(@player2, @p2_pieces, @board)

      break if p1_turn == 'Q' || checkmate || stalemate

      p2_turn = player_turn(@player2, @p2_pieces, @p1_pieces, @board)
      break if p2_turn == 'Q'

      checkmate = checkmate?(@player1, @p1_pieces, @board)
      stalemate = stalemate?(@player1, @p1_pieces, @board)
    end
    puts 'Checkmate!, Game over' if checkmate
    puts 'Stalemate, Game over' if stalemate
  end

  private

  def player_turn(player, player_pieces, opp_pieces, board)
    p_moves = ''
    loop do
      p_moves = get_moves(player, board)
      return p_moves if p_moves == 'Q'

      break unless still_in_check?(p_moves, player_pieces, opp_pieces, board)

      puts 'King is still in check, please make another move'
    end

    execute_move(p_moves, player_pieces, opp_pieces, board)
    puts('Check') if opp_check?(player_pieces, opp_pieces, board)
    toggle_check(player) if opp_check?(player_pieces, opp_pieces, board)
  end

  # prompt for start/final squares for move
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

  # remove piece from player_piece array
  def capture_piece(p_moves, opp_pieces, board)
    # check if opponent piece is in the square
    opp_piece = square_occupied?(p_moves[1], board)
    # capture and remove piece
    opp_index = opp_pieces.find_index { |piece| piece.history.last == opp_piece.history.last } if opp_piece
    opp_pieces.delete_at(opp_index) if opp_piece
  end

  def execute_move(p_moves, player_pieces, opp_pieces, board)
    update_move_history(p_moves, board)
    capture_piece(p_moves, opp_pieces, board) # if opponent piece is in the square
    castle_rook(p_moves, board) if start_castling?(p_moves, board) # castling
    board.move_piece(p_moves[0], p_moves[1])
    promote_pawn(p_moves, player_pieces, board) if pawn_end?(p_moves, board)
    board.print_board
  end

  # king moves to start castling?
  def start_castling?(p_moves, board)
    piece = get_piece(p_moves[0], board)
    squares_moved = parse_coord(p_moves[1])[1] - parse_coord(p_moves[0])[1]
    print "piece: #{piece.class}, squares: #{squares_moved}\n"
    (piece.class == King) && (squares_moved.abs > 1)
  end

  # get moves for rook to finish castling
  def rook_castle_moves(final_king_coords, col, offset)
    rook_start = parse_square([final_king_coords[0], col])
    rook_finish = parse_square([final_king_coords[0], final_king_coords[1] + offset])
    [rook_start, rook_finish]
  end

  # execute moves to complete castling
  def castle_rook(p_moves, board)
    squares_moved = parse_coord(p_moves[1])[1] - parse_coord(p_moves[0])[1]
    final_king_coords = parse_coord(p_moves[1])
    col, offset = squares_moved.positive? ? [7, -1] : [0, 1]
    rook_castle_moves = rook_castle_moves(final_king_coords, col, offset)

    update_move_history(rook_castle_moves, board)
    board.move_piece(rook_castle_moves[0], rook_castle_moves[1])
  end

  # pawn reached end of board?
  def pawn_end?(p_moves, board)
    piece = get_piece(p_moves[1], board)
    final_coords = parse_coord(p_moves[1])
    piece.class == Pawn && final_coords[0] == 7
  end

  def promote_pawn(p_moves, player_pieces, board)
    pawn = get_piece(p_moves[1], board)
    promoted_piece = @setup_board.promoted_pawn(pawn, board)
    pawn_index = player_pieces.find_index { |piece| piece.history.last == pawn.history.last }
    player_pieces.delete_at(pawn_index)
    player_pieces.push(promoted_piece)
  end

  # opponent's king in check?
  def opp_check?(player_pieces, opponent_pieces, board)
    opp_king_square = opponent_pieces.select { |piece| piece.class == King }[0].history.last
    player_pieces.each do |piece|
      next if piece.class == King
      return true if piece.possible_moves(board).include?(opp_king_square)
    end
    false
  end

  def toggle_check(player)
    player == @player1 ? @p2_check = !@p2_check : @p1_check = !@p1_check
  end

  def still_in_check?(p_moves, player_pieces, opp_pieces, board)
    # execute the move
    opp_piece = get_piece(p_moves[1], board)
    capture_piece(p_moves, opp_pieces, board)
    board.move_piece(p_moves[0], p_moves[1])
    still_in_check = opp_check?(opp_pieces, player_pieces, board)

    # undo the move after seeing if king still in check
    board.move_piece(p_moves[1], p_moves[0])
    board.add_piece(opp_piece, p_moves[1]) if opp_piece
    opp_pieces.push(opp_piece) if opp_piece

    still_in_check
  end

  # king in check, no possible way to escape check
  def checkmate?(opponent, opponent_pieces, board)
    check = opponent == @player1 ? @p1_check : @p2_check
    opp_king = opponent_pieces.select { |piece| piece.class == King }[0]
    opp_king.possible_moves(board).length.zero? && check
  end

  # king not in check, no possible moves
  def stalemate?(opponent, opponent_pieces, board)
    check = opponent == @player1 ? @p1_check : @p2_check
    opp_moves = opponent_pieces.map { |piece| piece.possible_moves(board).length }
    opp_moves.all?(&:zero?) && !check
  end

  # misc methods used in other methods

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
end
