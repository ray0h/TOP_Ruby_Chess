require './lib/gameplay'

# prevents methods that puts / print text from doing so when testing for returns
# `yield` allows code wrapped in method to run
def silence_output
  orig_stdout = $stdout
  $stdout = StringIO.new
  yield
  $stdout = orig_stdout
end

describe Gameplay do
  let(:game) { Gameplay.new }
  let(:piece_types) { game.p1_pieces.map { |piece| piece.class.name } }

  context 'setting up' do
    it 'sets up two players' do
      expect(game.player1.class.name).to eql('Player')
      expect(game.player2.class.name).to eql('Player')
    end

    it 'sets up a chessboard' do
      expect(game.board.class.name).to eql('Board')
    end

    context 'player piece assignment' do
      it 'assigns a set of 16 pieces to a player' do
        game.setup_new
        expect(game.p1_pieces.flatten.length).to eql(16)
        expect(game.p2_pieces.flatten.length).to eql(16)
      end

      it 'includes the appropriate types/numbers of each piece' do
        game.setup_new
        expect(piece_types.count('King')).to eql(1)
        expect(piece_types.count('Queen')).to eql(1)
        expect(piece_types.count('Rook')).to eql(2)
        expect(piece_types.count('Bishop')).to eql(2)
        expect(piece_types.count('Knight')).to eql(2)
        expect(piece_types.count('Pawn')).to eql(8)
      end
    end

    it 'adds pieces to the board for a new game' do
      game.setup_new
      expect(game.board.grid[7].none?(nil)).to be_truthy
      expect(game.board.grid[6].none?(nil)).to be_truthy
      expect(game.board.grid[1].none?(nil)).to be_truthy
      expect(game.board.grid[0].none?(nil)).to be_truthy
      expect(game.board.grid[7][4].color).to eql('black')
      expect(game.board.grid[0][4].color).to eql('white')
    end
  end

  context 'basic gameplay' do
    it 'reflects a player move on the board' do
      silence_output do
        game.setup_new
        expect(game.board.grid[1][3]).to be_truthy
        expect(game.board.grid[3][3]).to be_nil
        allow(STDIN).to receive(:gets).and_return('D2', 'D4', 'Q')
        game.play
        expect(game.board.grid[1][3]).to be_nil
        expect(game.board.grid[3][3]).to be_truthy
      end
    end

    it 'removes captured pieces' do
      silence_output do
        allow(STDIN).to receive(:gets).and_return('D2', 'D4', 'E7', 'E5', 'D4', 'E5', 'Q')
        game.setup_new
        game.play
        expect(game.p2_pieces.length).to eql(15)
      end
    end

    it 'recognizes checks' do
      silence_output do
        expect(game.p1_check).to be_falsy
        allow(STDIN).to receive(:gets).and_return('F2', 'F4', 'E7', 'E6', 'B1', 'C3', 'D8', 'H4', 'Q')
        game.setup_new
        game.play
        expect(game.p1_check).to be_truthy
      end
    end

    it 'will not allow player move if king remains in check' do
      silence_output do
        allow(STDIN).to receive(:gets).and_return('F2', 'F4', 'E7', 'E6', 'B1', 'C3', 'D8', 'H4', 'A2', 'A3', 'Q')
        game.setup_new
        game.play
        expect(game.board.grid[2][0]).to be_nil
        expect(game.board.grid[1][0]).to be_truthy

      end
    end
    let(:bkg) { double('King', color: 'black', history: ['H8'], symbol: "\u265A") }
    let(:wkg) { double('King', color: 'white', history: ['F7'], symbol: "\u2654") }
    let(:wr1) { double('Rook', color: 'white', history: ['H1'], symbol: "\u2656") }
    let(:board) { double }
    it 'recognizes checkmates' do
      silence_output do
        allow(bkg).to receive(:possible_moves).and_return([])
        allow(wkg).to receive(:possible_moves).and_return(%w[E8 F8 G8 E7 G7 E6 F6 G6])
        allow(wr1).to receive(:possible_moves).and_return(%w[A1 B1 C1 D1 E1 F1 G1 H2 H3 H4 H5 H6 H7 H8])
        allow(bkg).to receive(:class).and_return(King)
        allow(wkg).to receive(:class).and_return(King)

        p1_pieces = [wkg, wr1]
        p2_pieces = [bkg]
        game.setup_in_progress(p1_pieces, p2_pieces)
        game.play
        expect(game.p2_check).to be_truthy
      end
    end

    xit 'recognizes stalemates'
  end

  context 'advanced gameplay' do
    xit 'handles castling moves'
    xit 'handles pawn promotion'
  end
end
