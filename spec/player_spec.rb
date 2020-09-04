require './lib/player'

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
  it 'asks for an initial square' do
    allow(player1).to receive(:gets).and_return('B2')
    expect { player1.start_move }.to output('player1, pick a square: ').to_stdout
  end

  it 'rejects if not a valid square length' do
    allow(player1).to receive(:gets).and_return('Q', 'B15', 'A1')
    string = 'player1, pick a square: '
    2.times { string += "Enter a valid square\nplayer1, pick a square: " }
    expect { player1.start_move }.to output(string).to_stdout
  end

  xit 'rejects if initial square is not on board'
  xit 'rejects if initial square is unoccupied'
  xit 'rejects if initial square is occupied by opponents piece'
  xit 'prints back the piece picked'
end

describe 'Player - moves - choosing final square to move piece' do
  xit 'asks for a final square to move piece to'
  xit 'can cancel move and start again'
  xit 'rejects if final square is not in piece\'s possible moves'
  xit 'completes a move and return a move combo for updating board/piece state'
end
