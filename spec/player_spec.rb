require './lib/player'

describe 'Player - id' do
  xit 'can change name/id'
end

describe 'Player - moves - picking intitial square' do
  xit 'asks for an initial square'
  xit 'rejects if initial square is not on board'
  xit 'rejects if initial square is unoccupied'
  xit 'rejects if initial square is occupied by opponents piece'
  xit 'prints back the piece picked'
end

describe 'Player - moves - choosing final square to move piece' do
  xit 'asks for a final square to move piece to'
  xit 'can cancel move and start again'
  xit 'rejects if final square is not in piece\'s possible moves'
  xit 'completes a move and return a move combo for updating board/piece state'
end
