require './lib/rook'

describe Rook do
  let(:wr1) { Rook.new('white', 'player1') }
  let(:br1) { Rook.new('black', 'player1') }
  let(:board) { double }

  it 'has unique/appropriate unicode symbols' do
    expect(wr1.symbol).to eql("\u2656")
    expect(br1.symbol).to eql("\u265C")
  end

  xit 'moves like a rook piece (horiz/vert)'
  xit 'can move to spot occupied by opponent piece (but not beyond)'
  xit 'can not move if surrounded by its own pieces'
end
