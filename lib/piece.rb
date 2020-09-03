# Generic Chess Piece Class
class Piece
  attr_accessor :color, :player_id, :history, :opponent
  def initialize(color, player_id)
    @color = color
    @player_id = player_id
    @history = []
    @opponent = @color == 'white' ? 'black ' : 'white'
  end

  private

  # methods to help define general movement logic

  # translate [row][col] coords from 'A2' move
  def parse_coord(square)
    square = square.split('')
    row = square[1].to_i - 1
    col = square[0].bytes[0] - 65
    [row, col]
  end

  def first_move?
    @history.length < 2
  end

  def on_board?(square)
    coord = parse_coord(square)
    coord[0].between?(0, 7) && coord[1].between?(0, 7)
  end

  def square_occupied?(square, board)
    return false unless on_board?(square)

    coord = parse_coord(square)
    space = board.grid[coord[0]][coord[1]]
    space.nil? ? false : space
  end

  def my_piece?(piece)
    piece.color == @color
  end
end
