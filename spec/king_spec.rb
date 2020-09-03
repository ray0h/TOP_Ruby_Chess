require './lib/king'

describe 'King - symbols and basic moves' do
  let(:wkg) { King.new('white', 'player1') }
  let(:bkg) { King.new('black', 'player2') }
  let(:board) { double }
  before(:each) do
    wkg.history.push('D4')
    allow(wkg).to receive(:square_occupied?).and_return(false)
  end

  it 'has unique/appropriate unicode symbols' do
    expect(wkg.symbol).to eql("\u2654")
    expect(bkg.symbol).to eql("\u265A")
  end

  xit 'moves like a king piece - 1 space, diag/horiz/vert'
  xit 'can move to spot occupied by opponent piece'
  xit 'can not move if surrounded by its own pieces'
end

describe 'King - moves unique to king class' do
  xit 'can not move into an empty square within opponent piece\'s possible moves'
  xit 'can access appropriate squares if castling'
end
