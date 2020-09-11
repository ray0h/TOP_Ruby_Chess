# methods related to assessing board state (e.g. checkmates)
module BoardState
  # opponent's king in check?
  def opp_check?(player_pieces, opponent_pieces, board)
    opp_king_square = opponent_pieces.select { |piece| piece.class == King }[0].history.last
    player_pieces.each do |piece|
      next if piece.class == King
      return true if piece.possible_moves(board).include?(opp_king_square)
    end
    false
  end

  def fast_forward_move(p_moves, opp_pieces, board)
    my_piece = get_piece(p_moves[0], board)
    my_piece.history.push(p_moves[1]) if my_piece.class == King
    capture_piece(p_moves, opp_pieces, board)
    board.move_piece(p_moves[0], p_moves[1])
  end

  def rewind_move(p_moves, board)
    board.move_piece(p_moves[1], p_moves[0])
    opp_piece = get_piece(p_moves[1], board)
    board.add_piece(opp_piece, p_moves[1]) if opp_piece
    opp_pieces.push(opp_piece) if opp_piece
    my_piece = get_piece(p_moves[0], board)
    my_piece.history.pop if my_piece.class == King
  end

  def still_in_check?(p_moves, player_pieces, opp_pieces, board)
    fast_forward_move(p_moves, opp_pieces, board)
    # check if move eliminates check
    still_in_check = opp_check?(opp_pieces, player_pieces, board)
    rewind_move(p_moves, board)

    still_in_check
  end

  # array id'ing piece(s) that place king in check
  def checking_pieces(my_pieces, opponent_pieces, board)
    opp_king_square = opponent_pieces.select { |piece| piece.class == King }[0].history.last
    checking_pieces = my_pieces.select { |piece| piece.possible_moves(board).include?(opp_king_square) }
    checking_pieces
  end

  # verify if opponent pieces can capture piece placing their king in check
  def remove_checker?(my_pieces, opponent_pieces, board)
    checker = checking_pieces(my_pieces, opponent_pieces, board)
    return false unless checker.length == 1

    checker_square = checker[0].history.last
    checker_removers = opponent_pieces.select { |piece| piece.possible_moves(board).include?(checker_square) }
    checker_removers.length.positive?
  end

  def horiz_btwn_squares(king_coords, checker_coords)
    squares = []
    if king_coords[1] > checker_coords[1]
      min = checker_coords[1] + 1
      max = king_coords[1] - 1
    else
      min = king_coords[1] + 1
      max = checker_coords[1] - 1
    end
    min.upto(max) { |i| squares.push(parse_square([king_coords[0], i])) }
    squares
  end

  def vert_btwn_squares(king_coords, checker_coords)
    squares = []
    if king_coords[0] > checker_coords[0]
      min = checker_coords[0] + 1
      max = king_coords[0] - 1
    else
      min = king_coords[0] + 1
      max = checker_coords[0] - 1
    end
    min.upto(max) { |i| squares.push(parse_square([i, king_coords[1]])) }
    squares
  end

  def diag_offsets(king_coords, checker_coords)
    row = king_coords[0] > checker_coords[0] ? -1 : 1
    col = king_coords[1] > checker_coords[1] ? -1 : 1
    iter = (king_coords[0] - checker_coords[0]).abs - 1
    [row, col, iter]
  end

  def diag_btwn_squares(king_coords, checker_coords)
    squares = []
    row, col, iter = diag_offsets(king_coords, checker_coords)
    1.upto(iter) do |i|
      squares.push(parse_square([king_coords[0] + (row * i), king_coords[1] + (col * i)]))
    end
    squares
  end

  def get_btwn_squares(opp_king_square, checker_square)
    king_coords = parse_coord(opp_king_square)
    checker_coords = parse_coord(checker_square)
    btwn_squares = if king_coords[0] == checker_coords[0] # horiz line
                     horiz_btwn_squares(king_coords, checker_coords)
                   elsif king_coords[1] == checker_coords[1] # vert line
                     vert_btwn_squares(king_coords, checker_coords)
                   else # diagonal line
                     diag_btwn_squares(king_coords, checker_coords)
                   end
    btwn_squares
  end

  def get_blockers(opp_pieces, checker, board)
    opp_king_square = opp_pieces.select { |piece| piece.class == King }[0].history.last
    checker_square = checker[0].history.last
    # get squares btwn king and attacking piece
    btwn_squares = get_btwn_squares(opp_king_square, checker_square)

    # if btwn_squares, for each square, see if an opponents piece can move here
    blockers = btwn_squares&.map { |square| opp_pieces.select { |piece| piece.possible_moves(board).include?(square) } }

    blockers ? blockers.flatten : []
  end

  # verify if opponent pieces can block piece placing their king in check
  def block_checker?(my_pieces, opp_pieces, board)
    checker = checking_pieces(my_pieces, opp_pieces, board)
    mult_lines = [Rook, Bishop, Queen].include?(checker.class)
    return false unless checker.length == 1 || mult_lines

    blockers = get_blockers(opp_pieces, checker, board)
    blockers.length.positive?
  end
end
