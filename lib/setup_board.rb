require_relative './piece'
require_relative './pawn'
require_relative './knight'
require_relative './bishop'
require_relative './rook'
require_relative './queen'
require_relative './king'

# setting up chessboard
class SetupBoard
  def new_game(player1, player2, board)
    p1_pieces = create_new_pieces(player1.id, 'white')
    p2_pieces = create_new_pieces(player2.id, 'black')

    setup_pieces(p1_pieces, 0, 1, board)
    setup_pieces(p2_pieces, 7, 6, board)
    [p1_pieces, p2_pieces]
  end

  def in_progress_game(p1_pieces, p2_pieces, board)
    p1_pieces.each do |piece|
      square = piece.history.last
      board.add_piece(piece, square)
    end
    p2_pieces.each do |piece|
      square = piece.history.last
      board.add_piece(piece, square)
    end
  end

  private

  def parse_coord(square)
    square = square.split('')
    row = square[1].to_i - 1
    col = square[0].bytes[0] - 65
    [row, col]
  end

  def parse_square(coord)
    row = (coord[0] + 1).to_s
    col = (coord[1] + 65).chr
    col + row
  end

  def create_new_pieces(player_id, color)
    backrow = [Rook.new(color, player_id), Knight.new(color, player_id), Bishop.new(color, player_id)]
    backrow.push(Queen.new(color, player_id))
    backrow.push(King.new(color, player_id))
    backrow += [Bishop.new(color, player_id), Knight.new(color, player_id), Rook.new(color, player_id)]
    frontrow = []
    8.times { frontrow.push(Pawn.new(color, player_id)) }

    backrow + frontrow
  end

  def setup_pieces(pieces, back_row, front_row, board)
    0.upto(7) do |col|
      pawns = col + 8
      back_square = parse_square([back_row, col])
      front_square = parse_square([front_row, col])
      board.add_piece(pieces[col], back_square)
      pieces[col].history.push(back_square)
      board.add_piece(pieces[pawns], front_square)
      pieces[pawns].history.push(front_square)
    end
  end
end
