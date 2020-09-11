# methods related to moving pieces around chess board
module Moves

  private 
  
  # prompt for start/final squares for move
  def get_moves(player, board)
    p_moves = 'X'
    while p_moves == 'X'
      init_move = player.start_move(board)
      p_moves = player.finish_move(init_move, board)
      puts 'Canceling move' if p_moves == 'X'
    end
    p_moves
  end

  def update_move_history(p_moves, board)
    my_piece = get_piece(p_moves[0], board)
    my_piece.history.push(p_moves[1])
  end

  # remove piece from player_piece array
  def capture_piece(p_moves, opp_pieces, board)
    # check if opponent piece is in the square
    opp_piece = square_occupied?(p_moves[1], board)
    # capture and remove piece
    opp_index = opp_pieces.find_index { |piece| piece.history.last == opp_piece.history.last } if opp_piece
    opp_pieces.delete_at(opp_index) if opp_piece
  end

  def execute_move(p_moves, player_pieces, opp_pieces, board)
    update_move_history(p_moves, board)
    capture_piece(p_moves, opp_pieces, board) # if opponent piece is in the square
    castle_rook(p_moves, board) if start_castling?(p_moves, board) # castling
    board.move_piece(p_moves[0], p_moves[1])
    promote_pawn(p_moves, player_pieces, board) if pawn_end?(p_moves, board)
    board.print_board
  end

  def validate_moves(player, player_pieces, opp_pieces, board)
    p_moves = ''
    loop do
      p_moves = get_moves(player, board)
      return p_moves if %w[Q S].include?(p_moves)

      break unless still_in_check?(p_moves, player_pieces, opp_pieces, board)

      puts 'King is still in check, please make another move'
    end
    p_moves
  end

  # king moves to start castling?
  def start_castling?(p_moves, board)
    piece = get_piece(p_moves[0], board)
    squares_moved = parse_coord(p_moves[1])[1] - parse_coord(p_moves[0])[1]
    (piece.class == King) && (squares_moved.abs > 1)
  end

  # get moves for rook to finish castling
  def rook_castle_moves(final_king_coords, col, offset)
    rook_start = parse_square([final_king_coords[0], col])
    rook_finish = parse_square([final_king_coords[0], final_king_coords[1] + offset])
    [rook_start, rook_finish]
  end

  # execute moves to complete castling
  def castle_rook(p_moves, board)
    squares_moved = parse_coord(p_moves[1])[1] - parse_coord(p_moves[0])[1]
    final_king_coords = parse_coord(p_moves[1])
    col, offset = squares_moved.positive? ? [7, -1] : [0, 1]
    rook_castle_moves = rook_castle_moves(final_king_coords, col, offset)

    update_move_history(rook_castle_moves, board)
    board.move_piece(rook_castle_moves[0], rook_castle_moves[1])
  end

  # toggle ep_flag in en passant scenarios
  def toggle_enpassant(last_move, board)
    return if last_move.length.zero?

    last_piece = get_piece(last_move[1], board)
    return unless last_piece.class == Pawn

    coords = parse_coord(last_move[1])
    last_piece.ep_flag = !last_piece.ep_flag if last_piece.history.length == 2 && [3, 4].include?(coords[0])
  end

  # pawn reached end of board?
  def pawn_end?(p_moves, board)
    piece = get_piece(p_moves[1], board)
    final_coords = parse_coord(p_moves[1])
    piece.class == Pawn && final_coords[0] == 7
  end

  def promote_pawn(p_moves, player_pieces, board)
    pawn = get_piece(p_moves[1], board)
    promoted_piece = @setup_board.promoted_pawn(pawn, board)
    pawn_index = player_pieces.find_index { |piece| piece.history.last == pawn.history.last }
    player_pieces.delete_at(pawn_index)
    player_pieces.push(promoted_piece)
  end
end
