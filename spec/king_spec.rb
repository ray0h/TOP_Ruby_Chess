require './lib/pieces/king'

grid = Array.new(8) { Array.new(8) { nil } }

describe 'King - symbols' do
  let(:wkg) { King.new('white', 'player1') }
  let(:bkg) { King.new('black', 'player2') }

  it 'has unique/appropriate unicode symbols' do
    expect(wkg.symbol).to eql("\u2654")
    expect(bkg.symbol).to eql("\u265A")
  end
end

describe 'King - basic moves' do
  let(:wkg) { King.new('white', 'player1') }
  let(:board) { double(grid: grid) }
  before(:each) do
    wkg.history.push('D4')
    allow(wkg).to receive(:square_occupied?).and_return(false)
    allow(board).to receive(:add_piece)
    allow(board).to receive(:move_piece)
  end

  it 'moves like a king piece - 1 space, diag/horiz/vert' do
    expect(wkg.possible_moves(board).length).to eql(8)
    expect(wkg.possible_moves(board)).to include('C3', 'C4', 'C5', 'D3', 'D5', 'E3', 'E4', 'E5')
  end

  let(:bp1) { double('Pawn', history: ['E3'], color: 'black', possible_moves: %w[E2]) }
  it 'can move to spot occupied by opponent piece' do
    grid[3][3] = wkg
    grid[2][4] = bp1
    allow(wkg).to receive(:square_occupied?).with('E3', board).and_return(bp1)
    expect(wkg.possible_moves(board).length).to eql(8)
    expect(wkg.possible_moves(board)).to include('E3')
    grid[3][3] = nil
    grid[2][4] = nil
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
  let(:board) { double(grid: grid) }
  let(:br1) { double('Rook', color: 'black', history: ['D8'], possible_moves: %w[D1 D2 D3 D4 D5 D6 D7 C8]) }
  let(:wr2) { double('Rook', color: 'white', history: ['H1']) }
  before(:each) do
    wkg.history.push('E1')
    allow(wkg).to receive(:square_occupied?).and_return(false)
  end

  it 'can not move into an empty square within opponent piece\'s possible moves' do
    grid[7][3] = br1
    grid[0][4] = wkg
    allow(wkg).to receive(:get_opponent_pieces).with(board).and_return([br1])
    allow(board).to receive(:move_piece)

    expect(wkg.possible_moves(board).length).to eql(3)
    expect(wkg.possible_moves(board)).to_not include('D1', 'D2')
    grid[7][3] = nil
    grid[0][4] = nil
  end

  it 'can access appropriate squares if castling' do
    allow(wkg).to receive(:get_rooks).with(board).and_return([wr2])
    allow(wr2).to receive(:first_move?).and_return(true)
    allow(wkg).to receive(:opponent_poss_moves).with(board).and_return([])
    allow(wkg).to receive(:get_between_squares).with(wr2).and_return(%w[F1 G1])
    allow(board).to receive(:move_piece)

    expect(wkg.possible_moves(board).length).to eql(6)
    expect(wkg.possible_moves(board)).to include('G1')
  end
end
