require_relative './player'
require_relative './board'
require_relative './setup_board'
require './lib/modules/moves'
require './lib/modules/board_state'
require './lib/modules/save_load'

require 'yaml'
require 'pry'

# Gameplay class
class Gameplay
  attr_reader :player1, :player2, :board, :p1_pieces, :p2_pieces, :p1_check, :p2_check
  include Moves
  include BoardState
  include SaveLoad
 
  def initialize
    @player1, @player2 = create_players
    @p1_pieces = []
    @p2_pieces = []
    @p1_check = false
    @p2_check = false
    @last_move = []
    @directory = './saved_games'
    @files = Dir.glob("#{@directory}/**/*")
    @board = Board.new
    @setup_board = SetupBoard.new
  end

  def setup_new_game
    @p1_pieces, @p2_pieces = @setup_board.new_game(@player1, @player2, @board)
  end

  def setup_in_progress_game(p1_pieces, p2_pieces, last_move)
    @p1_pieces, @p2_pieces = @setup_board.in_progress_game(p1_pieces, p2_pieces, @board)
    # update check state if a player was in check
    @last_move = last_move
    toggle_check(@player1) if opp_check?(@p1_pieces, @p2_pieces, @board)
    toggle_check(@player2) if opp_check?(@p2_pieces, @p1_pieces, @board)
  end

  def setup_board
    setup_new_game if @files.length.zero?
    list_saved_games(@files)
    choice = choose_saved_game(@files)
    setup_new_game if choice == 'n'
    p1_pieces, p2_pieces, last_move = load_from_yaml(choice) if choice != 'n'
    setup_in_progress_game(p1_pieces, p2_pieces, last_move)
  end

  def skip_p1?
    return false if @last_move.length.zero?

    p @last_move
    piece = get_piece(@last_move[1], @board)
    piece.player_id == @player1.id
  end

  def play
    p @last_move
    checkmate = checkmate?(@player2, @p2_pieces, @p1_pieces, @board)
    stalemate = stalemate?(@player2, @p2_pieces, @board)
    @board.print_board

    until checkmate || stalemate
      p1_turn = player_turn(@player1, @p1_pieces, @p2_pieces, @board) unless skip_p1?
      checkmate = checkmate?(@player2, @p2_pieces, @p1_pieces, @board)
      stalemate = stalemate?(@player2, @p2_pieces, @board)

      break if %w[Q S].include?(p1_turn) || checkmate || stalemate

      p2_turn = player_turn(@player2, @p2_pieces, @p1_pieces, @board)
      break if %w[Q S].include?(p2_turn)

      checkmate = checkmate?(@player1, @p1_pieces, @p2_pieces, @board)
      stalemate = stalemate?(@player1, @p1_pieces, @board)
    end
    puts 'Checkmate!, Game over' if checkmate
    puts 'Stalemate, Game over' if stalemate
  end

  private

  def save_game
    directory = @directory + '/' + 'game' + (@files.length + 1).to_s + '.txt'
    File.open(directory, 'w') do |f|
      YAML.dump({ p1_pieces: @p1_pieces, p2_pieces: @p2_pieces, last_move: @last_move }, f)
    end
    print "game saved...goodbye \n"
  end

  def player_turn(player, player_pieces, opp_pieces, board)
    toggle_enpassant(@last_move, board)
    p_moves = validate_moves(player, player_pieces, opp_pieces, board)
    save_game if p_moves == 'S'
    return p_moves if %w[Q S].include?(p_moves)

    execute_move(p_moves, player_pieces, opp_pieces, board)
    toggle_enpassant(@last_move, board)
    @last_move = p_moves
    puts('Check') if opp_check?(player_pieces, opp_pieces, board)
    toggle_check(player) if opp_check?(player_pieces, opp_pieces, board)
  end

  def toggle_check(player)
    player == @player1 ? @p2_check = !@p2_check : @p1_check = !@p1_check
  end

  # opp king in check, no possible way to escape check
  def checkmate?(opponent, opponent_pieces, my_pieces, board)
    in_check = opponent == @player1 ? @p1_check : @p2_check
    opp_king = opponent_pieces.select { |piece| piece.class == King }[0]
    no_king_moves = opp_king.possible_moves(board).length.zero?
    checkers = checking_pieces(my_pieces, opponent_pieces, board)
    checker_blocker = block_checker?(my_pieces, opponent_pieces, board)
    checker_remover = remove_checker?(my_pieces, opponent_pieces, board)
    # print "#{in_check}, #{no_king_moves}, #{checkers.length}, #{checker_blocker}, #{checker_remover} \n"
    no_king_moves && in_check && (checkers.length > 1 || (!checker_blocker && !checker_remover))
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
