# require_relative './pawn'

# wp1 = Pawn.new('white', 'player1')
# puts wp1.instance_variables
# puts wp1.symbol
# puts wp1.class.name

require_relative './player'
require_relative './board'
board = Board.new
board.grid[1][0] = 'pawn'
player1 = Player.new('player1')
player1.start_move(board)