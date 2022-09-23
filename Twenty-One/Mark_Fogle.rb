require 'yaml'

MESSAGES_TO_DISPLAY = YAML.load_file("twenty_one.yml")

FILES = ["twenty_one.txt", "general_info.txt",
         "rules_for_twenty_one.txt", "values_of_cards.txt"]

SUITS = [:diamonds, :spades, :hearts, :clubs]

SUIT_AND_ICON = { diamonds: '◆', hearts: '♥', clubs: '♣', spades: '♠' }

J_K_Q = %w(Jack King Queen)

def display_message(file, message)
  file[message]
end

def flashes_message(msg)
  "\e[5m#{msg}\e[0m"
end

def deck_of_cards
  { diamonds: %w(Ace 2 3 4 5 6 7 8 9 10 Jack Queen King),
    hearts: %w(Ace 2 3 4 5 6 7 8 9 10 Jack Queen King),
    clubs: %w(Ace 2 3 4 5 6 7 8 9 10 Jack Queen King),
    spades: %w(Ace 2 3 4 5 6 7 8 9 10 Jack Queen King) }
end

def empty_arr
  []
end

def empty_string
  ''
end

def prompt(message)
  puts "=> #{message}"
end

def prints_blank_lines
  3.times { puts ' ' }
end

def hit_enter
  e = gets.chomp
  loop do
    break if e == ''
    prompt(display_message(MESSAGES_TO_DISPLAY, 'enter_again'))
    e = gets.chomp
  end
  e
end

def flow
  counter = 0
  loop do
    puts File.readlines(FILES[counter])
    prints_blank_lines
    prompt("Please press the #{flashes_message('enter')} key to continue.")
    hit_enter
    sleep_and_clear_game
    counter += 1
    break if counter == 3
  end
end

def sleep_and_clear_game
  sleep 3
  system('clear')
end

def delete_initial_cards_from_hand!(hand, deck)
  hand.each do |subarr|
    subarr.each_index do |_|
      deck[subarr[0]].delete_if { |item| item == subarr[1] }
    end
  end
end

def delete_drawn_card_from_deck!(hand, deck)
  suit = hand[-1][0]
  card = hand[-1][1]
  deck[suit].delete_if { |c| c == card }
end

def add_card_to_hand!(hand, deck)
  suit = SUITS.sample
  card = deck[suit].sample
  hand << [suit, card]
end

def generate_random_hand(deck_copy)
  suit = SUITS.sample
  suits_value = deck_copy[suit].sample
  [suit, suits_value]
end

def initial_two_cards!(hand, deck)
  while hand.size < 2
    hand << generate_random_hand(deck)
  end
end

def arr_of_values_but_no_suits!(hand, values)
  hand.each do |subarr|
    values << subarr[1]
  end
end

def choose_icon_for_suit(suit)
  case suit
  when :hearts
    SUIT_AND_ICON[:hearts]
  when :diamonds
    SUIT_AND_ICON[:diamonds]
  when :clubs
    SUIT_AND_ICON[:clubs]
  else
    SUIT_AND_ICON[:spades]
  end
end

def say_player_hand(hand)
  prompt("Your hand is: ")
  hand.each do |subarr|
    zero_index = subarr[0]
    puts("#{subarr[1]} of #{zero_index} #{choose_icon_for_suit(zero_index)}")
  end
end

def says_both_hands(p_hand, d_hand)
  prompt("Your hand is: ")
  p_hand.each do |subarr|
    zero_index = subarr[0]
    puts("#{subarr[1]} of #{zero_index} #{choose_icon_for_suit(zero_index)}")
  end

  prints_blank_lines

  prompt("Dealer has: ")
  suit = d_hand[0][0]
  puts("#{d_hand[0][1]} of #{suit} #{choose_icon_for_suit(suit)}")
  puts("unknown card")
  prints_blank_lines
end

def say_dealer_hand(d_hand)
  prompt("Dealer has: ")
  suit = d_hand[0][0]
  puts("#{d_hand[0][1]} of #{suit} #{choose_icon_for_suit(suit)}")
  puts("unknown card")
end

def convert_to_ten_or_face_value!(values)
  values.map! do |card|
    if J_K_Q.member?(card)
      10
    else
      card.to_i
    end
  end
end

def one_ace_in_initial_hand!(values)
  values.map! do |card|
    if card == 'Ace'
      11
    else
      card
    end
  end
  convert_to_ten_or_face_value!(values)
end

def two_aces_in_initial_hand!(values)
  values.clear
  loop do
    values << 11
    values << 1
    break
  end
end

def string_values_to_integers(values)
  if values.count('Ace') == 2
    two_aces_in_initial_hand!(values)
  elsif values.count('Ace') == 1
    one_ace_in_initial_hand!(values)
  else
    convert_to_ten_or_face_value!(values)
  end
end

def sum_of_hand(hand, values) # i need to do it here.. ma
  arr_of_values_but_no_suits!(hand, values)
  string_values_to_integers(values)
  values.inject(:+)
end

def determine_last_card_value!(hand, arr)
  arr << if J_K_Q.member?(hand.last[1])
           10
         elsif hand.last[1] == 'Ace'
           arr.inject(:+) + 11 > 21 ? 1 : 11
         else
           hand.last[1].to_i
         end
end

def h_or_s
  input = gets.chomp.downcase
  loop do
    break if input == 's' || input == 'h'
    prompt(display_message(MESSAGES_TO_DISPLAY, 'h_or_s'))
    input = gets.chomp.downcase
  end
  input
end

def player_made_choice(choice)
  case choice
  when 'h'
    'hit'
  else
    'stay'
  end
end

