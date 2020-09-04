require './lib/player'

grid = Array.new(8) { Array.new(8) {nil} }
grid[1][0] = 'wp1'

describe 'Player - id' do
  let(:player1) { Player.new('player1') }
  it 'can change name/id' do
    expect(player1.id).to eql('player1')
    allow(player1).to receive(:gets).and_return('Bob')
    expect { player1.change_id }.to output('player1, what should I call you now? ').to_stdout
    expect(player1.id).to eql('Bob')
  end
end

describe 'Player - moves - picking initial square' do
  let(:player1) { Player.new('player1') }
  let(:board) { double }
  before(:each) do
    allow(board).to receive(:grid).and_return(grid)
  end
  std_puts = 'player1, pick a square: '

  it 'asks for an initial square' do
    allow(player1).to receive(:gets).and_return('A2')
    expect { player1.start_move(board) }.to output(std_puts).to_stdout
  end
  
  it 'rejects if not a valid square length' do
    allow(player1).to receive(:gets).and_return('Q', 'B15', 'A2')
    string = std_puts
    2.times { string += "Enter a valid square\n#{std_puts}" }
    expect { player1.start_move(board) }.to output(string).to_stdout
  end

  it 'rejects if initial square is not on board' do
    allow(player1).to receive(:gets).and_return('C9', 'A2')
    string = "#{std_puts}Enter a valid square on the board\n#{std_puts}"
    expect { player1.start_move(board) }.to output(string).to_stdout
  end

  it 'rejects if initial square is unoccupied' do
    allow(player1).to receive(:gets).and_return('A1', 'A2')
    string = "#{std_puts}That square is empty, pick a square with a piece\n#{std_puts}"

    expect { player1.start_move(board) }.to output(string).to_stdout
  end

  xit 'rejects if initial square is occupied by opponents piece'
  xit 'prints back the piece picked'
end

describe 'Player - moves - choosing final square to move piece' do
  xit 'asks for a final square to move piece to'
  xit 'can cancel move and start again'
  xit 'rejects if final square is not in piece\'s possible moves'
  xit 'completes a move and return a move combo for updating board/piece state'
end
