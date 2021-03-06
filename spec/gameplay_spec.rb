require './lib/gameplay'
require './lib/pieces/king'
require './lib/pieces/rook'
require './lib/pieces/pawn'
require 'fileutils'

# prevents methods that puts / print text from doing so when testing for returns
# `yield` allows code wrapped in method to run
def silence_output
  orig_stdout = $stdout
  $stdout = StringIO.new
  yield
  $stdout = orig_stdout
end

describe 'Gameplay - setting up' do
  let(:game) { Gameplay.new }

  it 'sets up two players' do
    expect(game.player1.class.name).to eql('Player')
    expect(game.player2.class.name).to eql('Player')
  end

  it 'sets up a chessboard' do
    expect(game.board.class.name).to eql('Board')
  end
end

describe 'Gameplay - basic gameplay' do
  let(:game) { Gameplay.new }
  let(:bkg) { King.new('black', 'player2') }
  let(:wkg) { King.new('white', 'player1') }
  let(:wr1) { Rook.new('white', 'player1') }

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
      allow(STDIN).to receive(:gets).and_return('F2', 'F4', 'E7', 'E6', 'B1', 'C3', 'D8', 'H4', 'Q')
      game.setup_new_game
      game.play
      last_str = $stdout.string[-30..-1]
      expect(last_str).to eql("Check\nplayer1, pick a square: ")
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

  it 'recognizes checkmates' do
    bkg.history.push('H8')
    wkg.history.push('F7')
    wr1.history.push('G1')

    silence_output do
      allow(STDIN).to receive(:gets).and_return('G1', 'H1')
      game.setup_in_progress_game([wkg, wr1], [bkg], %w[H7 H8])
      game.play
      last_str = $stdout.string[-22..-1]
      expect(last_str).to eql("Checkmate!, Game over\n")
    end
  end

  it 'recognizes stalemates' do
    bkg.history.push('H1')
    wkg.history.push('H3')
    wr1.history.push('G8')

    silence_output do
      allow(STDIN).to receive(:gets).and_return('G8', 'G7')
      game.setup_in_progress_game([wkg, wr1], [bkg], %w[G1 H1])
      game.play
      first_str = $stdout.string[0, 21]
      expect(first_str).to eql("Stalemate, Game over\n")
    end
  end
end

describe 'Gameplay - advanced gameplay' do
  let(:game) { Gameplay.new }
  let(:bkg) { King.new('black', 'player2') }
  let(:wkg) { King.new('white', 'player1') }
  let(:wr1) { Rook.new('white', 'player1') }
  let(:wp1) { Pawn.new('white', 'player1') }
  let(:bp2) { Pawn.new('black', 'player2') }

  it 'executes castling moves' do
    bkg.history.push('A8')
    wkg.history.push('E1')
    wr1.history.push('H1')

    silence_output do
      allow(STDIN).to receive(:gets).and_return('E1', 'G1', 'Q')
      game.setup_in_progress_game([wkg, wr1], [bkg], %w[A7 A8])
      game.play
      expect(game.board.grid[0][6].class).to eql(King)
      expect(game.board.grid[0][5].class).to eql(Rook)
    end
  end

  it 'handles pawn promotion' do
    bkg.history.push('E8')
    wkg.history.push('E1')
    wp1.history.push('A7')
    silence_output do
      allow(STDIN).to receive(:gets).and_return('A7', 'A8', 'Rook', 'Q')
      game.setup_in_progress_game([wkg, wp1], [bkg], %w[E7 E8])

      game.play
      expect(game.board.grid[7][0].class).to eql(Rook)
      expect(game.p1_pieces.length).to eql(2)
    end
  end

  context 'en passant moves' do
    before(:each) do
      wp1.history.push('A2')
      bp2.history = %w[B7 B5 B4]
      wkg.history.push('E1')
      bkg.history.push('E8')
    end

    it 'can execute pawn en passant when first given chance' do
      silence_output do
        allow(STDIN).to receive(:gets).and_return('A2', 'A4', 'Q')
        game.setup_in_progress_game([wkg, wp1], [bkg, bp2], %w[B5 B4])
        game.play
        expect(bp2.possible_moves(game.board).length).to eql(2)
        expect(bp2.possible_moves(game.board)).to include('A3')
      end
    end

    it 'can no longer en passant if alternate move made when first given chance' do
      silence_output do
        allow(STDIN).to receive(:gets).and_return('A2', 'A4', 'E8', 'E7', 'Q')
        game.setup_in_progress_game([wkg, wp1], [bkg, bp2], %w[B5 B4])
        game.play
        expect(bp2.possible_moves(game.board).length).to eql(1)
        expect(bp2.possible_moves(game.board)).to_not include('A3')
      end
    end

    it 'recognizes and removes an en passant captured piece' do
      silence_output do
        allow(STDIN).to receive(:gets).and_return('A2', 'A4', 'B4', 'A3', 'Q')
        game.setup_in_progress_game([wkg, wp1], [bkg, bp2], %w[B5 B4])
        game.play
        expect(game.p1_pieces.length).to eql(1)
        expect(game.board.grid[3][0]).to be_nil
      end
    end
  end
end

describe 'Gameplay - saving/loading' do
  let(:game) { Gameplay.new }

  xit 'can save a game' do
    directory = './saved_games'
    # FileUtils.rm_rf Dir.glob(directory + '/**')
    # expect(Dir.glob(directory + '/**').length).to eql(0)
    files = Dir.glob(directory + '/**').length
    allow(STDIN).to receive(:gets).and_return('D2', 'D4', 'S')
    silence_output do
      game.setup_new_game
      game.play
      expect(Dir.glob(directory + '/**').length).to be(files + 1)
    end
  end

  it 'can load a game' do
    allow(STDIN).to receive(:gets).and_return(1)
    silence_output do
      game.setup_board
      expect(game.board.grid[1][3]).to be_nil
      expect(game.board.grid[3][3].class).to be(Pawn)
    end
  end

  it 'can start a brand new game' do
    allow(STDIN).to receive(:gets).and_return('N')
    silence_output do
      game.setup_board
      expect(game.board.grid[0].none?(nil)).to be_truthy
      expect(game.board.grid[1].none?(nil)).to be_truthy

      expect(game.board.grid[2].all?(nil)).to be_truthy
      expect(game.board.grid[3].all?(nil)).to be_truthy
      expect(game.board.grid[4].all?(nil)).to be_truthy
      expect(game.board.grid[5].all?(nil)).to be_truthy

      expect(game.board.grid[6].none?(nil)).to be_truthy
      expect(game.board.grid[7].none?(nil)).to be_truthy
    end
  end
end
