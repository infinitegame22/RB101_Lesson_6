=begin
1. ask "hit" or "stay"
2. if "stay", stop asking
3. otherwise, go to #1
=end
loop do
  puts "hit or stay?"
  answer = gets.chomp
  break if answer == 'stay'
end

def total(hand)# only calculating Ace
  # assume hand is an array of cards
  # represent each card with key from hash -> 'HA',
  # every string in the hand array will have a value in the set
  # hand_total = 0
  # has_ace = false
  # hand.each do |card_key|
  #   if card_key.last == 1
  #     has_ace = true
  #   end
  #   hand_total += card_key.last
  # end
  aces = hand.values.count(1)
  sum = hand.values.sum
  aces.times do 
    sum += 10 if sum + 10 <= 21 
  end 
  sum
  # if hand_total + 10 <= 21
  #   hand_total += 10
  # end
  # hand_total
end