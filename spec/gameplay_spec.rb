require './lib/gameplay'
require './lib/king'
require './lib/rook'

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

  context 'setting up' do
    it 'sets up two players' do
      expect(game.player1.class.name).to eql('Player')
      expect(game.player2.class.name).to eql('Player')
    end

    it 'sets up a chessboard' do
      expect(game.board.class.name).to eql('Board')
    end
  end

  context 'basic gameplay' do
    it 'reflects a player move on the board' do
      silence_output do
        game.setup_new_game
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
        game.setup_new_game
        game.play
        expect(game.p2_pieces.length).to eql(15)
      end
    end

    it 'recognizes checks' do
      silence_output do
        expect(game.p1_check).to be_falsy
        allow(STDIN).to receive(:gets).and_return('F2', 'F4', 'E7', 'E6', 'B1', 'C3', 'D8', 'H4', 'Q')
        game.setup_new_game
        game.play
        expect(game.p1_check).to be_truthy
      end
    end

    it 'will not allow player move if king remains in check' do
      silence_output do
        allow(STDIN).to receive(:gets).and_return('F2', 'F4', 'E7', 'E6', 'B1', 'C3', 'D8', 'H4', 'A2', 'A3', 'Q')
        game.setup_new_game
        game.play
        expect(game.board.grid[2][0]).to be_nil
        expect(game.board.grid[1][0]).to be_truthy
      end
    end

    context 'checkmates' do
      let(:bkg) { King.new('black', 'player2') }
      let(:wkg) { King.new('white', 'player1') }
      let(:wr1) { Rook.new('white', 'player1') }
      it 'recognizes checkmates' do
        bkg.history.push('H8')
        wkg.history.push('F7')
        wr1.history.push('H1')
        p1_pieces = [wkg, wr1]
        p2_pieces = [bkg]

        silence_output do
          game.setup_in_progress_game(p1_pieces, p2_pieces)
          game.play
          expect(game.p2_check).to be_truthy
        end
      end
    end

    context 'stalemates' do
      let(:bkg) { King.new('black', 'player2') }
      let(:wkg) { King.new('white', 'player1') }
      let(:wr1) { Rook.new('white', 'player1') }
      it 'recognizes stalemates' do
        bkg.history.push('H1')
        wkg.history.push('H3')
        wr1.history.push('G8')
        p1_pieces = [wkg, wr1]
        p2_pieces = [bkg]

        silence_output do
          game.setup_in_progress_game(p1_pieces, p2_pieces)
          game.play
          expect(game.p2_check).to be_falsy
        end
      end
    end
  end

  context 'advanced gameplay' do
    let(:bkg) { King.new('black', 'player2') }
    let(:wkg) { King.new('white', 'player1') }
    let(:wr1) { Rook.new('white', 'player1') }
    it 'executes castling moves' do
      bkg.history.push('A8')
      wkg.history.push('E1')
      wr1.history.push('H1')
      p1_pieces = [wkg, wr1]
      p2_pieces = [bkg]

      silence_output do
        allow(STDIN).to receive(:gets).and_return('E1', 'G1', 'Q')
        game.setup_in_progress_game(p1_pieces, p2_pieces)
        game.play
        expect(game.board.grid[0][6].class).to eql(King)
        expect(game.board.grid[0][5].class).to eql(Rook)
      end
    end

    xit 'handles pawn promotion'
  end
end
