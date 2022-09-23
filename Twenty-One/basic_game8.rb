require "set"

ROUNDS_TO_WIN = 5

def prompt(msg)
  puts ">> #{msg}"
end

def welcome_message
  system 'clear'
  prompt "You have begun a game of 21!"
  prompt "1st player to 5 games wins!"
  prompt "Press Enter to continue..."
  gets.chomp
  
end


def initialize_deck()
  deck = {}

  card_value = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10]
  card_type = %w[A 2 3 4 5 6 7 8 9 10 J Q K]
  suits = %w[H D S C]

  suits.each do |suit|
    card_type.each_with_index do |card, idx| # generating key-value pairs
      deck[suit + card] = card_value[idx]
    end
  end
  deck
end

def total(hand)
  hand_total = 0
  has_ace = false
  hand.each do |card_key| # ['HA', 1]
    has_ace = true if DECK[card_key] == 1
    hand_total += DECK[card_key]
  end
  hand_total += 10 if has_ace && hand_total + 10 <= 21
  hand_total
end

def deal_hands!(number_of_cards, hand, used_cards) # start of game is 2
  system 'clear'
  number_of_cards.times do
    card = DECK.to_a.sample
    card = DECK.to_a.sample while used_cards.include?(card[0])
    hand << card[0]
    used_cards.add(card[0])
  end
end # returns an array for hand with new card(s)

def busted?(score)
  score > 21
end

def game_over?(player_hand, dealer_hand, both_turns_completed = false)
  game_over = false

  player_hand_score = total(player_hand)
  dealer_hand_score = total(dealer_hand)

  if player_hand_score == 21 || busted?(dealer_hand_score)
    system 'clear'
    puts "Player wins! Player's score is #{player_hand_score}."
    game_over = true
    
  elsif dealer_hand_score == 21 || busted?(player_hand_score)
    system 'clear'
    puts "Dealer wins! Dealer's score is #{dealer_hand_score}."
    game_over = true

  elsif both_turns_completed
    if player_hand_score < dealer_hand_score
      puts "Dealer wins!! The dealer's score is #{dealer_hand_score}."
    else
      puts "Player wins!! The player's score is #{player_hand_score}."
    end
    game_over = true
  end

  if game_over
    puts "Dealer: #{dealer_hand}"
    puts "Player: #{player_hand}"
  end

  game_over # returns true/false value
end

def game_over_computer?(player_hand, dealer_hand)
  game_over = false

  player_hand_score = total(player_hand)
  dealer_hand_score = total(dealer_hand)

  if player_hand_score == dealer_hand_score
    game_over = true
    puts game_over
  elsif player_hand_score == 21 || busted?(dealer_hand_score)
    puts "Player wins! Player's score is #{player_hand_score}."
    game_over = true
  elsif dealer_hand_score == 21 || busted?(player_hand_score)
    puts "Dealer wins! Dealer's score is #{dealer_hand_score}."
    game_over = true
  end
  display_hand(player_hand, dealer_hand) if game_over

  game_over # returns true/false value
end

def play_again
  print "Would you like to play again? (y/n)"
  answer = gets.chomp
  return true if answer.downcase == "y" || answer.downcase == "yes"
  false
end

def display_hand(player_hand, dealer_hand)
  puts "Player hand is: #{player_hand}"
  puts "Dealer hand is: #{dealer_hand}"
end

# what happens if each player gets 21 on the first deal?

def hit_or_stay(player_hand, dealer_hand, used_cards)
  puts "Your hand is: #{player_hand}. Your score is #{total(player_hand)}."
  loop do
    puts "hit or stay?"
    answer = gets.chomp
    if answer.downcase == "hit" || answer.downcase == "h"
      deal_hands!(1, player_hand, used_cards)
      puts "Your hand is: #{player_hand}. Your score is #{total(player_hand)}."
      return if game_over?(player_hand, dealer_hand)
    end

    if answer.downcase == "stay" || answer.downcase == "s"
      puts "Your hand is: #{player_hand}. Your score is #{total(player_hand)}."
      return
    end
  end
end

def computer_hit_or_stay(dealer_hand, player_hand, used_cards)
  return p ("Game over.") if game_over?(player_hand, dealer_hand)

  puts "Dealer's hand is: #{dealer_hand}. Dealer's score is #{total(dealer_hand)}."
  while total(dealer_hand) < total(player_hand) && total(dealer_hand) <= 17
    deal_hands!(1, dealer_hand, used_cards)
    puts "Dealer's hand is: #{dealer_hand}. Dealer's score is #{total(dealer_hand)}."
    return if game_over?(player_hand, dealer_hand, true)
  end
end

# Tyler Frye's awesome method
def game_winner?(player_wins, dealer_wins)
  player_wins >= ROUNDS_TO_WIN || dealer_wins >= ROUNDS_TO_WIN
end

# 21 -

DECK = initialize_deck

def deal_hands_to_both_players(player_hand, dealer_hand, used_cards) 
  deal_hands!(2, player_hand, used_cards)
  deal_hands!(2, dealer_hand, used_cards)
  display_hand(player_hand, dealer_hand)
end 


#game loop
def main
  # To be implemented 
  # player_wins = 0
  # dealer_wins = 0
  welcome_message

  loop do
    used_cards = Set[] 
    player_hand = []
    dealer_hand = []

    deal_hands_to_both_players(player_hand, dealer_hand, used_cards) 

    player_hand_score = total(player_hand)
    dealer_hand_score = total(dealer_hand)
    
    hit_or_stay(player_hand, dealer_hand, used_cards)
      # [1, 10], 11 
      # [1,10, 10], 21 
      # If the player busts, then what happens? 

      # Player: 17
    computer_hit_or_stay(dealer_hand, player_hand, used_cards)
      # 
      # Dealer's Score: 

    break if !play_again
  end
end

main
