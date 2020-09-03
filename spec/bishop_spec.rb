require './lib/bishop'

describe Bishop do
  let(:wb1) { Bishop.new('white', 'player1') }
  let(:bb1) { Bishop.new('black', 'player2') }
  let(:board) { double }
  before(:each) { wb1.history.push('D4') }

  it 'has unique/appropriate unicode symbols' do
    expect(wb1.symbol).to eql("\u2657")
    expect(bb1.symbol).to eql("\u265D")
  end

  it 'moves like a bishop piece (diagonally)' do
    allow(wb1).to receive(:square_occupied?).and_return(false)

    expect(wb1.possible_moves(board).length).to eql(13)
    expect(wb1.possible_moves(board)).to include('H8', 'A7', 'A1', 'G1')
  end

  it 'can not move to a spot beyond where its path is blocked' do
    allow(wb1).to receive(:square_occupied?).and_return(false)
    allow(wb1).to receive(:square_occupied?).with('F6', board).and_return(bb1)

    expect(wb1.possible_moves(board).length).to eql(10)
    expect(wb1.possible_moves(board)).to include('A1', 'A7', 'G1')
    expect(wb1.possible_moves(board)).to_not include('G7', 'H8')
  end

  it 'can not move if surrounded by other pieces' do
    allow(wb1).to receive(:square_occupied?).and_return('yes')
    
    expect(wb1.possible_moves(board).length).to be_zero
  end
end
