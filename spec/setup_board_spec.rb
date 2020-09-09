require './lib/setup_board'
require './lib/board'
# grid = Array.new(8) { Array.new(8) { nil } }
# p1_pieces = []
# p2_pieces = []
# 16.times do
#   p1_pieces.push('white_piece')
#   p2_pieces.push('black_piece')
# end

describe SetupBoard do
  let(:player1) { double('Player', id: 'player1', history: [])}
  let(:player2) { double('Player', id: 'player2', history: []) }
  let(:board) { Board.new }
  let(:setup) { SetupBoard.new }

 

  it 'has method to set up a new/fresh chessboard' do
    # p1_pieces = []
    # p2_pieces = []
    # 16.times do
    #   p1_pieces.push(white_piece)
    #   p2_pieces.push(black_piece)
    # end
    setup.new_game(player1, player2, board)
    expect(board.grid[7].none?(nil)).to be_truthy
    expect(board.grid[6].none?(nil)).to be_truthy
    expect(board.grid[1].none?(nil)).to be_truthy
    expect(board.grid[0].none?(nil)).to be_truthy
    expect(board.grid[7][4].color).to eql('black')
    expect(board.grid[0][4].color).to eql('white')
  end
  
  xit 'sets up a custom board' do
    
  end
end
