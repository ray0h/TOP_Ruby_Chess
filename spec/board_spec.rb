require './lib/board'

# constants
grid = "   _ _ _ _ _ _ _ _\n"
7.downto(0) do |i|
  row = "#{i + 1} |_|_|_|_|_|_|_|_|\n"
  grid += row
end
grid += "   A B C D E F G H\n\n"

describe Board do
  let(:board) { described_class.new }
  it 'contains a (board) array representing the 64 squares of chessboard' do
    expect(board.grid.length).to eql(8)
    0.upto(7) { |i| expect(board.grid[i].length).to eql(8) }
  end

  it 'can print out a CLI board based on the array' do
    expect { board.print_board }.to output(grid).to_stdout
  end

  it 'can add objects to the board array' do
    board.add("\u2659", 'A2')
    expect(board.grid[1][0]).to eql("\u2659")
  end
  xit 'can remove objects from the board array'
  xit 'can move objects within the board array'
end
