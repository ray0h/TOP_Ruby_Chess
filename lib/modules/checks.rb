# methods related to assessing check state of king

module Checks
  # opponent's king in check?
  def opp_check?(my_pieces, opponent_pieces, board)
    opp_king_square = opponent_pieces.select { |piece| piece.class == King }[0].history.last
    my_pieces.each do |piece|
      next if piece.class == King
      return true if piece.possible_moves(board).include?(opp_king_square)
    end
    false
  end

  # remove piece from player_piece array (assumes piece is opponents)
  def capture_piece(p_moves, opp_pieces, board)
    # check if opponent piece is in the square
    opp_piece = get_piece(p_moves[1], board)
    # capture and remove piece
    opp_index = opp_pieces.find_index { |piece| piece.history.last == opp_piece.history.last } if opp_piece
    opp_pieces.delete_at(opp_index) if opp_piece
  end

  def fast_forward_move(p_moves, opponent_pieces, board)
    my_piece = get_piece(p_moves[0], board)
    opponent_piece = get_piece(p_moves[1], board)
    capture_piece(p_moves, opponent_pieces, board) if opponent_piece && my_piece.color != opponent_piece.color
    my_piece.history.push(p_moves[1]) if my_piece.class == King
    board.move_piece(p_moves[0], p_moves[1])
    opponent_piece
  end

  def rewind_move(p_moves, opponent_piece, opponent_pieces, board)
    board.move_piece(p_moves[1], p_moves[0])
    board.add_piece(opponent_piece, p_moves[1]) if opponent_piece
    opponent_pieces.push(opponent_piece) if opponent_piece
    my_piece = get_piece(p_moves[0], board)
    my_piece.history.pop if my_piece.class == King
  end

  # eval if player's king remains in check after potential move
  def still_in_check?(p_moves, my_pieces, opponent_pieces, board)
    opponent_piece = fast_forward_move(p_moves, opponent_pieces, board)
    # check if move eliminates check
    still_in_check = opp_check?(opponent_pieces, my_pieces, board)
    rewind_move(p_moves, opponent_piece, opponent_pieces, board)
    still_in_check
  end
end
