## Card Data ##
SUITS = %w(S H D C)
VALUES = %w(A 2 3 4 5 6 7 8 9 10 J Q K)
CARD_BACK = "\u{1F0A0}"

## Rules ##
STARTING_CARDS = 2

MAX_HAND_VALUE = 21 # max value a hand can have before 'busting'
DEALER_MAX = 17 # max value dealer can have before 'staying'

ROUNDS_TO_WIN = 5

ACE_MAX = 11 # high value for an Ace
ACE_MIN = 1 # low value for an Ace
ACE_DIFFERENCE = ACE_MAX - ACE_MIN # amount to remove when adjusting ace value

FACE_CARD_VALUE = 10

## Input Options ##
TURN_INPUTS = %w(s h) # stay, hit - options for turn inputs
YES_OR_NO = %w(y n) # yes, no - options when asked to play again

## Sleep Times ##
PAUSE_TIME = 2 # wait time between UI updates
DRAW_TIME = 1 # time between displaying individual card
ELIPSIS_TIME = 0.5 # wait time betwen . . .

def prompt(msg)
  puts ">> #{msg}"
end

# rubocop:disable Layout/LineLength
def display_welcome
  system 'clear'
  puts "
████████╗██╗    ██╗███████╗███╗   ██╗████████╗██╗   ██╗      ██████╗ ███╗   ██╗███████╗
╚══██╔══╝██║    ██║██╔════╝████╗  ██║╚══██╔══╝╚██╗ ██╔╝     ██╔═══██╗████╗  ██║██╔════╝
   ██║   ██║ █╗ ██║█████╗  ██╔██╗ ██║   ██║    ╚████╔╝█████╗██║   ██║██╔██╗ ██║█████╗
   ██║   ██║███╗██║██╔══╝  ██║╚██╗██║   ██║     ╚██╔╝ ╚════╝██║   ██║██║╚██╗██║██╔══╝
   ██║   ╚███╔███╔╝███████╗██║ ╚████║   ██║      ██║        ╚██████╔╝██║ ╚████║███████╗
   ╚═╝    ╚══╝╚══╝ ╚══════╝╚═╝  ╚═══╝   ╚═╝      ╚═╝         ╚═════╝ ╚═╝  ╚═══╝╚══════╝
 "

  prompt "Welcome to Twenty-One!"
  prompt "The player closest to 21 without going over wins the round!"
  prompt "First to 5 rounds wins!"
  prompt "[H]it to draw another card || [S]tay to keep your hand as is"
  prompt "Press enter to continue..."
  gets.chomp
end
# rubocop:enable Layout/LineLength

def initialize_deck
  deck = SUITS.product(VALUES)
  unicode_deck = initialize_unicode_deck

  deck.map!.with_index do |card, idx|
    card << unicode_deck[idx]
  end

  deck.shuffle
end

# create an array of unicode characters that represent
# a deck of cards in the same order as above
def initialize_unicode_deck
  unicode_cards = []
  suit_range = [*('A'..'D')]
  value_range = [*('1'..'9')] + ['A', 'B', 'D', 'E']
  suit_range.each do |suit_char|
    value_range.each do |value_char|
      unicode_cards << ["1F0#{suit_char}#{value_char}".hex].pack("U")
    end
  end
  unicode_cards
end

def valid_input?(answer, options)
  options.include?(answer.chr.downcase) ? true : false
end

def busted?(hand)
  calculate_hand_total(hand) > MAX_HAND_VALUE
end

def draw_card(deck)
  deck.pop
end

def calculate_hand_total(hand)
  hand_values = hand.map { |card| card[1] }

  hand_total = 0
  hand_values.each do |card|
    # Refactored this way because rubocop was
    # whining when I used hand_total = 11/10/card.to_i
    # in each conditional
    hand_total += if card == 'A'
                    ACE_MAX
                  elsif card.to_i == 0 # Face card, not Ace
                    FACE_CARD_VALUE
                  else # Standard value card
                    card.to_i
                  end
  end

  # Adjust ace values to the minimum value, one at a time
  # if total hand value exceeds MAX_HAND_VALUE
  num_aces = hand_values.select { |card| card == 'A' }.count
  num_aces.times { hand_total -= ACE_DIFFERENCE if hand_total > MAX_HAND_VALUE }

  hand_total
end

def player_turn!(deck, player_hand, dealer_hand)
  loop do
    display_totals(player_hand)
    return if busted?(player_hand)

    prompt "[H]it or [S]tay?"
    answer = gets.chomp
    unless valid_input?(answer, TURN_INPUTS)
      prompt "Please choose a valid move. [H] or [S]"
      next
    end

    # trying to avoid hardcoding values inside methods
    # is this okay? good?
    break if answer.downcase.start_with?(TURN_INPUTS[0])
    hit!(deck, player_hand)
    display_both_hands(player_hand, dealer_hand)
  end

  pause_text("You chose to Stay")
end

def dealer_turn!(deck, player_hand, dealer_hand)
  display_both_hands(player_hand, dealer_hand, false)
  display_totals(player_hand, dealer_hand)

  loop do
    break if calculate_hand_total(dealer_hand) >= DEALER_MAX
    sleep(PAUSE_TIME) # give a little time for player to read
    hit!(deck, dealer_hand)
    display_both_hands(player_hand, dealer_hand, false)
    display_totals(player_hand, dealer_hand)
  end
end

