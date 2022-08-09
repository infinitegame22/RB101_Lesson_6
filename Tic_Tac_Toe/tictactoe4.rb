require 'pry'

INITIAL_MARKER = ' '
PLAYER_MARKER = 'X'
COMPUTER_MARKER = 'O'

WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                [[1, 5, 9], [3, 5, 7]]              # diagonals

def prompt(msg)
  puts "=> #{msg}"
end

# rubocop:disable Metrics/AbcSize
def display_board(brd)
  system 'clear'
  puts "You're a #{PLAYER_MARKER}. Computer is #{COMPUTER_MARKER}."
  puts ""
  puts "     |     |"
  puts "  #{brd[1]}  |  #{brd[2]}  |  #{brd[3]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{brd[4]}  |  #{brd[5]}  |  #{brd[6]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{brd[7]}  |  #{brd[8]}  |  #{brd[9]}"
  puts "     |     |"
  puts ""
end
# rubocop:enable Metrics/AbcSize

def initialize_board
  new_board = {}
  (1..9).each { |num| new_board[num] = INITIAL_MARKER }
  new_board
end #=> {1 => ' ', 2 => ' ', 3 => ' '...}

def empty_squares(brd) # inspecting the board
  brd.keys.select { |num| brd[num] == INITIAL_MARKER } # returns an array
end


def joinor(array, punctuation = ',', conjunction = 'or')
  string_output = ''
  array.map do |num|
    if num == array[-1] 
      string_output << conjunction + " #{num.to_s}"
    elsif array.length == 2
      string_output << "#{num} "
    else
      string_output << "#{num.to_s}" + ', '
    end
  end
  string_output
end

def player_passes_piece!(brd, current_player) # modifying the board
  square = ''
  loop do
    prompt "Choose a square (#{joinor(empty_squares(brd))}):"
    square = gets.chomp.to_i
    break if empty_squares(brd).include?(square)
    prompt "Sorry, that's not a valid choice."
  end

  brd[square] = current_player
end

# def computer_places_piece!(brd)
#   square = empty_squares(brd).sample
#   brd[square] = COMPUTER_MARKER
# end

def at_risk_square(line, brd, marker)
  if brd.values_at(*line).count(marker) == 2
    brd.select{|k,v| line.include?(k) && v == INITIAL_MARKER }.keys.first
    # `select` invoked on board and is passed the two parameters, k and v, 
    # the `select` method is passed the result of the block where the `include?` method is invoked on the method parameter `line`
  end
end

def computer_place_piece!(brd)
  square = nil

  #offense
  WINNING_LINES.each do |line|
    square = at_risk_square(line, brd, COMPUTER_MARKER) #=> number
    break if square
  end

  #defense
  if square == nil
    WINNING_LINES.each do |line|
      square = at_risk_square(line, brd, PLAYER_MARKER) #=> number
      break if square
    end
  end

  if square == nil
    brd[5] == INITIAL_MARKER ? square = 5 : square = empty_squares(brd).sample
  end

  brd[square] = COMPUTER_MARKER
end


def board_full?(brd)
  empty_squares(brd).empty?
end

def someone_won?(brd)
  !!detect_winner(brd) # bangs turn this into a boolean
end

def detect_winner(brd)
  WINNING_LINES.each do |line|
    # if brd[line[0]] == PLAYER_MARKER &&
    #    brd[line[1]] == PLAYER_MARKER &&
    #    brd[line[2]] == PLAYER_MARKER
    #   return 'Player'
    # elsif brd[line[0]] == COMPUTER_MARKER &&
    #       brd[line[1]] == COMPUTER_MARKER &&
    #       brd[line[2]] == COMPUTER_MARKER
    #   return 'Computer'
    # end
    if brd.values_at(*line).count(PLAYER_MARKER) == 3
      return 'Player'
    elsif brd.values_at(*line).count(COMPUTER_MARKER) == 3
      return 'Computer'
    end
  end
  nil
end

score = {"Player" => 0, "Computer" => 0}

def round_count(string, score)
  if string == 'Player'
    score["Player"] += 1
  end
  if string == 'Computer'
    score["Computer"] += 1
  end
  if score["Player"] == 5 || score["Computer"] == 5
      puts "Congratulations to #{string}!".center(50)
      puts "The #{string} has reached 5 wins!".center(50)
      puts "#{string} is the crown champion!".center(50)
      puts "| *    *    * |".center(50)
      puts "|**   ***   **|".center(50)
      puts "|*************|".center(50)
      puts "|*************|".center(50)
  end
end

def which_player_goes
  prompt "Do you want to go first? (y/n)"
  answer = gets.chomp
  answer
end

def computer_which_player_goes
  string = ['y', 'n'].sample
  if string.downcase == 'y' || string.downcase == 'yes'
    player = PLAYER_MARKER
  else
    player = COMPUTER_MARKER
  end
  player
end

player = ''

def alternate_player(player)
  player == PLAYER_MARKER ? COMPUTER_MARKER : PLAYER_MARKER
end

def place_piece!(brd, current_player)
  if current_player == PLAYER_MARKER
    player_passes_piece!(brd)
  else
    computer_place_piece!(brd)
  end
end

# What does player point to or which argument is passed in to the player parameter
# to n

def main(brd, player)
  loop do
    display_board(brd)
    place_piece!(brd, player)
    current_player = alternate_player(player)
    break if someone_won?(brd) || board_full?(brd)
  end

end

loop do
  board = initialize_board
  input = computer_which_player_goes

  display_board(board)
  main(input, board)


  display_board(board)

  if someone_won?(board)
    prompt "#{detect_winner(board)} won!"
  else
    prompt "It's a tie!"
  end

  round_count(detect_winner(board), score)
  
  prompt "The score is Player: #{score["Player"]} and Computer: #{score["Computer"]}."
  prompt "Play again? (y or n) The first to 5 games wins!"
  answer = gets.chomp
  break unless answer.downcase == 'y' || answer.downcase == 'yes'
end

prompt "Thanks for playing Tic Tac Toe! Good bye!"