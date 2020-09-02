require_relative 'piece'

# pawn piece class
class Pawn < Piece
  attr_reader :symbol
  def initialize(color, player_id)
    super(color, player_id)
    @symbol = @color == 'white' ? "\u2659" : "\u265F"
  end

  # black pawns move 'N' to 'S', white pawns move 'S' to 'N'
  def possible_moves(board)
    poss_move_array = []
    current_square = @history.last
    current_coords = parse_coord(current_square)

    poss_move_array.push(single_march(current_coords, board)) if single_march(current_coords, board)
    poss_move_array.push(double_march(current_coords, board)) if first_move? && double_march(current_coords, board)
    valid_diagonals(current_coords, board).each { |move| poss_move_array.push(move) }

    poss_move_array
  end

  private

  # translate 'A2' type move from [row][col] coords
  def parse_move(coords)
    row = coords[0] + 1
    col = (coords[1] + 65).chr
    col + row.to_s
  end

  def single_march(coords, board)
    march = @color == 'white' ? [coords[0] + 1, coords[1]] : [coords[0] - 1, coords[1]]
    sngl_march = parse_move(march)
    !square_occupied?(sngl_march, board) && on_board?(sngl_march) ? sngl_march : false
  end

  def double_march(coords, board)
    march = @color == 'white' ? [coords[0] + 2, coords[1]] : [coords[0] - 2, coords[1]]
    dbl_march = parse_move(march)
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
    diag1 = parse_move(get_diagonals(coords)[0])
    diag2 = parse_move(get_diagonals(coords)[1])
    piece1 = square_occupied?(diag1, board)
    piece2 = square_occupied?(diag2, board)
    valid_diagonals = []
    valid_diagonals.push(diag1) if piece1 && !my_piece?(piece1)
    valid_diagonals.push(diag2) if piece2 && !my_piece?(piece2)
    valid_diagonals
  end
end
