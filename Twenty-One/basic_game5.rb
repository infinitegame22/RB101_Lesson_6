require "set"

def initialize_deck()
  deck = {}
  #two lists:
  card_value = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10]
  card_type = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K']
  suits = ['H', 'D', 'S', 'C']
  
  suits.each do |suit|
    card_type.each_with_index do |card, idx| # generating key-value pairs
      deck[suit + card] = card_value[idx]
    end
  end
  deck
end

def total(hand)# only calculating Ace
  # assume hand is an array of cards
  # represent each card with key from hash -> 'HA',
  # every string in the hand array will have a value in the set
  hand_total = 0
  has_ace = false
  hand.each do |card_key| # ['HA', 1]
    if DECK[card_key] == 1 
      has_ace = true
    end
    hand_total += DECK[card_key]
  end
  if has_ace && hand_total + 10 <= 21
    hand_total += 10
  end
  hand_total
end

# ace_count = 2
# loop do
#   if hand_total + 10 <= 21 && ace_count > 0
#     hand_total += 10
#     ace_count -= 1
#   end
#   break if hand_total + 10 > 21 || ace_count == 0
# end

# p total(['HA', 'S2']) == 13
# p total(['HA', 'S9', 'CA']) == 21
# p total(['DQ', 'S9']) == 19
  # since Ace is a 1 by default
# set of cards used already, check to see if we have used this already, 
# if we haven't then pass it to the player and put it into the set
# set is very efficient, set of keys -> auxiliary data structure to keep track of 
# cards being used.
# main game loop use a set

# def main
  
# end

# main
# loop do
#   puts "hit or stay?"
#   answer = gets.chomp
#   break if answer == 'stay' || busted?   # the busted? method is not shown
# end


# convert deck hash to an array
# sample, will return a key

# start of game - two cards to player and dealer

def deal_hands!(number_of_cards, hand, used_cards) # start of game is 2
  number_of_cards.times do
    card = DECK.to_a.sample
    while used_cards.include?(card[0])
      card = DECK.to_a.sample
    end
    hand << card[0]
    used_cards.add(card[0])
  end
end # returns an array for hand with new card(s)

# p deal_hands(2, [])
# p deal_hands(10, [])
def busted?(score)
  score > 21
end


def game_over?(player_hand, dealer_hand)
  game_over = false
  
  player_hand_score = total(player_hand)
  dealer_hand_score = total(dealer_hand)

  if player_hand_score == 21  || busted?(dealer_hand_score)
    puts "Player wins! Player's score is #{player_hand_score}."
    game_over = true
  elsif dealer_hand_score == 21 || busted?(player_hand_score)
    puts "Dealer wins! Dealer's score is #{dealer_hand_score}."
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
  elsif player_hand_score == 21  || busted?(dealer_hand_score)
    puts "Player wins! Player's score is #{player_hand_score}."
    game_over = true
  elsif dealer_hand_score == 21 || busted?(player_hand_score)
    puts "Dealer wins! Dealer's score is #{dealer_hand_score}."
    game_over = true
  end
  if game_over
    puts "Dealer: #{dealer_hand}"
    puts "Player: #{player_hand}"
  end

  game_over # returns true/false value
end

def play_again
  print "Would you like to play again? (y/n)"
  answer = gets.chomp
  if answer.downcase == 'y' || answer.downcase == 'yes'
    return true
  end
  false 
end

# what happens if each player gets 21 on the first deal?

def hit_or_stay(player_hand, dealer_hand, used_cards)
  puts "Your hand is: #{player_hand}. Your score is #{total(player_hand)}."
  loop do
    puts "hit or stay?"
    answer = gets.chomp
    if answer == 'hit'
      deal_hands!(1, player_hand, used_cards)
      if game_over?(player_hand, dealer_hand)
        return 
      end
      puts "Your hand is: #{player_hand}. Your score is #{total(player_hand)}."
    end
    if answer == 'stay'
      puts "Your hand is: #{player_hand}. Your score is #{total(player_hand)}."
      return
    end
  end
end

def computer_hit_or_stay(dealer_hand, player_hand, used_cards)
  while total(dealer_hand) < total(player_hand) && total(dealer_hand) <= 17
    deal_hands!(1, dealer_hand, used_cards)
    if game_over?(player_hand, dealer_hand)
      return 
    end
  end
end

# 21 -

DECK = initialize_deck

#game loop
def main

  loop do 
    used_cards = Set[]
    player_hand = []
    dealer_hand =[]

    deal_hands!(2, player_hand, used_cards)
    deal_hands!(2, dealer_hand, used_cards)

    player_hand_score = total(player_hand)
    dealer_hand_score = total(dealer_hand)

    #break if game_over?(player_hand, dealer_hand) && !play_again

    hit_or_stay(player_hand, dealer_hand, used_cards)
    computer_hit_or_stay(dealer_hand, player_hand, used_cards)
    break if !play_again 
    
  end 
end



main

# def total(hand)# only calculating Ace [[][]] [['HA', 1]]
#   # assume hand is an array of cards
#   # represent each card with key from hash -> 'HA',
#   # every string in the hand array will have a value in the set
#   hand_total = 0
#   has_ace = false
#   hand.each do |(card_key, _ )|
#     if DECK[card_key] == 1 # {'HA' => 1, 'HK' => 10 } DECK['HA']
#       has_ace = true
#     end
#     hand_total += DECK[card_key]
#   end
#   if hand_total + 10 <= 21
#     hand_total += 10
#   end
#   hand_total
# end

# def deal_hands!(number_of_cards, hand, used_cards) # start of game is 2
#   number_of_cards.times do
#     card = DECK.to_a.sample # {'HA' => 1, 'HK' => 10 } == [['HA', 1],['HK', 10]]
#     while used_cards.include?(card[0])
#       card = DECK.to_a.sample
#     end
#     hand << card[0] #['HA', 1]
#     used_cards.add(card[0])
#   end
# end # returns an array for hand with new card(s)

# # p deal_hands(2, [])
# # p deal_hands(10, [])
# def busted?(score)
#   score > 21
# end