def two_paths(choice, hand, values, deck)
  if choice == 'hit'
    hits!(hand, deck)
    determine_last_card_value!(hand, values)
  else
    prompt(display_message(MESSAGES_TO_DISPLAY, 'player_stays'))
  end
end

def hits!(hand, deck)
  add_card_to_hand!(hand, deck)
end

def bust?(total)
  total > 21
end

def says_dealer_busted
  prompt(display_message(MESSAGES_TO_DISPLAY, 'dealer_busts'))
end

def dealer_decides_move(sum)
  sum <= 17 ? 'h' : 's'
end

def play_again
  y_or_n = ''
  prompt("Enter \'y\' or \'n\'.")
  loop do
    y_or_n = gets.chomp.downcase
    return y_or_n if y_or_n == 'n' || y_or_n == 'y'
    prompt(display_message(MESSAGES_TO_DISPLAY, 'n_or_y'))
  end
end

def did_player_and_dealer_stay?(p_move, d_move)
  p_move == 's' && d_move == 's'
end

def compare_hands(player, dealer)
  if player > dealer
    prompt(display_message(MESSAGES_TO_DISPLAY, 'players_hand_wins'))
  elsif player == dealer
    prompt(display_message(MESSAGES_TO_DISPLAY, 'tie'))
  else
    prompt(display_message(MESSAGES_TO_DISPLAY, 'dealers_hand_wins'))
  end
end

def clears_everything!(*args)
  args.map!(&:clear)
end

deck = deck_of_cards

players_hand = empty_arr
dealers_hand = empty_arr
p_card_values = empty_arr
d_card_values = empty_arr

y_or_n = empty_string
dealer_decision = empty_string
player_decision = empty_string
dealer_absolute_total = empty_string
player_absolute_total = empty_string

# flow

loop do
  initial_two_cards!(players_hand, deck)
  delete_initial_cards_from_hand!(players_hand, deck)
  say_player_hand(players_hand)
  player_absolute_total = sum_of_hand(players_hand, p_card_values)
  2.times { puts '' }
  prompt("Your current hand's total is: #{player_absolute_total}")

  initial_two_cards!(dealers_hand, deck)
  delete_initial_cards_from_hand!(dealers_hand, deck)
  prints_blank_lines
  say_dealer_hand(dealers_hand)
  dealer_absolute_total = sum_of_hand(dealers_hand, d_card_values)

  prints_blank_lines
  prompt("Press #{flashes_message('enter')} to continue.")
  sleep_and_clear_game if hit_enter

  loop do
    says_both_hands(players_hand, dealers_hand)
    prompt(display_message(MESSAGES_TO_DISPLAY, 'h_or_s'))
    player_decision = h_or_s
    sleep_and_clear_game

    if player_decision == 'h'
      prompt(display_message(MESSAGES_TO_DISPLAY, 'player_hits'))
      sleep_and_clear_game
      hits!(players_hand, deck)
      delete_drawn_card_from_deck!(players_hand, deck)
      say_player_hand(players_hand)
      determine_last_card_value!(players_hand, p_card_values)
      player_absolute_total = p_card_values.inject(:+)
    else
      prompt(display_message(MESSAGES_TO_DISPLAY, 'player_stays'))
      sleep_and_clear_game
      break
    end
    prints_blank_lines
    prompt("Your current hand's total is: #{player_absolute_total}")
    break if bust?(player_absolute_total)
    sleep_and_clear_game
  end

  if bust?(player_absolute_total)
    prompt(display_message(MESSAGES_TO_DISPLAY, 'player_busts'))
    y_or_n = play_again
    if y_or_n == 'y'
      prompt(display_message(MESSAGES_TO_DISPLAY, 'continue_game'))
      clears_everything!(players_hand, dealers_hand,
                         p_card_values, d_card_values)

      deck = deck_of_cards
      sleep_and_clear_game
      next
    else
      prompt(display_message(MESSAGES_TO_DISPLAY, 'goodbye'))
      break
    end
  end

  prompt(display_message(MESSAGES_TO_DISPLAY, 'dealer_turn'))
  sleep_and_clear_game

  loop do
    dealer_decision = dealer_decides_move(dealer_absolute_total)
    if dealer_decision == 'h'
      prompt(display_message(MESSAGES_TO_DISPLAY, 'dealer_hits'))
      sleep_and_clear_game
      hits!(dealers_hand, deck)
      delete_drawn_card_from_deck!(dealers_hand, deck)
      determine_last_card_value!(dealers_hand, d_card_values)
      dealer_absolute_total = d_card_values.inject(:+)
      sleep_and_clear_game
    else
      prompt(display_message(MESSAGES_TO_DISPLAY, 'dealer_stays'))
      break
    end
    break if bust?(dealer_absolute_total)
  end

  sleep_and_clear_game

  says_dealer_busted if bust?(dealer_absolute_total)

  if did_player_and_dealer_stay?(player_decision, dealer_decision)
    prompt(display_message(MESSAGES_TO_DISPLAY, 'both_stay'))
    compare_hands(player_absolute_total, dealer_absolute_total)
  end

  sleep_and_clear_game

  loop do
    prompt(display_message(MESSAGES_TO_DISPLAY, 'play_again'))
    y_or_n = play_again
    if y_or_n == 'y'
      prompt(display_message(MESSAGES_TO_DISPLAY, 'continue_game'))
      clears_everything!(players_hand, dealers_hand,
                         p_card_values, d_card_values)
      deck = deck_of_cards
      sleep_and_clear_game
    else
      prompt(display_message(MESSAGES_TO_DISPLAY, 'goodbye'))
    end
    break
  end
  break if y_or_n == 'n'
end