=begin

1. Initialize deck
2. Deal cards to player and dealer
3. Player turn: hit or stay
  - repeat until bust or "stay"
4. If player bust, dealer wins.
5. Dealer turn: hit or stay
  - repeat until total >= 17
6. If dealer bust, player wins.
7. Compare cards and declare winner.


1. Create a deck function for this game.  

When I'm playing any card game and a card gets used it is removed
from the deck.  Don't want to have a case where it goes back into the deck.

hash could make it easier to understand
string could represent the code
'H King' => 10
'S Queen' => 10
'D 10' => 10

13 unique elements
4 suits
loop over a loop
hash with 52 key-value pairs where the keys are the name of the card
with the suit letter and numerical value.
For the `'Ace'` going to have to check numerical value.
2nd hash, that maps the card type to the value.
1 data structure to look a value in the other one?
We want to modify the data structure while we are iterating through.
Ideally we just have one hash that represents the deck.

Leveraging these lists to build the hash.  Using these pieces to
conveniently loop over them all.  For the key and value we are going
to combine the card types and the key.
=end

# DECK = {}
# #two lists:
# card value = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10]
# card type = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K']
# suits = ['H', 'D', 'S', 'C']

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
  deck.to_a.shuffle.to_h
end

p initialize_deck
p initialize_deck.size