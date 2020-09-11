require './lib/modules/setup_board'
require './lib/board'

# prevents methods that puts / print text from doing so when testing for returns
# `yield` allows code wrapped in method to run
def silence_output
  orig_stdout = $stdout
  $stdout = StringIO.new
  yield
  $stdout = orig_stdout
end

describe 'SetupBoard' do
  include SetupBoard
  let(:player1) { double('Player', id: 'player1', history: [])}
  let(:player2) { double('Player', id: 'player2', history: []) }
  let(:board) { Board.new }
  # let(:setup) { Class.new { include SetupBoard } }

  context 'new board' do
    it 'has method to set up a new/fresh chessboard' do
      new_game(player1, player2, board)
      expect(board.grid[7].none?(nil)).to be_truthy
      expect(board.grid[6].none?(nil)).to be_truthy
      expect(board.grid[1].none?(nil)).to be_truthy
      expect(board.grid[0].none?(nil)).to be_truthy
      expect(board.grid[7][4].color).to eql('black')
      expect(board.grid[0][4].color).to eql('white')
    end

    it 'assigns a set of 16 pieces to a player' do
      p1_pieces, p2_pieces = new_game(player1, player2, board)
      expect(p1_pieces.length).to eql(16)
      expect(p2_pieces.length).to eql(16)
    end

    it 'includes the appropriate types/numbers of each piece' do
      p1_pieces, p2_pieces = new_game(player1, player2, board)
      piece_types = p1_pieces.map(&:class)
      expect(piece_types.count(King)).to eql(1)
      expect(piece_types.count(Queen)).to eql(1)
      expect(piece_types.count(Rook)).to eql(2)
      expect(piece_types.count(Bishop)).to eql(2)
      expect(piece_types.count(Knight)).to eql(2)
      expect(piece_types.count(Pawn)).to eql(8)
    end
  end

  let(:wkg) { double('King', color: 'white', history: ['E1']) }
  let(:wp1) { double('Pawn', color: 'white', history: ['A2']) }
  let(:bkg) { double('King', color: 'black', history: ['H5']) }
  let(:bqn) { double('Queen', color: 'black', history: ['A8']) }
  it 'sets up a custom board' do
    p1_pieces = [wkg, wp1]
    p2_pieces = [bqn, bkg]
    in_progress_game(p1_pieces, p2_pieces, board)
    expect(board.grid[1][1]).to be_nil
    expect(board.grid[1][0]).to be_truthy
    expect(board.grid[0][4]).to be_truthy
    expect(board.grid[7][0]).to be_truthy
    expect(board.grid[4][7]).to be_truthy
    expect(board.grid[4][7].color).to eql('black')
  end

  let(:wp8) { double('Pawn', color: 'white', player_id: 'player1', history: %w[H2 H4 H5 H6 H7 H8]) }
  it 'adds to board and returns a promoted pawn piece' do
    silence_output do
      allow(STDIN).to receive(:gets).and_return('Rook')
      promoted_piece = promoted_pawn(wp8, board)
      expect(promoted_piece.class).to eql(Rook)
      expect(promoted_piece.history.last).to eql('H8')
      expect(board.grid[7][7].class).to eql(Rook)
    end
  end
end
