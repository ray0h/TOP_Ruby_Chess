require './lib/gameplay'

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

    xit 'assigns a set of pieces to a player'
    xit 'adds pieces to the board for a new game'
  end

  context 'basic gameplay' do
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
