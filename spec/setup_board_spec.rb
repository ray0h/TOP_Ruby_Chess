require './lib/setup_board'

grid = Array.new(8) { Array.new(8) {nil} }
p1_pieces = []
p2_pieces = []
16.times do
  p1_pieces.push('white_piece')
  p2_pieces.push('black_piece')
end

describe SetupBoard do
  let(:board) { double('Board', grid: grid) }
  let(:white_piece) { double('Piece', color: 'white', history: [])}
  let(:black_piece) { double('Piece', color: 'black', history: []) }
  let(:setup) { SetupBoard.new(p1_pieces, p2_pieces, board) }

  before(:each) do
    p1_pieces = []
    p2_pieces = []
    16.times do
      p1_pieces.push(white_piece)
      p2_pieces.push(black_piece)
    end
  end

  it 'has method to set up a new/fresh chessboard' do
    setup.new_game
    expect(setup.board.grid[7].none?(nil)).to be_truthy
    expect(setup.board.grid[6].none?(nil)).to be_truthy
    expect(setup.board.grid[1].none?(nil)).to be_truthy
    expect(setup.board.grid[0].none?(nil)).to be_truthy
    expect(setup.board.grid[7][4].color).to eql('black')
    expect(setup.board.grid[0][4].color).to eql('white')
  end
  
  xit 'sets up a custom board'
end
