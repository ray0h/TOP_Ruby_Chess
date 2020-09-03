require_relative './piece'

# King piece class
class King < Piece
  attr_reader :symbol
  def initialize(color, player_id)
    super(color, player_id)
    @symbol = @color == 'white' ? "\u2654" : "\u265A"
    @history = []
  end

  def possible_moves(board)
    current_square = @history.last
    current_coords = parse_coord(current_square)
    king_moves(current_coords, board)
  end

  private

  def parse_square(coord)
    row = (coord[0] + 1).to_s
    col = (coord[1] + 65).chr
    col + row
  end

  def diagonal(coord, row_coef, col_coef, board)
    next_square = parse_square([coord[0] + (1 * row_coef), coord[1] + (1 * col_coef)])

    on_board?(next_square) ? [next_square] : []
  end

  def line(coord, row_coef, col_coef, board)
    next_square = parse_square([coord[0] + (1 * row_coef), coord[1] + (1 * col_coef)])

    on_board?(next_square) ? [next_square] : []
  end

  def king_moves(coords, board)
    corners = [[1, 1], [1, -1], [-1, 1], [-1, -1]]
    lines = [[1, 0], [-1, 0], [0, 1], [0, -1]]
    poss_moves = []

    lines.each do |pair|
      poss_moves += line(coords, pair[0], pair[1], board)
    end
    corners.each do |pair|
      poss_moves += diagonal(coords, pair[0], pair[1], board)
    end
    poss_moves
  end
end
