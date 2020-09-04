require './lib/player'

describe 'Player - id' do
  let(:player1) { Player.new('player1') }
  it 'can change name/id' do
    expect(player1.id).to eql('player1')
    # allow(player1).to receive(:change_id)
    allow(player1).to receive(:gets).and_return('Bob')
    expect { player1.change_id }.to output('player1, what should I call you now? ').to_stdout
    expect(player1.id).to eql('Bob')
  end
end

describe 'Player - moves - picking intitial square' do
  xit 'asks for an initial square'
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
