require_relative './player'
require_relative './board'
require './lib/modules/setup_board'
require './lib/modules/moves'
require './lib/modules/board_state'
require './lib/modules/save_load'
require './lib/modules/board_helpers'
require 'yaml'

# Main controllers/logic for setting up and playing a game of chess
class Gameplay
  attr_reader :player1, :player2, :board, :p1_pieces, :p2_pieces
  include Moves
  include BoardHelpers
  include BoardState
  include SaveLoad
  include SetupBoard

  def initialize
    @player1 = Player.new('player1')
    @player2 = Player.new('player2')
    @p1_pieces = []
    @p2_pieces = []
    @last_move = []
    @directory = './saved_games'
    @files = Dir.glob("#{@directory}/**/*")
    @board = Board.new
  end

  def setup_new_game
    @p1_pieces, @p2_pieces = new_game(@player1, @player2, @board)
  end

  def setup_in_progress_game(p1_pieces, p2_pieces, last_move)
    @p1_pieces, @p2_pieces = in_progress_game(p1_pieces, p2_pieces, @board)
    @last_move = last_move
  end

  def setup_board
    setup_new_game if @files.length.zero?
    list_saved_games(@files)
    choice = choose_saved_game(@files)
    if choice == 'n'
      setup_new_game
    else
      p1_pieces, p2_pieces, last_move = load_from_yaml(choice)
      setup_in_progress_game(p1_pieces, p2_pieces, last_move)
    end
  end

  def play
    quit_game = initial_state
    until quit_game
      quit_game = move_and_eval(@player1, @p1_pieces, @p2_pieces, @board) unless skip_p1?
      break if quit_game

      quit_game = move_and_eval(@player2, @p2_pieces, @p1_pieces, @board)
    end
  end

  private

  def initial_state
    checkmate = checkmate?(@p2_pieces, @p1_pieces, @board)
    stalemate = stalemate?(@p1_pieces, @p2_pieces, @board)
    @board.print_board
    checkmate || stalemate
  end

  # use for loading saved game
  def skip_p1?
    return false if @last_move.length.zero?

    piece = get_piece(@last_move[1], @board)
    piece.player_id == @player1.id
  end

  def player_turn(player, player_pieces, opp_pieces, board)
    # flag pawn as available to capture en passant in that scenario
    toggle_enpassant(@last_move, board)

    # get player's moves
    p_moves = validate_moves(player, player_pieces, opp_pieces, board)

    # save game if directed
    save_game(@files, @directory, @p1_pieces, @p2_pieces, @last_move) if p_moves == 'S'
    # exit turn if Quitting or Saving game
    return p_moves if %w[Q S].include?(p_moves)

    execute_move(p_moves, player_pieces, opp_pieces, board)
    # remove any active en passant flag 
    toggle_enpassant(@last_move, board)
    @last_move = p_moves
    puts('Check') if opp_check?(player_pieces, opp_pieces, board)
  end

  def move_and_eval(player, player_pieces, opp_pieces, board)
    p_turn = player_turn(player, player_pieces, opp_pieces, board)
    checkmate = checkmate?(opp_pieces, player_pieces, board)
    stalemate = stalemate?(player_pieces, opp_pieces, board)

    %w[Q S].include?(p_turn) || checkmate || stalemate
  end
end
