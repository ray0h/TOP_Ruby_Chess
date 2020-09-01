require './lib/board'

describe Board do
  let(:board) { described_class.new }
  it 'contains a (board) array representing the 64 squares of chessboard' do
    expect(board.grid.length).to eql(8)
    0.upto(7) { |i| expect(board.grid[i].length).to eql(8) }
  end
  xit 'can print out a CLI board based on the array'
  xit 'can add objects to the board array'
  xit 'can remove objects from the board array'
  xit 'can move objects within the board array'
end
