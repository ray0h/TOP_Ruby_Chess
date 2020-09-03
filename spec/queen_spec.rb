require './lib/queen'

describe Queen do
  let(:wqn) { Queen.new('white', 'player1') }
  let(:bqn) { Queen.new('black', 'player2') }
  let(:board) { double }

  it 'has unique/appropriate unicode symbols' do
    expect(wqn.symbol).to eql("\u2655")
    expect(bqn.symbol).to eql("\u265B")
  end

  xit 'moves like a queen piece (diag/horiz/vert)'
  xit 'can move to spot occupied by opponent piece (but not beyond)'
  xit 'can not move if surrounded by its own pieces'
end