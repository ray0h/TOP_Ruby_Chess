require_relative './piece'

# Queen piece class
class Queen < Piece
  attr_reader :symbol
  def initialize(color, player_id)
    super(color, player_id)
    @symbol = @color == 'white' ? "\u2655" : "\u265B"
    @history = []
  end

  def possible_moves(board)
    current_square = @history.last
    current_coords = parse_coord(current_square)
    queen_moves(current_coords, board)
  end

  private

  def parse_square(coord)
    row = (coord[0] + 1).to_s
    col = (coord[1] + 65).chr
    col + row
  end

  def possible_diagonal(coord, row_coef, col_coef, board)
    inc = 1
    diagonals = []
    loop do
      next_square = parse_square([coord[0] + (inc * row_coef), coord[1] + (inc * col_coef)])
      piece = square_occupied?(next_square, board)

      diagonals.push(next_square) if (piece && !my_piece?(piece)) || (!piece && on_board?(next_square))
      inc += 1
      break if piece || !on_board?(next_square)
    end
    diagonals
  end

  def possible_line(coord, row_coef, col_coef, board)
    inc = 1
    line = []
    loop do
      next_square = parse_square([coord[0] + (inc * row_coef), coord[1] + (inc * col_coef)])
      piece = square_occupied?(next_square, board)

      line.push(next_square) if (piece && !my_piece?(piece)) || (!piece && on_board?(next_square))
      inc += 1
      break if piece || !on_board?(next_square)
    end
    line
  end

  def queen_moves(coord, board)
    n = possible_line(coord, 1, 0, board)
    e = possible_line(coord, 0, 1, board)
    w = possible_line(coord, 0, -1, board)
    s = possible_line(coord, -1, 0, board)

    nw = possible_diagonal(coord, 1, -1, board)
    ne = possible_diagonal(coord, 1, 1, board)
    sw = possible_diagonal(coord, -1, -1, board)
    se = possible_diagonal(coord, -1, 1, board)

    possible_moves = n + e + w + s + nw + ne + sw + se
    possible_moves
  end
end
