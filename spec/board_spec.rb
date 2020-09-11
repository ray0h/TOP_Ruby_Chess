require './lib/board'

# constants
grid = "   _ _ _ _ _ _ _ _\n"
7.downto(0) do |i|
  row = "#{i + 1} |_|_|_|_|_|_|_|_|\n"
  grid += row
end
grid += "   A B C D E F G H\nEnter 'Q'/'S' anytime to (Q)uit/(S)ave game\n\n"
board_array = Array.new(8) { Array.new(8) { nil }}

describe Board do
  let(:board) { described_class.new }
  it 'contains a (board) array representing the 64 squares of chessboard' do
    expect(board.grid.length).to eql(8)
    0.upto(7) { |i| expect(board.grid[i].length).to eql(8) }
  end

  it 'can print out a CLI board based on the array' do
    expect { board.print_board(board_array) }.to output(grid).to_stdout
  end

  it 'can add objects to the board array' do
    board.add_piece("\u2659", 'A2')
    expect(board.grid[1][0]).to eql("\u2659")
  end

  it 'can remove objects from the board array' do
    board.add_piece("\u2659", 'B2')
    expect(board.grid[1][1]).to eql("\u2659")
    board.remove_piece('B2')
    expect(board.grid[1][1]).to be_nil
  end

  it 'can move objects within the board array' do
    board.add_piece("\u2659", 'B2')
    board.move_piece('B2', 'B4')
    expect(board.grid[3][1]).to eql("\u2659")
  end
end
