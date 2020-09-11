require './lib/pieces/piece'
require './lib/pieces/pawn'
require './lib/pieces/knight'
require './lib/pieces/bishop'
require './lib/pieces/rook'
require './lib/pieces/queen'
require './lib/pieces/king'

# setting up chessboard
module SetupBoard
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
    [p1_pieces, p2_pieces]
  end

  def promote_pawn(p_moves, player_pieces, board)
    pawn = get_piece(p_moves[1], board)
    promoted_piece = promoted_pawn(pawn, board)
    pawn_index = player_pieces.find_index { |piece| piece.history.last == pawn.history.last }
    player_pieces.delete_at(pawn_index)
    player_pieces.push(promoted_piece)
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

  def pick_piece(response, color, player_id)
    if response == 'Knight'
      piece = Knight.new(color, player_id)
    elsif response == 'Bishop'
      piece = Bishop.new(color, player_id)
    elsif response == 'Rook'
      piece = Rook.new(color, player_id)
    elsif response == 'Queen'
      piece = Queen.new(color, player_id)
    end
    piece
  end

  def promoted_piece(pawn, response)
    player_id = pawn.player_id
    color = pawn.color
    response = response.downcase.capitalize
    promoted_piece = pick_piece(response, color, player_id)
    promoted_piece.history.push(pawn.history.last)
    promoted_piece
  end

  def promoted_pawn(pawn, board)
    square = pawn.history.last
    promo_piece = nil
    until promo_piece
      puts 'Pawn promotion, enter the new piece (Knight, Bishop, Rook, Queen): '
      response = STDIN.gets.to_s.chomp
      promo_piece = promoted_piece(pawn, response)
    end
    board.remove_piece(square)
    board.add_piece(promo_piece, square)
    promo_piece
  end
end
