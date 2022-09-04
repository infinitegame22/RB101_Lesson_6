SUITS = ['Hearts', 'Diamonds', 'Clubs', 'Spades']
SUIT_MEMBERS = [*('2'..'10'), 'Jack', 'Queen', 'King', 'Ace']

WINNING_SUM = 21
CASINO_SHUFFLE = 7

CARD_VALUES = {
  '2' => 2, '3' => 3, '4' => 4, '5' => 5, '6' => 6, '7' => 7, '8' => 8,
  '9' => 9, '10' => 10, 'Jack' => 10, 'Queen' => 10, 'King' => 10
}

# Methods
def prompt(message)
  puts "=> #{message}"
end

def hand_builder(hand)
  card_strings = ["The #{hand[0][1]} of #{hand[0][0]}"]

  i = 1
  while i < hand.size
    card_strings << "the #{hand[i][1]} of #{hand[i][0]}"
    i += 1
  end

  joiner(card_strings)
end

def joiner(hand)
  case hand.size
  when 0 then ''
  when 1 then hand.first.last
  when 2 then hand.map { |card| card }.join(" and ")
  else
    hand.slice(0, hand.size - 1).map { |card| card }
        .join(", ") + ", and #{hand[-1]}"
  end
end

def initialize_deck
  deck = SUITS.each_with_object([]) do |suit, arr|
    SUIT_MEMBERS.each do |value|
      arr << [suit, value]
    end
  end

  shuffle_deck!(deck)

  deck
end

def deal_hand(deck)
  hand = [deck[-1], deck[-2]]
  [hand, deck.slice(0, deck.size - 2)]
end

def shuffle_deck!(deck)
  CASINO_SHUFFLE.times { deck.shuffle! }
end

def initialize_ace_values(hand)
  hand.select { |card| card[1] == 'Ace' }.map { |_| 11 }
end

def get_base_value(hand)
  hand.reject { |card| card[1] == 'Ace' }
      .map { |card| CARD_VALUES[card[1]] }.sum
end

def get_score(hand)
  ace_values = initialize_ace_values(hand)
  base_value = get_base_value(hand)

  i = 0
  while (base_value + ace_values.sum > WINNING_SUM) && (i < ace_values.size)
    ace_values[i] = 1
    i += 1
  end

  base_value + ace_values.sum
end

def display_player_hand(hand)
  prompt "You have: #{hand_builder(hand)}"
end

def display_dealer_hand(hand)
  prompt "Dealer has: The #{hand.first.last} of #{hand.first.first} "\
    "and an unknown card"
end

def display_hands(player_hand, dealer_hand)
  system('clear')
  display_dealer_hand(dealer_hand)
  display_player_hand(player_hand)
  puts
end

def hit_or_stay
  prompt "Hit or stay?"

  choice = ''
  valid_choices = ['hit', 'h', 'stay', 's']
  loop do
    choice = gets.chomp.downcase
    break if valid_choices.include?(choice)
    prompt "That is not a valid choice."
  end

  choice[0]
end

def deal_card(hand, deck)
  hand += [deck[-1]]
  [hand, deck.slice(0, deck.size - 1)]
end

def bust?(score)
  !!(score > WINNING_SUM)
end

def dealer_plays(dealer_hand, deck)
  loop do
    if get_score(dealer_hand) < 17
      dealer_hand, deck = deal_card(dealer_hand, deck)
      prompt "The dealer hits..."
      puts
      system('sleep 1.3')
    else
      break
    end
  end

  [dealer_hand, deck]
end

def display_score(player_score, dealer_score)
  prompt "Dealer has: #{dealer_score}"
  prompt "You have: #{player_score}"
  puts
end

def busted(player_hand, dealer_hand, player_score, dealer_score)
  system('clear')
  display_final_hands(player_hand, dealer_hand)
  display_score(player_score, dealer_score)

  if bust?(player_score)
    prompt "You're bust!"
    prompt "The dealer wins!"
  elsif bust?(dealer_score)
    prompt "The dealer is bust!"
    prompt "You win!"
  end
end

def display_final_hands(player_hand, dealer_hand)
  prompt "Dealer has: #{hand_builder(dealer_hand)}"
  display_player_hand(player_hand)
  puts
end

def declare_winner(player_hand, dealer_hand,
                   player_score, dealer_score)
  system('clear')
  display_final_hands(player_hand, dealer_hand)
  display_score(player_score, dealer_score)

  if player_score > dealer_score
    prompt "You win!"
  elsif dealer_score > player_score
    prompt "The dealer wins!"
  else
    prompt "It's a tie!"
  end
end

def play_again?
  puts
  prompt "Play again (y or n)?"
  again = gets.chomp.downcase
  !!again.start_with?('y')
end

def say_hello
  system('clear')
  puts "*** Welcome to Twenty-One! ***"
  system('sleep 1.6')
end

def say_goodbye
  system('clear')
  puts "*** Thanks for playing Twenty-One! Good bye! ***"
  puts
end

def winner(player_score, dealer_score)
  if player_score > WINNING_SUM
    'dealer'
  elsif dealer_score > WINNING_SUM || player_score > dealer_score
    'player'
  elsif dealer_score > player_score
    'dealer'
  else
    'tie'
  end
end

def hand_or_hands(score)
  if score == 1
    "#{score} hand"
  else
    "#{score} hands"
  end
end

def declare_game_winner(player_score, dealer_score)
  puts
  prompt "At the end of that game,"
  prompt "The player won " + hand_or_hands(player_score)
  prompt "The dealer won " + hand_or_hands(dealer_score)
  puts
  if player_score > dealer_score
    prompt "You won the game!"
  else
    prompt "The dealer won the game!"
  end
end

say_hello

player_game_score = 0
dealer_game_score = 0

# Main game loop
loop do
  # Deal starting hands
  deck = initialize_deck
  dealer_hand, deck = deal_hand(deck)
  player_hand, deck = deal_hand(deck)
  dealer_partial_score = get_score([dealer_hand.first])
  player_score = nil

  # Player turn loop
  loop do
    player_score = get_score(player_hand)
    display_hands(player_hand, dealer_hand)
    display_score(player_score, "#{dealer_partial_score} + ?")

    if hit_or_stay == 'h'
      player_hand, deck = deal_card(player_hand, deck)
      player_score = get_score(player_hand)
    else
      break
    end

    break if bust?(player_score)
  end

  display_hands(player_hand, dealer_hand)
  display_score(player_score, "#{dealer_partial_score} + ?")

  # Dealer turn, unless the player is already bust
  dealer_hand, deck = dealer_plays(dealer_hand, deck) unless bust?(player_score)
  dealer_score = get_score(dealer_hand)

  # Determine who won
  if bust?(player_score) || bust?(dealer_score)
    busted(player_hand, dealer_hand, player_score, dealer_score)
  else
    declare_winner(player_hand, dealer_hand,
                   player_score, dealer_score)
  end

  if winner(player_score, dealer_score) == 'player'
    player_game_score += 1
  elsif winner(player_score, dealer_score) == 'dealer'
    dealer_game_score += 1
  end

  if player_game_score == 5 || dealer_game_score == 5
    declare_game_winner(player_game_score, dealer_game_score)
    player_game_score = 0
    dealer_game_score = 0
  end

  break unless play_again?
end

say_goodbye