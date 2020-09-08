require_relative './board'
require_relative './piece'
require_relative './pawn'
require_relative './knight'
require_relative './bishop'
require_relative './rook'
require_relative './queen'
require_relative './king'

# setting up chessboard
class SetupBoard
  attr_reader :p1_pieces, :p2_pieces, :board
  def initialize(p1_pieces, p2_pieces, board)
    @p1_pieces = p1_pieces
    @p2_pieces = p2_pieces
    @board = board
  end

  def new_game
    setup_pieces(@p1_pieces, 0, 1, @board)
    setup_pieces(@p2_pieces, 7, 6, @board)
  end

  # def in_progress_game; end
  
  private

  def parse_square(coord)
    row = (coord[0] + 1).to_s
    col = (coord[1] + 65).chr
    col + row
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
end
