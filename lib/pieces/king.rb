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
    poss_moves = king_moves(current_coords, board) + castle_moves(board)

    # king can not move to spot where he would be placed in check
    opp_moves = opponent_poss_moves(board)
    poss_moves.filter { |move| !opp_moves.include?(move) }
  end

  private

  # functions related to normal king moves
  def one_space_move(coord, row_coef, col_coef, board)
    next_square = parse_square([coord[0] + (1 * row_coef), coord[1] + (1 * col_coef)])
    piece = square_occupied?(next_square, board)

    (piece && !my_piece?(piece)) || (!piece && on_board?(next_square)) ? [next_square] : []
  end

  def king_moves(coords, board)
    surrounding = [[1, 1], [1, -1], [-1, 1], [-1, -1], [1, 0], [-1, 0], [0, 1], [0, -1]]
    poss_moves = []

    surrounding.each { |pair| poss_moves += one_space_move(coords, pair[0], pair[1], board) }
    poss_moves
  end

  # functions related to prevent king moving into check space
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
    opp_pieces.each do |piece|
      coords = parse_coord(piece.history.last)
      moves = piece.class.name == 'King' ? king_moves(coords, board) : piece.possible_moves(board)
      poss_moves += moves
    end
    poss_moves.uniq
  end

  # functions related to castling
  def between_rook_king(king_coord, rook_coord)
    squares = []
    row = king_coord[0]
    min = (rook_coord[1] == 7 ? king_coord[1] : rook_coord[1]) + 1
    max = (rook_coord[1] == 7 ? rook_coord[1] : king_coord[1]) - 1
    min.upto(max) { |col| squares.push(parse_square([row, col])) }
    squares
  end

  def get_between_squares(rook)
    king_coord = parse_coord(@history.last)
    rook_coord = parse_coord(rook.history.last)

    between_squares = between_rook_king(king_coord, rook_coord)
    between_squares
  end

  def between_squares_empty?(rook, board)
    btwn_squares = get_between_squares(rook)

    status = btwn_squares.map { |square| square_occupied?(square, board) }
    status.all? { |square| square == false }
  end

  def no_check_between_squares?(rook, board)
    opp_moves = opponent_poss_moves(board)
    btwn_squares = get_between_squares(rook)
    status = btwn_squares.map { |square| opp_moves.include?(square) }
    status.all? { |square| square == false }
  end

  def can_castle?(rook, board)
    false if first_move?
    false if rook.first_move?
    false unless between_squares_empty?(rook, board)
    false unless no_check_between_squares?(rook, board)
    true
  end

  def get_rooks(board)
    rooks = []
    0.upto(7) do |i|
      0.upto(7) do |j|
        space = board.grid[i][j]
        rooks.push(space) if !space.nil? && my_piece?(space) && space.class.name == 'Rook'
      end
    end
    rooks
  end

  def castle_moves(board)
    rooks = get_rooks(board)
    castle_moves = []

    rooks.each do |rook|
      king_coord = parse_coord(@history.last)
      rook_coord = parse_coord(rook.history.last)
      row = king_coord[0]
      col = rook_coord[1] == 7 ? 6 : 2
      castle_moves.push(parse_square([row, col])) if can_castle?(rook, board)
    end
    castle_moves
  end
end
