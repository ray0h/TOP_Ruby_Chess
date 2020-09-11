require_relative './player'
require_relative './board'
require_relative './setup_board'
require './lib/modules/moves'
require './lib/modules/board_state'

require 'yaml'
require 'pry'

# Gameplay class
class Gameplay
  attr_reader :player1, :player2, :board, :p1_pieces, :p2_pieces, :p1_check, :p2_check
  include Moves
  include BoardState
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

  def list_saved_games
    print "Saved chess games: \n"
    @files.each_with_index do |file, ind|
      print "#{ind + 1}. #{file} \n"
    end
  end

  def choose_saved_game
    choices = Array.new(@files.length) { |el| (el + 1).to_s }
    print "Choose a game to load, or enter 'N' to start new game: \n"
    choice = ''
    until choices.include?(choice) || choice == 'n'
      print 'choice: '
      choice = STDIN.gets.to_s.chomp.downcase
    end
    choice != 'n' ? @files[choice.to_i - 1].to_s : 'n'
  end

  def load_from_yaml(path)
    file = File.open(path, 'r')
    contents = file.read
    file.close
    data = YAML.load contents
    [data[:p1_pieces], data[:p2_pieces], data[:last_move]]
    # File.delete(path) # delete file after loading?
  end

  def setup_board
    setup_new_game if @files.length.zero?
    list_saved_games
    choice = choose_saved_game
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

  # # opponent's king in check?
  # def opp_check?(player_pieces, opponent_pieces, board)
  #   opp_king_square = opponent_pieces.select { |piece| piece.class == King }[0].history.last
  #   player_pieces.each do |piece|
  #     next if piece.class == King
  #     return true if piece.possible_moves(board).include?(opp_king_square)
  #   end
  #   false
  # end

  def toggle_check(player)
    player == @player1 ? @p2_check = !@p2_check : @p1_check = !@p1_check
  end

  # def fast_forward_move(p_moves, opp_pieces, board)
  #   my_piece = get_piece(p_moves[0], board)
  #   my_piece.history.push(p_moves[1]) if my_piece.class == King
  #   capture_piece(p_moves, opp_pieces, board)
  #   board.move_piece(p_moves[0], p_moves[1])
  # end

  # def rewind_move(p_moves, board)
  #   board.move_piece(p_moves[1], p_moves[0])
  #   opp_piece = get_piece(p_moves[1], board)
  #   board.add_piece(opp_piece, p_moves[1]) if opp_piece
  #   opp_pieces.push(opp_piece) if opp_piece
  #   my_piece = get_piece(p_moves[0], board)
  #   my_piece.history.pop if my_piece.class == King
  # end

  # def still_in_check?(p_moves, player_pieces, opp_pieces, board)
  #   fast_forward_move(p_moves, opp_pieces, board)
  #   # check if move eliminates check
  #   still_in_check = opp_check?(opp_pieces, player_pieces, board)
  #   rewind_move(p_moves, board)

  #   still_in_check
  # end

  # # array id'ing piece(s) that place king in check
  # def checking_pieces(my_pieces, opponent_pieces, board)
  #   opp_king_square = opponent_pieces.select { |piece| piece.class == King }[0].history.last
  #   checking_pieces = my_pieces.select { |piece| piece.possible_moves(board).include?(opp_king_square) }
  #   checking_pieces
  # end

  # # verify if opponent pieces can capture piece placing their king in check
  # def remove_checker?(my_pieces, opponent_pieces, board)
  #   checker = checking_pieces(my_pieces, opponent_pieces, board)
  #   return false unless checker.length == 1

  #   checker_square = checker[0].history.last
  #   checker_removers = opponent_pieces.select { |piece| piece.possible_moves(board).include?(checker_square) }
  #   checker_removers.length.positive?
  # end

  # def horiz_btwn_squares(king_coords, checker_coords)
  #   squares = []
  #   if king_coords[1] > checker_coords[1]
  #     min = checker_coords[1] + 1
  #     max = king_coords[1] - 1
  #   else
  #     min = king_coords[1] + 1
  #     max = checker_coords[1] - 1
  #   end
  #   min.upto(max) { |i| squares.push(parse_square([king_coords[0], i])) }
  #   squares
  # end

  # def vert_btwn_squares(king_coords, checker_coords)
  #   squares = []
  #   if king_coords[0] > checker_coords[0]
  #     min = checker_coords[0] + 1
  #     max = king_coords[0] - 1
  #   else
  #     min = king_coords[0] + 1
  #     max = checker_coords[0] - 1
  #   end
  #   min.upto(max) { |i| squares.push(parse_square([i, king_coords[1]])) }
  #   squares
  # end

  # def diag_offsets(king_coords, checker_coords)
  #   row = king_coords[0] > checker_coords[0] ? -1 : 1
  #   col = king_coords[1] > checker_coords[1] ? -1 : 1
  #   iter = (king_coords[0] - checker_coords[0]).abs - 1
  #   [row, col, iter]
  # end

  # def diag_btwn_squares(king_coords, checker_coords)
  #   squares = []
  #   row, col, iter = diag_offsets(king_coords, checker_coords)
  #   1.upto(iter) do |i|
  #     squares.push(parse_square([king_coords[0] + (row * i), king_coords[1] + (col * i)]))
  #   end
  #   squares
  # end

  # def get_btwn_squares(opp_king_square, checker_square)
  #   king_coords = parse_coord(opp_king_square)
  #   checker_coords = parse_coord(checker_square)
  #   btwn_squares = if king_coords[0] == checker_coords[0] # horiz line
  #                    horiz_btwn_squares(king_coords, checker_coords)
  #                  elsif king_coords[1] == checker_coords[1] # vert line
  #                    vert_btwn_squares(king_coords, checker_coords)
  #                  else # diagonal line
  #                    diag_btwn_squares(king_coords, checker_coords)
  #                  end
  #   btwn_squares
  # end

  # def get_blockers(opp_pieces, checker, board)
  #   opp_king_square = opp_pieces.select { |piece| piece.class == King }[0].history.last
  #   checker_square = checker[0].history.last
  #   # get squares btwn king and attacking piece
  #   btwn_squares = get_btwn_squares(opp_king_square, checker_square)

  #   # if btwn_squares, for each square, see if an opponents piece can move here
  #   blockers = btwn_squares&.map { |square| opp_pieces.select { |piece| piece.possible_moves(board).include?(square) } }

  #   blockers ? blockers.flatten : []
  # end

  # # verify if opponent pieces can block piece placing their king in check
  # def block_checker?(my_pieces, opp_pieces, board)
  #   checker = checking_pieces(my_pieces, opp_pieces, board)
  #   mult_lines = [Rook, Bishop, Queen].include?(checker.class)
  #   return false unless checker.length == 1 || mult_lines

  #   blockers = get_blockers(opp_pieces, checker, board)
  #   blockers.length.positive?
  # end

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
