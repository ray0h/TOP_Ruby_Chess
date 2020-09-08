# require_relative './pawn'

# wp1 = Pawn.new('white', 'player1')
# puts wp1.instance_variables
# puts wp1.symbol
# puts wp1.class.name

require_relative './gameplay'
game = Gameplay.new
game.play