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
    poss_moves = king_moves(current_coords, board)

    opp_moves = opponent_poss_moves(board)
    poss_moves.filter { |move| !opp_moves.include?(move) }
  end

  private

  def parse_square(coord)
    row = (coord[0] + 1).to_s
    col = (coord[1] + 65).chr
    col + row
  end

  def diagonal(coord, row_coef, col_coef, board)
    next_square = parse_square([coord[0] + (1 * row_coef), coord[1] + (1 * col_coef)])
    piece = square_occupied?(next_square, board)

    (piece && !my_piece?(piece)) || (!piece && on_board?(next_square)) ? [next_square] : []
  end

  def line(coord, row_coef, col_coef, board)
    next_square = parse_square([coord[0] + (1 * row_coef), coord[1] + (1 * col_coef)])
    piece = square_occupied?(next_square, board)

    (piece && !my_piece?(piece)) || (!piece && on_board?(next_square)) ? [next_square] : []
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

  def get_opponent_pieces(board)
    opp_pieces = []
    0.upto(7) do |i|
      0.upto(7) do |j|
        opp_pieces.push(board.grid[i][j]) if !board.grid[i][j].nil? && !my_piece?(board.grid[i][j])
      end
    end
    opp_pieces
  end

  def opponent_poss_moves(board)
    poss_moves = []
    opp_pieces = get_opponent_pieces(board)
    opp_pieces.each { |piece| poss_moves += piece.possible_moves }
    poss_moves.uniq
  end
end
