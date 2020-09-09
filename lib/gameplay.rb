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

  def setup_new
    @p1_pieces, @p2_pieces = @setup_board.new_game(@player1, @player2, @board)
  end

  def setup_in_progress(p1_pieces, p2_pieces)
    @setup_board.in_progress_game(p1_pieces, p2_pieces, @board)
  end

  def play
    checkmate = false
    stalemate = false
    @board.print_board

    until checkmate || stalemate
      p1_turn = player_turn(@player1, @p1_pieces, @p2_pieces, @board)
      checkmate = checkmate?(@player2, @p2_pieces, @board)
      break if p1_turn == 'Q' || checkmate

      p2_turn = player_turn(@player2, @p2_pieces, @p1_pieces, @board)
      break if p2_turn == 'Q'
      checkmate = checkmate?(@player1, @p1_pieces, @board)
    end
    puts 'Game over'
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

  def update_move_history(p_moves, board)
    my_piece = get_piece(p_moves[0], board)
    my_piece.history.push(p_moves[1])
  end

  def capture_piece(p_moves, opp_pieces, board)
    # check if opponent piece is in the square
    puts 'capturing piece?'
    opp_piece = square_occupied?(p_moves[1], board)
    # capture and remove piece
    opp_index = opp_pieces.find_index { |piece| piece.history.last == opp_piece.history.last } if opp_piece
    opp_pieces.delete_at(opp_index) if opp_piece
  end

  def move_piece(p_moves, opp_pieces, board)
    update_move_history(p_moves, board)
    capture_piece(p_moves, opp_pieces, board) # if opponent piece is in the square
    board.move_piece(p_moves[0], p_moves[1])
    board.print_board
  end

  # opponent's king in check?
  def check?(player_pieces, opponent_pieces, board)
    opp_king_square = opponent_pieces.select { |piece| piece.class.name == 'King' }[0].history.last
    player_pieces.each do |piece|
      next if piece.class.name == 'King'
      return true if piece.possible_moves(board).include?(opp_king_square)
    end
    false
  end

  def checkmate?(opponent, opponent_pieces, board)
    check = opponent == @player1 ? @p1_check : @p2_check
    opp_king = opponent_pieces.select { |piece| piece.class.name == 'King' }[0]
    opp_king.possible_moves(board).length.zero? && check
  end

  def set_check(player, check)
    if check
      player == 'player1' ? @p2_check = true : @p1_check = true
    else
      player == 'player1' ? @p2_check = false : @p1_check = false
    end
  end

  def still_in_check?(p_moves, player_pieces, opp_pieces, board)
    opp_piece = get_piece(p_moves[1], board)

    board.move_piece(p_moves[0], p_moves[1])
    still_in_check = check?(opp_pieces, player_pieces, board)
    board.move_piece(p_moves[1], p_moves[0])
    board.add_piece(opp_piece, p_moves[1]) if opp_piece
    still_in_check
  end

  def player_turn(player, player_pieces, opp_pieces, board)
    p_moves = ''
    loop do
      p_moves = get_moves(player, board)
      return p_moves if p_moves == 'Q'

      break unless still_in_check?(p_moves, player_pieces, opp_pieces, board)

      puts 'King is still in check, please make another move'
    end

    move_piece(p_moves, opp_pieces, board)
    check = check?(player_pieces, opp_pieces, board)
    puts('Check') if check
    set_check(player, check)
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

end
