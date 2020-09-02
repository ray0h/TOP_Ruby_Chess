require './lib/pawn'

grid1 = Array.new(8) { Array.new(8) { nil } }

describe Pawn do
  let(:wp1) { described_class.new('white', 'player1') }
  let(:bp1) { described_class.new('black', 'player2') }
  let(:board) { double }

  it 'has an appropriate pawn unicode symbol' do
    expect(wp1.symbol).to eql("\u2659")
    expect(bp1.symbol).to eql("\u265F")
  end

  it 'can move forward one or two spaces to start' do
    allow(board).to receive(:grid).and_return(grid1)
    wp1.history.push('A2')
    expect(wp1.possible_moves(board)).to include('A3', 'A4')
    expect(wp1.possible_moves(board)).to_not include('B3')
    bp1.history.push('B7')
    expect(bp1.possible_moves(board)).to include('B6', 'B5')
    bp1.history.push('B6')
    expect(bp1.possible_moves(board)).to include('B5')
    expect(bp1.possible_moves(board).length).to eql(1)
  end

  it 'can "move"(capture) if opponent piece is diagonal' do
    wp1.history.push('B2')
    wp1.history.push('B4')
    allow(wp1).to receive(:square_occupied?).with('C5', board).and_return(bp1)
    allow(wp1).to receive(:square_occupied?).with('A5', board).and_return(false)
    expect(wp1.possible_moves(board).length).to eql(2)
    expect(wp1.possible_moves(board)).to include('B5', 'C5')
  end
end
