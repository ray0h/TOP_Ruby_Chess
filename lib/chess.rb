require_relative './gameplay'

# main file to execute ruby chess game
chess_game = Gameplay.new
chess_game.setup_board
chess_game.play