def display_totals(player_hand, dealer_hand=[])
  prompt "Your total:   #{calculate_hand_total(player_hand)}"
  unless dealer_hand.empty?
    prompt "Dealer total: #{calculate_hand_total(dealer_hand)}"
  end
end

def hit!(deck, hand)
  hand << draw_card(deck)
  pause_text("Hitting")
end

def pause_text(text)
  print ">> #{text}"
  print_elipsis(ELIPSIS_TIME)
end

def print_elipsis(time)
  sleep(time)
  3.times do
    print "."
    sleep(time)
  end
end

def initialize_starting_hands!(deck, player_hand, dealer_hand)
  STARTING_CARDS.times do
    player_hand << draw_card(deck)
    dealer_hand << draw_card(deck)
  end
end

def display_starting_hands(player_hand, dealer_hand)
  system 'clear'
  print "\nDealer's Hand: "
  display_hand_individually(dealer_hand, false)

  print "Player's Hand: "
  display_hand_individually(player_hand)
end

def display_hand_individually(hand, player=true)
  # Display a hand one card at a time, with a rest inbetween
  # First card will be 'face down' if player = false
  # Could probably code this into the game loop and use display_hand
  # as we're initializing each card into each hand, but this works
  # and I'm too tired to refactor that xD
  card_graphics = hand.map { |card| card[2] }
  (hand.size).times do |n|
    sleep(DRAW_TIME)
    if n == 0 && !player
      print "#{CARD_BACK} "
    else
      print "#{card_graphics[n]} "
    end
  end
  sleep(DRAW_TIME)
  puts "\n\n"
end

def display_both_hands(player_hand, dealer_hand, player_turn=true)
  system 'clear'
  print "\nDealer's Hand: "
  # hide first card if it's still player's turn
  display_hand(dealer_hand, player_turn)
  print "Player's Hand: "
  display_hand(player_hand)
end

def display_hand(hand, hide_first=false)
  # keep dealer first card face down if it's still player turn
  card_graphics = hand.map { |card| card[2] }
  card_graphics.each_with_index do |card, idx|
    if hide_first && idx == 0
      print "#{CARD_BACK} "
      next
    end
    print "#{card} "
  end
  print "\n\n"
end

def detect_result(player_hand, dealer_hand)
  player_total = calculate_hand_total(player_hand)
  dealer_total = calculate_hand_total(dealer_hand)

  if player_total > MAX_HAND_VALUE
    :player_busted
  elsif dealer_total > MAX_HAND_VALUE
    :dealer_busted
  elsif player_total > dealer_total
    :player_win
  elsif player_total < dealer_total
    :dealer_win
  else
    :tie
  end
end

def display_result(result)
  sleep(PAUSE_TIME)
  case result
  when :player_busted
    prompt "You busted! Dealer wins!"
  when :dealer_busted
    prompt "Dealer busted! You win!"
  when :player_win
    prompt "You win!"
  when :dealer_win
    prompt "Dealer wins!"
  when :tie
    prompt "It's a tie!"
  end
end

def play_again?
  sleep(PAUSE_TIME)
  print "\n"
  answer = ''
  loop do
    prompt "Would you like to play again? [Y]es or [N]o"
    answer = gets.chomp
    unless valid_input?(answer, YES_OR_NO)
      prompt "Please choose a valid selection. [Y] or [N]"
      next
    end
    break
  end
  # trying to avoid hardcoding values inside methods
  # is this okay? good?
  return true if answer.chr.downcase == YES_OR_NO[0] # 'y'
  false
end

def process_win(result, player_wins, dealer_wins)
  if result == :player_win || result == :dealer_busted
    player_wins += 1
  elsif result == :dealer_win || result == :player_busted
    dealer_wins += 1
  end
  [player_wins, dealer_wins]
end

def game_winner?(player_wins, dealer_wins)
  player_wins >= ROUNDS_TO_WIN || dealer_wins >= ROUNDS_TO_WIN
end

def end_round(player_wins, dealer_wins)
  sleep(PAUSE_TIME)
  print "\n"
  puts "Player Wins: #{player_wins}"
  puts "Dealer Wins: #{dealer_wins}"
end

def end_game(player_wins)
  sleep(PAUSE_TIME)
  winner_str = if player_wins >= ROUNDS_TO_WIN
                 'Player'
               else
                 'Dealer'
               end
  prompt "#{winner_str} has won #{ROUNDS_TO_WIN} rounds to take it all!"
end

def display_goodbye
  print "\n"
  prompt "Thanks for playing Twenty-One!"
  prompt "Goodbye."
end

# main game loop
loop do
  player_wins = 0
  dealer_wins = 0

  quit_mid_set = false

  display_welcome
  # round loop
  loop do
    deck = initialize_deck
    player_hand = []
    dealer_hand = []

    initialize_starting_hands!(deck, player_hand, dealer_hand)
    display_starting_hands(player_hand, dealer_hand)
    player_turn!(deck, player_hand, dealer_hand)
    unless busted?(player_hand)
      dealer_turn!(deck, player_hand, dealer_hand)
    end

    result = detect_result(player_hand, dealer_hand)
    display_result(result)
    player_wins, dealer_wins = process_win(result, player_wins, dealer_wins)

    end_round(player_wins, dealer_wins)
    if game_winner?(player_wins, dealer_wins)
      end_game(player_wins)
      break
    end

    next if play_again?
    quit_mid_set = true
    break
  end

  break if quit_mid_set
  break unless play_again?
end

display_goodbye