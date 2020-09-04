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
end

class Board 
  attr_reader :grid
  def initialize
    @grid = Array.new(8) {Array.new(8) {nil}}
  end
end

# board = Board.new
# board.grid[1][0] = 'wp1'

# player = Player.new('player1')
# p player.start_move(board)
