require './lib/knight'

describe Knight do
  let(:bk1) { Knight.new('black', 'player2') }
  let(:bk2) { Knight.new('black', 'player2') }
  let(:board) { double }
  before(:each) { allow(bk1).to receive(:square_occupied?).and_return(false) }

  it 'has unique/appropriate unicode symbols' do
    expect(bk1.symbol).to eql("\u265E")
  end

  it 'moves like a knight piece' do
    bk1.history.push('D4')
    expect(bk1.possible_moves(board).length).to eql(8)
    expect(bk1.possible_moves(board)).to include('B3', 'B5', 'C2', 'C6', 'E2', 'E6', 'F3', 'F5')
  end

  it 'only has possible moves that stay on board' do
    bk1.history.push('G1')
    expect(bk1.possible_moves(board).length).to eql(3)
    expect(bk1.possible_moves(board)).to include('E2', 'F3', 'H3')
  end

  it 'can not move to spot occupied by one of its same colored pieces' do
    allow(bk1).to receive(:square_occupied?).with('B3', board).and_return(bk2)
    bk1.history.push('D4')
    expect(bk1.possible_moves(board).length).to eql(7)
    expect(bk1.possible_moves(board)).to_not include('B3')
  end
end
