require './lib/king'

grid = []
0.upto(7) do
  row = Array.new(8) { nil }
  grid.push(row)
end

describe 'King - symbols and basic moves' do
  let(:wkg) { King.new('white', 'player1') }
  let(:bkg) { King.new('black', 'player2') }
  let(:board) { double }
  before(:each) do
    wkg.history.push('D4')
    allow(wkg).to receive(:square_occupied?).and_return(false)
    allow(board).to receive(:grid).and_return(grid)
  end

  it 'has unique/appropriate unicode symbols' do
    expect(wkg.symbol).to eql("\u2654")
    expect(bkg.symbol).to eql("\u265A")
  end

  it 'moves like a king piece - 1 space, diag/horiz/vert' do
    expect(wkg.possible_moves(board).length).to eql(8)
    expect(wkg.possible_moves(board)).to include('C3', 'C4', 'C5', 'D3', 'D5', 'E3', 'E4', 'E5')
  end

  it 'can move to spot occupied by opponent piece' do
    allow(wkg).to receive(:square_occupied?).with('E4', board).and_return('bk1')
    allow(wkg).to receive(:my_piece?).with('bk1').and_return(false)
    expect(wkg.possible_moves(board).length).to eql(8)
    expect(wkg.possible_moves(board)).to include('E4')
  end

  it 'can not move if surrounded by its own pieces' do
    allow(wkg).to receive(:square_occupied?).and_return('true')
    allow(wkg).to receive(:my_piece?).and_return(true)

    expect(wkg.possible_moves(board).length).to be_zero
  end
end

describe 'King - moves unique to king class' do
  let(:wkg) { King.new('white', 'player1') }
  let(:bkg) { King.new('black', 'player2') }
  let(:board) { double }
  let(:br1) { double }
  before(:each) do
    wkg.history.push('D4')
    allow(wkg).to receive(:square_occupied?).and_return(false)
    allow(board).to receive(:grid).and_return(grid)
  end

  it 'can not move into an empty square within opponent piece\'s possible moves' do
    allow(wkg).to receive(:get_opponent_pieces).with(board).and_return([br1])
    allow(wkg).to receive(:opponent_poss_moves).with(board).and_return(%w[E1 E2 E3 E4 E5 E6 E7 F8])

    expect(wkg.possible_moves(board).length).to eql(5)
    expect(wkg.possible_moves(board)).to_not include('E3', 'E4', 'E5')
  end

  xit 'can access appropriate squares if castling'
end
