require './lib/bishop'

describe Bishop do
  let(:wb1) { Bishop.new('white', 'player1') } 
  let(:bb1) { Bishop.new('black', 'player2') }

  it 'has unique/appropriate unicode symbols' do
    expect(wb1.symbol).to eql("\u2657")
    expect(bb1.symbol).to eql("\u265D")
  end

  it 'moves like a bishop piece (diagonally)' do
    wb1.history.push('D4')
    expect(wb1.possible_moves.length).to eql(13)
    expect(wb1.possible_moves).to include('H8', 'A7', 'A1', 'G1')
  end

  xit 'can not move to a spot beyond where its path is blocked'

  xit 'can not move if surrounded by other pieces'
end
