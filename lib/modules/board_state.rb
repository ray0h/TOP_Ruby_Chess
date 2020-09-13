# methods related to assessing board state (e.g. checkmates)
module BoardState
  # opponent's king in check?
  def opp_check?(my_pieces, opponent_pieces, board)
    opp_king_square = opponent_pieces.select { |piece| piece.class == King }[0].history.last
    my_pieces.each do |piece|
      next if piece.class == King
      return true if piece.possible_moves(board).include?(opp_king_square)
    end
    false
  end

  def fast_forward_move(p_moves, opponent_pieces, board)
    my_piece = get_piece(p_moves[0], board)
    my_piece.history.push(p_moves[1]) if my_piece.class == King
    capture_piece(p_moves, opponent_pieces, board)
    board.move_piece(p_moves[0], p_moves[1])
  end

  def rewind_move(p_moves, board)
    board.move_piece(p_moves[1], p_moves[0])
    opponent_piece = get_piece(p_moves[1], board)
    board.add_piece(opp_piece, p_moves[1]) if opponent_piece
    opponent_pieces.push(opponent_piece) if opponent_piece
    my_piece = get_piece(p_moves[0], board)
    my_piece.history.pop if my_piece.class == King
  end

  def still_in_check?(p_moves, my_pieces, opponent_pieces, board)
    fast_forward_move(p_moves, opponent_pieces, board)
    # check if move eliminates check
    still_in_check = opp_check?(opponent_pieces, my_pieces, board)
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

  # get pieces that could potentially block checking piece
  def get_blockers(opponent_pieces, checker, board)
    opp_king_square = opponent_pieces.select { |piece| piece.class == King }[0].history.last
    checker_square = checker[0].history.last
    # get squares btwn king and attacking piece
    btwn_squares = get_btwn_squares(opp_king_square, checker_square)

    # if btwn_squares, for each square, see if an opponents piece can move here
    blockers = btwn_squares&.map { |square| opponent_pieces.select { |piece| piece.possible_moves(board).include?(square) } }

    blockers ? blockers.flatten : []
  end

  # verify if opponent pieces can block piece placing their king in check
  def block_checker?(my_pieces, opponent_pieces, board)
    checker = checking_pieces(my_pieces, opponent_pieces, board)
    mult_lines = [Rook, Bishop, Queen].include?(checker.class)
    return false unless checker.length == 1 || mult_lines

    blockers = get_blockers(opponent_pieces, checker, board)
    blockers.length.positive?
  end

  def stop_checker?(my_pieces, opponent_pieces, board)
    checkers = checking_pieces(my_pieces, opponent_pieces, board)
    checker_blocker = block_checker?(my_pieces, opponent_pieces, board)
    checker_remover = remove_checker?(my_pieces, opponent_pieces, board)
    checkers.length > 1 || (!checker_blocker && !checker_remover)
  end

  # opp king in check, no possible way to escape check
  def checkmate?(opponent_pieces, my_pieces, board)
    in_check = opp_check?(my_pieces, opponent_pieces, board)
    opp_king = opponent_pieces.select { |piece| piece.class == King }[0]
    no_king_moves = opp_king.possible_moves(board).length.zero?
    checkmate = no_king_moves && in_check && stop_checker?(my_pieces, opponent_pieces, board)
    puts 'Checkmate!, Game over' if checkmate
    checkmate
  end

  # king not in check, no possible moves
  def stalemate?(my_pieces, opponent_pieces, board)
    in_check = opp_check?(my_pieces, opponent_pieces, board)

    opp_moves = opponent_pieces.map { |piece| piece.possible_moves(board).length }
    stalemate = opp_moves.all?(&:zero?) && !in_check
    puts 'Stalemate, Game over' if stalemate
    stalemate
  end
end
