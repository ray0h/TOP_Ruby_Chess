require './lib/piece'

describe Piece do
  let(:generic) { described_class.new('black', 'player1') }
  it 'has a color id' do
    expect(generic.color).to eql('black')
  end
  it 'id\'s the opponent color' do
    expect(generic.opponent).to eql('white')
  end
  it 'has a player id' do
    expect(generic.player_id).to eql('player1')
  end
  it 'has a move history' do
    expect(generic.history).to be_an(Array)
    expect(generic.history.length).to eql(0)
  end
end
