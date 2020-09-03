require './lib/queen'

describe Queen do
  let(:wqn) { Queen.new('white', 'player1') }
  let(:bqn) { Queen.new('black', 'player2') }
  let(:board) { double }
  before(:each) do
    wqn.history.push('D4')
    allow(wqn).to receive(:square_occupied?).and_return(false)
  end

  it 'has unique/appropriate unicode symbols' do
    expect(wqn.symbol).to eql("\u2655")
    expect(bqn.symbol).to eql("\u265B")
  end

  it 'moves like a queen piece (diag/horiz/vert)' do
    expect(wqn.possible_moves(board).length).to eql(27)
    expect(wqn.possible_moves(board)).to include('A1', 'A4', 'A7', 'D1', 'D8', 'G1', 'H4', 'H8')
  end

  xit 'can move to spot occupied by opponent piece (but not beyond)'
  xit 'can not move if surrounded by its own pieces'
end