require './lib/knight'

describe Knight do
  let(:bk1) { Knight.new('black', 'player2') }
  let(:board) { double }

  it 'has unique/appropriate unicode symbols' do
    expect(bk1.symbol).to eql("\u265E")
  end

  xit 'moves like a knight piece' do
  end

  xit 'only has possible moves that stay on board'
end
