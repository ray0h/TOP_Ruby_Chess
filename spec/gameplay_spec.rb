require './lib/gameplay'

describe Gameplay do
  let(:game) { Gameplay.new }
  let(:piece_types) { game.p1_pieces.flatten.map { |piece| piece.class.name } }

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
        expect(game.p1_pieces.flatten.length).to eql(16)
        expect(game.p2_pieces.flatten.length).to eql(16)
      end

      it 'includes the appropriate types/numbers of each piece' do
        expect(piece_types.count('King')).to eql(1)
        expect(piece_types.count('Queen')).to eql(1)
        expect(piece_types.count('Rook')).to eql(2)
        expect(piece_types.count('Bishop')).to eql(2)
        expect(piece_types.count('Knight')).to eql(2)
        expect(piece_types.count('Pawn')).to eql(8)
      end
    end

    it 'adds pieces to the board for a new game' do
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
      expect(game.board.grid[1][3]).to be_truthy
      expect(game.board.grid[3][3]).to be_nil
      allow(STDIN).to receive(:gets).and_return('D2', 'D4')
      string = "player1, pick a square: player1, pick a square to move to, or press 'XX' to cancel move: "
      expect { game.play }.to output(string).to_stdout
      expect(game.board.grid[1][3]).to be_nil
      expect(game.board.grid[3][3]).to be_truthy
    end

    xit 'removes captured pieces'
    xit 'recognizes checks'
    xit 'recognizes checkmates'
    xit 'recognizes stalemates'
  end

  context 'advanced gameplay' do
    xit 'handles castling moves'
    xit 'handles pawn promotion'
  end
end
