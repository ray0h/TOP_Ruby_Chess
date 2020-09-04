# Player class
class Player
  attr_reader :id
  def initialize(player_id)
    @id = player_id
  end

  def change_id
    print "#{id}, what should I call you now? "
    new_id = gets.to_s.chomp
    self.id = new_id
  end

  def start_move(board)
    print "#{id}, pick a square: "
    init_square = gets.to_s.chomp
    move = valid_square?(init_square, board)

    until move['valid']
      print "#{move['error_msg']}\n"
      print "#{id}, pick a square: "
      init_square = gets.to_s.chomp
      move = valid_square?(init_square, board)
    end
    init_square
  end

  def finish_move(init_square, board)
    print "#{id}, pick a square to move to, or press 'XX' to cancel move: "
    final_square = gets.to_s.chomp
    move = valid_final_square?(final_square, init_square, board)
    until move['valid']
      print "#{move['error_msg']}\n"
      print "#{id}, pick a square to move to, or press 'XX' to cancel move: "
      final_square = gets.to_s.chomp
      move = valid_final_square?(final_square, init_square, board)
    end
    puts 'Canceling move' if final_square == 'XX'
    final_square
  end

  private

  attr_writer :id

  def parse_coord(square)
    coord = square.split('')
    row = coord[1].to_i - 1
    col = coord[0].bytes[0] - 65
    [row, col]
  end

  def valid_id?(square)
    square.length == 2
  end

  def on_board?(square)
    coord = parse_coord(square)
    coord[0].between?(0, 7) && coord[1].between?(0, 7)
  end

  def square_occupied?(square, board)
    coord = parse_coord(square)
    space = board.grid[coord[0]][coord[1]]
    space.nil? ? false : space
  end

  def my_piece?(square, board)
    piece = square_occupied?(square, board)
    piece.id == id
  end

  def valid_square?(square, board)
    return { 'valid' => false, 'error_msg' => 'Enter a valid square' } unless valid_id?(square)

    return { 'valid' => false, 'error_msg' => 'Enter a valid square on the board' } unless on_board?(square)

    empty_sq_msg = 'That square is empty, pick a square with a piece'
    return { 'valid' => false, 'error_msg' => empty_sq_msg } unless square_occupied?(square, board)

    opp_piece_msg = 'That is opponent\'s piece, pick one of yours'
    return { 'valid' => false, 'error_msg' => opp_piece_msg } unless my_piece?(square, board)

    { 'valid' => true, 'error_msg' => '' }
  end

  def get_piece(square, board)
    coord = parse_coord(square)
    board.grid[coord[0]][coord[1]]
  end

  def valid_final_square?(final_square, init_square, board)
    piece = get_piece(init_square, board)

    return { 'valid' => true, 'error_msg' => '' } if final_square == 'XX'

    return { 'valid' => false, 'error_msg' => 'That\'s the current spot, pick a square to move to' } if init_square == final_square

    return { 'valid' => false, 'error_msg' => 'Can not move current piece there, pick another square'} unless piece.possible_moves.include?(final_square)

    { 'valid' => true, 'error_msg' => '' }
  end
end
