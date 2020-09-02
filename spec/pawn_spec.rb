require './lib/pawn'

grid1 = []
0.upto(7) do
  row = Array.new(8) { nil }
  grid1.push(row)
end

describe 'Pawn - initial moves' do
  let(:wp1) { Pawn.new('white', 'player1') }
  let(:bp1) { Pawn.new('black', 'player2') }
  let(:board) { double }

  it 'has an appropriate pawn unicode symbol' do
    expect(wp1.symbol).to eql("\u2659")
    expect(bp1.symbol).to eql("\u265F")
  end

  it 'can move forward one or two spaces to start' do
    allow(board).to receive(:grid).and_return(grid1)
    wp1.history.push('A2')
    expect(wp1.possible_moves(board)).to include('A3', 'A4')
    expect(wp1.possible_moves(board).length).to eql(2)
  end

  it 'can move forward only one space after first move' do
    allow(board).to receive(:grid).and_return(grid1)
    bp1.history.push('B7')
    expect(bp1.possible_moves(board)).to include('B6', 'B5')
    bp1.history.push('B6')
    expect(bp1.possible_moves(board)).to include('B5')
    expect(bp1.possible_moves(board).length).to eql(1)
  end
end

describe 'Pawn - blocked paths' do
  let(:wp1) { Pawn.new('white', 'player1') }
  let(:bp1) { Pawn.new('black', 'player2') }
  let(:board) { double }

  it 'can not single move if piece is in front of it' do
    grid1[2][0] = bp1
    allow(board).to receive(:grid).and_return(grid1)
    wp1.history.push('A2')
    expect(wp1.possible_moves(board).length).to be_zero
  end

  it 'can not double move if piece is in front of it' do
    grid1[2][0] = nil
    grid1[3][0] = bp1
    allow(board).to receive(:grid).and_return(grid1)
    wp1.history.push('A2')
    expect(wp1.possible_moves(board).length).to eql(1)
    expect(wp1.possible_moves(board)).to include('A3')
  end
end

describe 'Pawn - capturing moves' do
  let(:wp1) { Pawn.new('white', 'player1') }
  let(:bp1) { Pawn.new('black', 'player2') }
  let(:board) { double }

  it 'can "move"(capture) if opponent piece is diagonal' do
    wp1.history.push('B2')
    wp1.history.push('B4')
    allow(wp1).to receive(:square_occupied?).with('B5', board).and_return(false)
    allow(wp1).to receive(:square_occupied?).with('A5', board).and_return(false)
    allow(wp1).to receive(:square_occupied?).with('C5', board).and_return(bp1)
    expect(wp1.possible_moves(board).length).to eql(2)
    expect(wp1.possible_moves(board)).to include('B5', 'C5')
  end

  it 'can capture en passant' do
    wp1.history = %w[C2 C4]
    bp1.history = %w[B7 B5 B4]
    wp1.ep_flag = true
    allow(bp1).to receive(:square_occupied?).with('C4', board).and_return(wp1)
    allow(bp1).to receive(:square_occupied?).with('A4', board).and_return(false)
    allow(bp1).to receive(:square_occupied?).with('A3', board).and_return(false)
    allow(bp1).to receive(:square_occupied?).with('B3', board).and_return(false)
    allow(bp1).to receive(:square_occupied?).with('C3', board).and_return(false)
    expect(bp1.possible_moves(board).length).to eql(2)
    expect(bp1.possible_moves(board)).to include('B3', 'C3')
  end
end
