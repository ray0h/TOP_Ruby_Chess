require_relative 'piece'

# pawn piece class
class Pawn < Piece
  attr_reader :symbol
  attr_accessor :ep_flag
  def initialize(color, player_id)
    super(color, player_id)
    @symbol = @color == 'white' ? "\u2659" : "\u265F"
    @ep_flag = false
  end

  # black pawns move 'N' to 'S', white pawns move 'S' to 'N'
  def possible_moves(board)
    poss_move_array = []
    current_square = @history.last
    current_coords = parse_coord(current_square)

    poss_move_array.push(single_march(current_coords, board)) if single_march(current_coords, board)

    poss_move_array.push(double_march(current_coords, board)) if first_move? && double_march(current_coords, board)

    valid_diagonals(current_coords, board).each { |move| poss_move_array.push(move) }

    poss_move_array.push(en_passant?(current_coords, board)) if en_passant?(current_coords, board)

    poss_move_array
  end

  private

  def single_march(coords, board)
    march = @color == 'white' ? [coords[0] + 1, coords[1]] : [coords[0] - 1, coords[1]]
    sngl_march = parse_square(march)
    !square_occupied?(sngl_march, board) && on_board?(sngl_march) ? sngl_march : false
  end

  def double_march(coords, board)
    march = @color == 'white' ? [coords[0] + 2, coords[1]] : [coords[0] - 2, coords[1]]
    dbl_march = parse_square(march)

    single_march(coords, board) && !square_occupied?(dbl_march, board) ? dbl_march : false
  end

  def get_diagonals(coords)
    if @color == 'white'
      diag1 = [coords[0] + 1, coords[1] - 1]
      diag2 = [coords[0] + 1, coords[1] + 1]
    else # 'black'
      diag1 = [coords[0] - 1, coords[1] - 1]
      diag2 = [coords[0] - 1, coords[1] + 1]
    end
    [diag1, diag2]
  end

  def valid_diagonals(coords, board)
    diag1 = parse_square(get_diagonals(coords)[0])
    diag2 = parse_square(get_diagonals(coords)[1])
    piece1 = square_occupied?(diag1, board)
    piece2 = square_occupied?(diag2, board)
    valid_diagonals = []
    valid_diagonals.push(diag1) if piece1 && !my_piece?(piece1)
    valid_diagonals.push(diag2) if piece2 && !my_piece?(piece2)
    valid_diagonals
  end

  def check_side_squares(piece)
    possible = false
    offset = @color == 'white' ? 1 : -1
    if piece.ep_flag && piece.class.name == 'Pawn'
      square = piece.history.last
      coord = parse_coord(square)
      possible = parse_square([coord[0] + offset, coord[1]])
    end
    possible
  end

  def en_passant?(coords, board)
    row = @color == 'white' ? 4 : 3
    possible = false
    return false unless coords[0] == row

    poss_piece1 = square_occupied?(parse_square([coords[0], coords[1] + 1]), board)
    poss_piece2 = square_occupied?(parse_square([coords[0], coords[1] - 1]), board)

    possible = check_side_squares(poss_piece1) if poss_piece1
    possible = check_side_squares(poss_piece2) if poss_piece2
    possible
  end
end
