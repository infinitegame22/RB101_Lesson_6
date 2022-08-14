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

#set deck to be a constant in main game loop
DECK = initialize_deck

# Aces are 1 or 11
# if player or dealer is close to bust
# Initially take it as an 11, if it doesn't bust
# otherwise, count it as 1 so it doesn't go over 21

def total(hand)# only calculating Ace
  # assume hand is an array of cards
  # represent each card with key from hash -> 'HA',
  # every string in the hand array will have a value in the set
  hand_total = 0
  has_ace = false
  hand.each do |card_key|
    if DECK[card_key] == 1
      has_ace = true
    end
    hand_total += DECK[card_key]
  end
  if hand_total + 10 <= 21
    hand_total += 10
  end
  hand_total
end

ace_count = 2
loop do
  if hand_total + 10 <= 21 && ace_count > 0
    hand_total += 10
    ace_count -= 1
  end
  break if hand_total + 10 > 21 || ace_count == 0
end

p total(['HA', 'S2']) == 13
p total(['HA', 'S9', 'CA']) == 21
p total(['DQ', 'S9']) == 19
  # since Ace is a 1 by default
# set of cards used already, check to see if we have used this already, 
# if we haven't then pass it to the player and put it into the set
# set is very efficient, set of keys -> auxiliary data structure to keep track of 
# cards being used.
# main game loop use a set

# def main
  
# end

# main
=begin
  
rescue => exception

{ 1  => [1], 2 => [3, 5], ... 5 => [21, 23, 25, 27, 29] }
the number of elements determeins how many times you do something
=end

def triangle(num_rows)
  current_value = 1
  rows = {}

  1.upto(num_rows) { |nth_row| rows[nth_row] = Array.new }

  #rows[1] << current_value # we don't start at 0
  1.upto(num_rows) do |nth_row|
    nth_row.times do
      rows[nth_row] << current_value
      current_value += 2
    end
  end
  rows[num_rows].sum
end