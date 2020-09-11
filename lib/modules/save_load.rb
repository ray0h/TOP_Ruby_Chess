require 'yaml'

# methods related to saving/loading game
module SaveLoad

  private

  def list_saved_games(files)
    print "Saved chess games: \n"
    files.each_with_index do |file, ind|
      print "#{ind + 1}. #{file} \n"
    end
  end

  def choose_saved_game(files)
    choices = Array.new(files.length) { |el| (el + 1).to_s }
    print "Choose a game to load, or enter 'N' to start new game: \n"
    choice = ''
    until choices.include?(choice) || choice == 'n'
      print 'choice: '
      choice = STDIN.gets.to_s.chomp.downcase
    end
    choice != 'n' ? @files[choice.to_i - 1].to_s : 'n'
  end

  def save_game(files, directory, p1_pieces, p2_pieces, last_move)
    directory = directory + '/' + 'game' + (files.length + 1).to_s + '.txt'
    File.open(directory, 'w') do |f|
      YAML.dump({ p1_pieces: p1_pieces, p2_pieces: p2_pieces, last_move: last_move }, f)
    end
    print "game saved...goodbye \n"
  end

  def load_from_yaml(path)
    file = File.open(path, 'r')
    contents = file.read
    file.close
    data = YAML.load contents
    [data[:p1_pieces], data[:p2_pieces], data[:last_move]]
    # File.delete(path) # delete file after loading?
  end
end
