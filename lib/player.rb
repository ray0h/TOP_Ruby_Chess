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

  private

  attr_writer :id
end
