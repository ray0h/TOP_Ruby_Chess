# Player class
class Player
  attr_reader :id
  def initialize(player_id)
    @id = player_id
  end

  def change_id
    print "#{id}, what should I call you now? "
    new_id = gets.to_s.chomp
    self.id = new_id
  end

  def start_move
    print "#{id}, pick a square: "
    init_square = gets.to_s.chomp
    move = valid_square?(init_square)

    until move['valid']
      print "#{move['error_msg']}\n"
      print "#{id}, pick a square: "
      init_square = gets.to_s.chomp
      move = valid_square?(init_square)
    end
    init_square
  end

  private

  attr_writer :id

  def parse_coord(square)
    coord = square.split('')
    row = coord[0].to_i + 1
    col = coord[1].bytes[0] - 65
    [row, col]
  end

  def valid_id(square)
    square.length == 2
  end

  def valid_square?(square)
    return { 'valid' => false, 'error_msg' => 'Enter a valid square' } unless valid_id(square)

    { 'valid' => true, 'error_msg' => '' }
  end
end
