require './lib/modules/board_helpers'

# Player class
class Player
  include BoardHelpers

  attr_reader :id
  def initialize(player_id)
    @id = player_id
  end

  def change_id
    print "#{@id}, what should I call you now? "
    new_id = STDIN.gets.to_s.chomp
    self.id = new_id
  end

  def start_move(board)
    move = prompt_first_sq(board)
    until move['valid']
      print "#{move['error_msg']}\n"
      move = prompt_first_sq(board)
    end
    init_square = move['error_msg']
    init_square
  end

  def finish_move(init_square, board)
    return init_square if %w[Q S].include?(init_square)

    move = prompt_final_sq(init_square, board)
    until move['valid']
      print "#{move['error_msg']}\n"
      move = prompt_final_sq(init_square, board)
    end
    final_square = move['error_msg']
    %w[X Q S].include?(final_square) ? final_square : [init_square, final_square]
  end

  private

  attr_writer :id

  def valid_id?(square)
    square.length == 2
  end

  def square_occupied?(square, board)
    coord = parse_coord(square)
    space = board.grid[coord[0]][coord[1]]
    space.nil? ? false : space
  end

  def my_piece?(square, board)
    piece = square_occupied?(square, board)
    piece.player_id == @id
  end

  def prompt_first_sq(board)
    print "#{@id}, pick a square: "
    init_square = STDIN.gets.to_s.chomp
    validate_square(init_square, board)
  end

  def prompt_final_sq(init_square, board)
    print "#{@id}, pick a square to move to, or press 'X' to cancel move: "
    final_square = STDIN.gets.to_s.chomp
    validate_final_square(final_square, init_square, board)
  end

  def validate_square(square, board)
    return { 'valid' => true, 'error_msg' => square } if %w[X Q S].include?(square)
    return { 'valid' => false, 'error_msg' => 'Enter a valid square' } unless valid_id?(square)
    return { 'valid' => false, 'error_msg' => 'Enter a valid square on the board' } unless on_board?(square)

    empty_sq_msg = 'That square is empty, pick a square with a piece'
    return { 'valid' => false, 'error_msg' => empty_sq_msg } unless square_occupied?(square, board)

    opp_piece_msg = 'That is opponent\'s piece, pick one of yours'
    return { 'valid' => false, 'error_msg' => opp_piece_msg } unless my_piece?(square, board)

    { 'valid' => true, 'error_msg' => square }
  end

  def validate_final_square(final_square, init_square, board)
    return { 'valid' => true, 'error_msg' => final_square } if %w[X Q S].include?(final_square)

    piece = get_piece(init_square, board)
    return { 'valid' => false, 'error_msg' => 'Enter a valid square' } unless valid_id?(final_square)
    return { 'valid' => false, 'error_msg' => 'Enter a valid square on the board' } unless on_board?(final_square)

    same_sq_err = 'That\'s the current spot, pick a square to move to'
    return { 'valid' => false, 'error_msg' =>  same_sq_err } if init_square == final_square

    not_poss_err = 'Can not move current piece there, pick another square'
    return { 'valid' => false, 'error_msg' => not_poss_err } unless piece.possible_moves(board).include?(final_square)

    { 'valid' => true, 'error_msg' => final_square }
  end
end
