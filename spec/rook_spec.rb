require './lib/rook'

describe Rook do
  let(:wr1) { Rook.new('white', 'player1') }
  let(:br1) { Rook.new('black', 'player1') }
  let(:board) { double }
  before(:each) do
    wr1.history.push('D4')
    allow(wr1).to receive(:square_occupied?).and_return(false)
  end

  it 'has unique/appropriate unicode symbols' do
    expect(wr1.symbol).to eql("\u2656")
    expect(br1.symbol).to eql("\u265C")
  end

  it 'moves like a rook piece (horiz/vert)' do
    expect(wr1.possible_moves(board).length).to eql(14)
    expect(wr1.possible_moves(board)).to include('D1', 'D8', 'A4', 'G4', 'C4', 'E4', 'D3', 'D5')
  end

  xit 'can move to spot occupied by opponent piece (but not beyond)'
  xit 'can not move if surrounded by its own pieces'
end
