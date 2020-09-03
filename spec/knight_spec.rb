require './lib/knight'

describe Knight do
  let(:bk1) { Knight.new('black', 'player2') }
  let(:board) { double }

  it 'has unique/appropriate unicode symbols' do
    expect(bk1.symbol).to eql("\u265E")
  end

  it 'moves like a knight piece' do
    bk1.history.push('D4')
    expect(bk1.possible_moves.length).to eql(8)
    expect(bk1.possible_moves).to include('B3', 'B5', 'C2', 'C6', 'E2', 'E6', 'F3', 'F5')
  end

  it 'only has possible moves that stay on board' do
    bk1.history.push('G1')
    expect(bk1.possible_moves.length).to eql(3)
    expect(bk1.possible_moves).to include('E2', 'F3', 'H3')
  end
end
