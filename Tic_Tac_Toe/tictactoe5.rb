require "pry"

INITIAL_MARKER = " "
PLAYER_MARKER = "X"
COMPUTER_MARKER = "O"

WINNING_LINES =
  [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # rows # cols
    [[1, 5, 9], [3, 5, 7]] # diagonals

def prompt(msg)
  puts "=> #{msg}"
end

# rubocop:disable Metrics/AbcSize
def display_board(brd)
  system "clear"
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

def joinor(array, punctuation = ",", conjunction = "or")
  string_output = ""
  array.map do |num|
    if num == array[-1]
      string_output << conjunction + " #{num}"
    elsif array.length == 2
      string_output << num.to_s
    else
      string_output << num.to_s + ", "
    end
  end
  string_output
end

def player_passes_piece!(brd) # modifying the board
  square = ""
  loop do
    prompt "Choose a square (#{joinor(empty_squares(brd))}):"
    square = gets.chomp.to_i
    break if empty_squares(brd).include?(square)
    prompt "Sorry, that's not a valid choice."
  end

  brd[square] = PLAYER_MARKER
end

def computer_place_piece!(brd)
  square = nil

  # offense
  WINNING_LINES.each do |line|
    square = at_risk_square(line, brd, COMPUTER_MARKER) #=> number
    break if square
  end

  # defense
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

def at_risk_square(line, brd, marker)
  if brd.values_at(*line).count(marker) == 2
    brd.select { |k, v| line.include?(k) && v == INITIAL_MARKER }.keys.first
  end
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
      return "Player"
    elsif brd.values_at(*line).count(COMPUTER_MARKER) == 3
      return "Computer"
    end
  end
  nil
end

score = { "Player" => 0, "Computer" => 0 }

def round_count(string, score)
  score["Player"] += 1 if string == "Player"
  score["Computer"] += 1 if string == "Computer"
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

# ASk the player who goes first.
# Then call the correct place piece method based off the user.

# Input: User choice
# Ouptut: Symbol
def who_goes_first
  prompt "Who do you want to go first? (computer/player/random)"
  loop do
    answer = gets.chomp
    if answer.downcase == "player"
      return :player
    elsif answer.downcase == "computer"
      return :computer
    elsif answer.downcase == "random"
      return %i(computer player).sample
    else
      puts "Please enter player, computer, or random."
    end
  end
end

# Input: :player, :choice
def take_turn(user_choice, board)
  if user_choice == :player
    loop do
      display_board(board)

      player_passes_piece!(board)
      break if someone_won?(board) || board_full?(board)

      computer_place_piece!(board)
      break if someone_won?(board) || board_full?(board)
    end
  else
    loop do
      computer_place_piece!(board)
      break if someone_won?(board) || board_full?(board)

      display_board(board)

      player_passes_piece!(board)
      break if someone_won?(board) || board_full?(board)
    end
  end
end

loop do
  current_player = who_goes_first
  board = initialize_board

  display_board(board)
  take_turn(current_player, board)

  if someone_won?(board)
    prompt "#{detect_winner(board)} won!"
  else
    prompt "It's a tie!"
  end

  round_count(detect_winner(board), score)

  prompt "Play again? (y or n) The first to 5 games wins!"
  answer = gets.chomp
  break unless answer.downcase == "y" || answer.downcase == "yes"
end

prompt "Thanks for playing Tic Tac Toe! Good bye!"
