require './lib/setup_board'
require './lib/board'

describe SetupBoard do
  let(:player1) { double('Player', id: 'player1', history: [])}
  let(:player2) { double('Player', id: 'player2', history: []) }
  let(:board) { Board.new }
  let(:setup) { SetupBoard.new }

  it 'has method to set up a new/fresh chessboard' do
    setup.new_game(player1, player2, board)
    expect(board.grid[7].none?(nil)).to be_truthy
    expect(board.grid[6].none?(nil)).to be_truthy
    expect(board.grid[1].none?(nil)).to be_truthy
    expect(board.grid[0].none?(nil)).to be_truthy
    expect(board.grid[7][4].color).to eql('black')
    expect(board.grid[0][4].color).to eql('white')
  end

  let(:wkg) { double('King', color: 'white', history: ['E1']) }
  let(:wp1) { double('Pawn', color: 'white', history: ['A2']) }
  let(:bkg) { double('King', color: 'black', history: ['H5']) }
  let(:bqn) { double('Queen', color: 'black', history: ['A8']) }
  it 'sets up a custom board' do
    p1_pieces = [wkg, wp1]
    p2_pieces = [bqn, bkg]
    setup.in_progress_game(p1_pieces, p2_pieces, board)
    expect(board.grid[1][1]).to be_nil
    expect(board.grid[1][0]).to be_truthy
    expect(board.grid[0][4]).to be_truthy
    expect(board.grid[7][0]).to be_truthy
    expect(board.grid[4][7]).to be_truthy
    expect(board.grid[4][7].color).to eql('black')
  end
end
