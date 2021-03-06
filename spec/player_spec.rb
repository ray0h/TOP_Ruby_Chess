require './lib/player'

grid = Array.new(8) { Array.new(8) { nil } }

# prevents methods that puts / print text from doing so when testing for returns
# `yield` allows code wrapped in method to run
def silence_output
  orig_stdout = $stdout
  $stdout = StringIO.new
  yield
  $stdout = orig_stdout
end

describe 'Player - id' do
  let(:player1) { Player.new('player1') }
  it 'can change name/id' do
    expect(player1.id).to eql('player1')
    allow(STDIN).to receive(:gets).and_return('Bob')
    expect { player1.change_id }.to output('player1, what should I call you now? ').to_stdout
    expect(player1.id).to eql('Bob')
  end
end

describe 'Player - moves - picking initial square' do
  let(:player1) { Player.new('player1') }
  let(:board) { double }
  let(:wp1) { double }
  let(:bp1) { double }

  before(:each) do
    grid[1][0] = wp1
    grid[6][0] = bp1
    allow(board).to receive(:grid).and_return(grid)
    allow(wp1).to receive(:player_id).and_return('player1')
    allow(bp1).to receive(:player_id).and_return('player2')
  end
  std_puts = 'player1, pick a square: '

  it 'asks for an initial square' do
    allow(STDIN).to receive(:gets).and_return('A2')
    expect { player1.start_move(board) }.to output(std_puts).to_stdout
  end

  it 'rejects if not a valid square length (or not equal to X or Q)' do
    allow(STDIN).to receive(:gets).and_return('Z', 'B15', 'A2')
    string = std_puts
    2.times { string += "Enter a valid square\n#{std_puts}" }
    expect { player1.start_move(board) }.to output(string).to_stdout
  end

  it 'rejects if initial square is not on board' do
    allow(STDIN).to receive(:gets).and_return('C9', 'A2')
    string = "#{std_puts}Enter a valid square on the board\n#{std_puts}"
    expect { player1.start_move(board) }.to output(string).to_stdout
  end

  it 'rejects if initial square is unoccupied' do
    allow(STDIN).to receive(:gets).and_return('A1', 'A2')
    string = "#{std_puts}That square is empty, pick a square with a piece\n#{std_puts}"

    expect { player1.start_move(board) }.to output(string).to_stdout
  end

  it 'rejects if initial square is occupied by opponents piece' do
    allow(STDIN).to receive(:gets).and_return('A7', 'A2')
    string = "#{std_puts}That is opponent's piece, pick one of yours\n#{std_puts}"

    expect { player1.start_move(board) }.to output(string).to_stdout
  end

  it 'returns the starting square' do
    silence_output do
      allow(STDIN).to receive(:gets).and_return('A2')
      expect(player1.start_move(board)).to eql('A2')
    end
  end
end

describe 'Player - moves - choosing final square to move piece' do
  let(:player1) { Player.new('player1') }
  let(:board) { double }
  let(:wp1) { double }

  before(:each) do
    grid[1][0] = wp1
    allow(board).to receive(:grid).and_return(grid)
    allow(wp1).to receive(:possible_moves).and_return(%w[A3 A4])
  end
  std_puts = "player1, pick a square to move to, or press 'X' to cancel move: "

  it 'asks for a final square to move piece to' do
    allow(STDIN).to receive(:gets).and_return('A3')
    expect { player1.finish_move('A2', board) }.to output(std_puts).to_stdout
  end

  it 'asks again if current square is entered' do
    allow(STDIN).to receive(:gets).and_return('A2', 'A3')
    string = std_puts + "That's the current spot, pick a square to move to\n" + std_puts
    expect { player1.finish_move('A2', board) }.to output(string).to_stdout
  end

  it 'can cancel move and start again' do
    silence_output do
      allow(STDIN).to receive(:gets).and_return('X')
      expect { player1.finish_move('A2', board) }.to output(std_puts).to_stdout
      expect(player1.finish_move('A2', board)).to eql('X')
    end
  end

  it 'rejects if final square is not in piece\'s possible moves' do
    allow(STDIN).to receive(:gets).and_return('A6', 'A3')
    string = std_puts + "Can not move current piece there, pick another square\n" + std_puts
    expect { player1.finish_move('A2', board) }.to output(string).to_stdout
  end

  it 'completes a move and return a move combo for updating board/piece state' do
    silence_output do
      allow(STDIN).to receive(:gets).and_return('A3')
      expect(player1.finish_move('A2', board)).to eql(%w[A2 A3])
    end
  end

  it 'rejects if not a valid square length (or not equal to X or Q' do
    allow(STDIN).to receive(:gets).and_return('Z', 'B15', 'A3')
    string = std_puts
    2.times { string += "Enter a valid square\n#{std_puts}" }
    expect { player1.finish_move('A2', board) }.to output(string).to_stdout
  end

  it 'rejects if initial square is not on board' do
    allow(STDIN).to receive(:gets).and_return('C9', 'A3')
    string = "#{std_puts}Enter a valid square on the board\n#{std_puts}"
    expect { player1.finish_move('A2', board) }.to output(string).to_stdout
  end
end
