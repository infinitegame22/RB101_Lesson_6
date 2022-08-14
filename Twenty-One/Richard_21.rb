
=begin
Thanks to JD Fortune for kindly donating his design and code for
displaying cards. JD also pointed out that an array of hashes would
be a better data structure than an array of arrays due to less knowledge
of implementation details required (see peer_feedback.md for more
details and https://github.com/JDFortune/RB101/blob/main/lesson_6/twentyone/twenty_one.rb).
Thanks to Amy D. for collaborating on deck design, code reviews, and
other discussions to flesh out this code.
=end
require_relative 'message'

# ================== INITIALIZE CONSTANTS =====================

PARTICIPANT = {
  id: nil,  name: '',
  role: 'Player', score: 0,
  hand: nil, total: 0,
  unadjusted_total: 0,
  busted: false, num_aces: 0
}.freeze

DEALER_NAME = 'Jack Dragonchak Fortuna'.freeze

SUITS = %w(♥ ♣ ♦ ♠).freeze
VALUES = (2..9).to_a.concat(%w(J Q K A)).freeze
ACE = 'A'.freeze
HIDDEN_CARD = { suit: '?', rank: '?' }.freeze

MAX = 21 # The max total value a player can have before busting.
HIT_LIMIT = 17 # The dealer must hit until their hand is worth
# at least this value.

TABLE_WIDTH = 71 # Number of characters needed to fit a 6 cards
NUM_CARDS_PER_ROW = 6 # Max cards that can be displayed before
# pretty-printing stops working.
YES_OR_NO = %w(y n).freeze

# ================== HELPER METHODS =====================

# ------------------- Display Methods -------------------

def prompt(msg)
  puts "=> #{msg}"
end

def clear_screen
  system('clear') || system('cls')
end

# See 'message.rb'.
def welcome_player
  clear_screen
  puts welcome_message
  puts ''
end

def total_based_on_view(player, view)
  show_cards?(player, view) ? player[:total] : '?'
end

def card_image(card) # rubocop:disable Metrics/AbcSize
  cards = []
  cards << '+---------+'
  cards << ("#{'|'.ljust(8)}#{card[:rank].to_s.ljust(2)}|")
  cards << '|         |'
  cards << ('|'.ljust(5) + (card[:suit]).to_s + '|'.rjust(5))
  cards << '|         |'
  cards << ("|#{(card[:rank]).to_s.rjust(2)}#{'|'.rjust(8)}")
  cards << '+---------+'
  cards
end

def prettify!(cards)
  cards.map! { |card| card_image(card) }
end

def split_into_groups!(num_cards_per_row, cards)
  temp_cards = cards.dup
  cards.pop(cards.size)

  cards << temp_cards.pop(num_cards_per_row) until temp_cards.empty?

  cards
end

def lay_cards_in_rows!(cards)
  cards.map! do |row_of_cards|
    row_of_cards.transpose.map { |a| a.join(' ') }
  end
end

def hide_dealer!(cards)
  hand = [cards.first, HIDDEN_CARD]
  cards.pop(cards.size)

  hand.each do |card|
    cards << card
  end
end

def show_cards?(player, view)
  return true unless view.downcase == 'player'

  player?(player)
end

def line_up!(cards, num_cards_per_row = NUM_CARDS_PER_ROW)
  split_into_groups!(num_cards_per_row, cards)
  lay_cards_in_rows!(cards)
end

def display_cards(player, view = 'player')
  cards = player[:hand].dup

  hide_dealer!(cards) unless show_cards?(player, view)
  prettify!(cards)
  line_up!(cards)

  puts cards
end

def display_boundary(word, width = TABLE_WIDTH,
                     padding_symbol = '=', line_spacing = nil)
  puts word.center(width, padding_symbol)
  puts "\n\n\n" if line_spacing == :extra_space
end

def scores(players)
  scores = players.map { |player| "#{player[:name]}: #{player[:score]}" }
  scores.join(' | ')
end

def display_scores(players, width)
  puts 'SCORES'.center(width)
  puts ''.center(width, '-')
  scores = scores(players)

  puts "#{scores.center(width)}\n\n"
end

# 71 is the width of a full row of cards.
def display_table(players, view = 'player', width = TABLE_WIDTH)
  clear_screen
  display_boundary('GAME')

  players.each do |player|
    total = total_based_on_view(player, view)

    puts "\n#{player[:role]}: #{player[:name]}" \
         "\n Total: #{total}" \

    display_cards(player, view)
    puts "\n"
  end

  display_boundary('BOARD')
  puts "\n\n"
  display_scores(players, width)
end

def display_centered_message(msg, _width = TABLE_WIDTH)
  puts msg.center(TABLE_WIDTH)
  puts ''
end

def display_art(winner, player_win_art, dealer_win_art)
  if player?(winner)
    display_centered_message(player_win_art)
  else
    display_centered_message(dealer_win_art)
  end
end

def display_end_game_art(winner)
  display_art(winner, congrats_message, sad_dinosaur_message)
end

def show_art(phase, winner)
  if phase == 'round'
    display_art(winner, success_message, sad_face_message)
  else
    display_end_game_art(winner)
  end
end

def display_result(players, winner, phase = 'round')
  if phase == 'round'
    clear_screen if phase == 'round'
    display_scores(players, TABLE_WIDTH)
  end

  unless winner
    display_centered_message("The #{phase} is a tie!")
    return
  end

  msg = "#{winner[:role]} #{winner[:name]} " \
        "is the winner of the #{phase}!\n\n"

  display_centered_message(msg)
  show_art(phase, winner)
end

def show_game_result(players, winner, width = TABLE_WIDTH)
  clear_screen

  display_boundary('END OF GAME', width, '=', :extra_space)
  display_result(players, winner, 'game')
  display_boundary('END OF GAME', width, '=', :extra_space)
end

def wish_player_good_bye
  clear_screen
  display_boundary('BYE!', TABLE_WIDTH, '=')
  puts cute_good_bye_message
  display_boundary('BYE!', TABLE_WIDTH, '=')
  0.upto(6) do
    print '.'.center(10)
    sleep(0.5)
  end

  clear_screen
  puts good_bye_sasuke_message

  sleep(3)
  clear_screen
end

# ------------------- Initialization Methods -------------

def initialize_shuffled_deck
  deck = SUITS.product(VALUES).shuffle

  deck.map do |card|
    { suit: card[0], rank: card[1] }
  end
end

def request_name(player_num)
  prompt "You're player #{player_num}. What's your name?"
  name = nil
  loop do
    name = gets.chomp
    break unless name.empty?

    prompt 'Please enter at least one character.'
  end
  name
end

def initialize_player(player_num, test = nil)
  name = if test == :test
           "Test Player #{player_num}"
         else
           request_name(player_num)
         end

  player = PARTICIPANT.dup
  player[:id] = player_num
  player[:name] = name
  player[:hand] = Array.new
  player
end

def initialize_players(num_players = 1, test = nil)
  if num_players < 1
    prompt 'Number of players must be at least 1...'
    return
  end

  players = []
  1.upto(num_players) do |player_num|
    players << initialize_player(player_num, test)
  end

  dealer = PARTICIPANT.dup
  dealer[:id] = players.last[:id] + 1
  dealer[:name] = DEALER_NAME
  dealer[:role] = 'Dealer'
  dealer[:hand] = Array.new
  players << dealer
end

# ------------------- Decision Methods ------------------

def player?(player)
  player[:role].downcase == 'player'
end

def valid_choice?(choice, choices)
  return false unless choice

  choices.include?(choice.downcase)
end

def response(choices)
  choice = nil
  loop do
    choice = gets.chomp
    break if valid_choice?(choice, choices)

    prompt "You may only enter '#{choices[0]}' or '#{choices[1]}'."
  end
  choice.downcase
end

def affirmative?(valid_choices)
  response(valid_choices) == 'y'
end

def player_wants_to?(request)
  prompt "Want to #{request}? Enter (y)es or (n)o."

  affirmative?(YES_OR_NO)
end

def winner_of_game?(players)
  sleep(0.5)
  players.any? do |player|
    player[:score] >= 5
  end
end

def busted?(player)
  player[:total] > 21
end

def all_busted?(players)
  players[0...-1].all? { |player| player[:busted] }
end

def hit?(player)
  case player[:role].downcase
  when 'player'
    player_wants_to? 'hit'
  else
    player[:total] < 17
  end
end

def all_tied?(players)
  return false if players.size == 1

  players.all? do |player|
    player[:total] == best_total(players)
  end
end

# ---------------------- Deal Card Methods -----------------------

def value(card)
  case (card[:rank])
  when 'A' then 11
  when 'J', 'Q', 'K' then 10
  else card[:rank].to_i
  end
end

# Aces start with a value of 11 and decrease in value
# by 10 if counting the ace as 11 would cause the
# player to bust.
def adjust_total!(player)
  aces = player[:num_aces]
  player[:total] = player[:unadjusted_total]

  aces.times { player[:total] -= 10 if player[:total] > MAX }
end

# Keep track of an unadjusted total alongside the current
# adjusted total to make it easier to adjust the total
# based on the number of aces.
def update_total!(player, card)
  return unless card

  player[:unadjusted_total] += value(card)
  player[:total] += value(card)

  adjust_total!(player) if player[:total] > MAX
end

def deal!(deck, player, num_cards = 1)
  num_cards.times do
    card = deck.pop
    break unless card

    player[:hand] << card
    player[:num_aces] += 1 if card[:rank] == ACE

    update_total!(player, card)
    player[:busted] = true if busted?(player)
  end
end

def deal_cards!(deck, players, num_cards = 2)
  players.each { |player| deal!(deck, player, num_cards) }

  nil
end

# ------------------------- Game Play Methods --------------------

def take_turn!(deck, players, player)
  turn = player[:role].downcase
  loop do
    break if busted?(player)
    return unless hit?(player)

    deal!(deck, player)
    sleep(1) if turn == 'dealer'
    display_table(players, turn)
  end
  puts "#{player[:role]} #{player[:name]} busted!" if busted?(player)
  sleep(1)
end

def play_round!(players)
  deck = initialize_shuffled_deck

  deal_cards!(deck, players)
  display_table(players)

  players[0...-1].each do |player|
    prompt "Player #{player[:name]}, it's your turn."

    take_turn!(deck, players, player)
  end

  display_table(players, 'dealer')
  sleep(1)

  if all_busted?(players)
    sleep(2)
    return
  end

  take_turn!(deck, players, players.last)
end

def best_total(players)
  players.max do |player1, player2|
    player1[:total] <=> player2[:total]
  end[:total]
end

def player_with_best_total(players)
  players.find do |player|
    player[:total] == best_total(players)
  end
end

def round_winner(players)
  players = players.reject { |player| player[:busted] }
  return player_with_best_total(players) unless all_tied?(players)
end

def update_score!(round_winner)
  return unless round_winner

  round_winner[:score] += 1
  sleep(1)
  nil
end

def reset_round!(players)
  players.each do |player|
    player[:total] = 0
    player[:unadjusted_total] = 0
    player[:num_aces] = 0
    player[:busted] = false
    player[:hand] = []
  end
  sleep(1)
end

# ====================== Play Game! ===========================

def play_game!
  clear_screen
  players = initialize_players

  loop do
    play_round!(players)

    winner = round_winner(players)
    update_score!(winner)

    if winner_of_game?(players)
      show_game_result(players, winner)
      return
    end

    display_result(players, winner)
    reset_round!(players)
    break unless player_wants_to? 'continue this game'
  end
end

# =============================== MAIN =========================

def main
  welcome_player

  while player_wants_to? 'play a new game'
    play_game!
    sleep(1)
  end

  wish_player_good_bye
end

 
# Trade-off: Likely not a good practice, but is more convenient
# than using a YAML file.
# Credit: https://emojicombos.com/goodbye-ascii-art
def cute_good_bye_message
  <<~MSG
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠴⠒⠒⠲⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⢀⡤⠶⠲⠦⣄⠀⠀⠀⣀⣀⣀⣀⣤⣤⣼⣃⣀⡴⠋⠛⢦⢻⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⣰⢋⡴⠖⠦⣄⣨⠷⠚⠉⠉⠀⠀⠀⠀⠀⠀⠈⠉⠲⢤⡀⢈⡇⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⣏⢸⠀⠀⣰⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣼⠃⠀⠀⠀⠀⠀⠀⠀⢀⣀⡠⠤⠤⠤⠤⠄⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⢻⡜⢦⡞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⡄⠀⠀⠀⠀⢀⠴⠋⢡⣦⣤⣀⠀⠀⠀⠀⠀⠀⠉⠑⠲⠤⣀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⢹⡾⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣤⠀⠀⠀⠀⠀⢷⠀⠀⠀⣰⠃⠀⠀⣾⣿⠛⠻⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠢⣄⠀⠀⠀⠀
  ⠀⠀⠀⢸⡇⠀⠀⠀⠀⠐⠶⠆⠀⠀⠀⠀⠀⠀⠀⠉⠁⠀⠀⠀⠀⠀⢸⡄⠀⠀⡇⠀⠀⣸⣿⣷⣶⣶⠿⠃⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠳⣄⠀⠀
  ⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⣠⡀⣀⠤⠒⠋⠉⠙⠒⠾⣿⠇⠀⠀⠀⠀⠀⢧⠀⠀⢧⠀⢠⣿⡏⠀⠈⣿⡦⠀⣿⡇⢀⣼⣶⢄⣀⣀⡀⠀⠀⢠⣦⡌⢣⡀
  ⠀⠀⠀⢸⡇⠀⠀⠀⠀⠈⢿⠟⠁⠀⠰⢿⡿⠂⠀⠀⠈⢣⠀⠀⠀⠀⠀⠸⡇⠀⠈⢦⠘⠻⠿⣶⣾⡿⠃⠀⣿⣥⣾⠟⢡⣾⡟⠛⢿⣧⠀⣼⣿⠃⠀⢳
  ⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⡞⠀⠀⣄⣠⣼⢿⣦⣴⠆⠀⠈⡆⠀⠀⠀⠀⢠⡇⠀⠀⠀⠳⣄⠀⠀⠀⠀⠀⣠⣿⡿⠃⠀⣾⣿⠛⠻⢿⡿⢰⣿⠏⠀⠀⢸
  ⠀⠀⠀⠸⣇⠀⠀⠀⠀⠀⢷⠀⠀⠈⠉⠷⠴⠟⠀⠀⠀⣰⠃⠀⠀⠀⣠⡞⠀⠀⠀⠀⠀⠈⠑⢦⣀⠀⠼⠿⠋⠀⠀⠀⠈⠻⢷⣶⡆⢠⣬⡉⠀⠀⢀⡾
  ⠀⠀⠀⠀⠹⣄⠀⠀⠀⠀⠈⠣⣀⠀⠀⠀⠀⠀⠀⢀⡴⠃⠀⣀⡤⠞⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢑⡶⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠛⠁⣀⡤⠞⠀
  ⠀⠀⠀⠀⠀⠈⠓⢦⣤⣄⣀⣀⣈⣓⣒⣤⣤⣶⡾⠿⢶⣾⣯⣭⣤⣤⣤⣤⣤⣀⡀⠀⠀⠀⠀⠀⡴⠋⠀⠀⣄⣠⡴⠞⠒⠢⠤⠀⠐⠒⠚⠋⠉⠀⠀⠀
  ⠀⠀⠀⠀⣀⣤⠶⠚⠉⠁⣸⠟⠉⠉⠙⢧⣀⠀⠀⠀⡸⢻⠀⠀⠀⠀⠀⠀⠀⠀⠙⢦⡀⠀⠀⠀⠑⠒⠊⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⣸⠋⠉⠉⠁⠀⠀⠀⠀⣰⠏⠀⠀⠀⠀⠀⠈⠑⠒⠚⠁⢸⡟⠶⢤⣄⡀⠀⠀⢠⣦⣤⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⢹⡄⠀⠀⠀⠀⠀⠀⣴⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠈⠙⢳⣄⠈⢻⣿⡞⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠈⠳⣤⣀⣀⣀⣤⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠇⠀⠀⠀⠀⠀⠉⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠹⣏⢿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠙⠿⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⢻⠀⠀⢀⣄⠀⠀⠀⠀⠀⠀⠀⠀⣠⠞⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⢸⡀⠀⠀⠉⠻⣦⠀⠀⠀⣀⣤⠞⠛⠲⣤⣀⣤⠶⠶⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠘⣟⠛⢿⡁⠀⠀⠀⠀⠀⠀⠀⠀⢿⢸⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⢸⠁⠀⠀⠀⠀⠀⠈⢳⠀⠛⢦⣄⠀⠀⠀⠀⠀⣰⣿⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⢸⣄⠀⠀⢀⣤⠀⣠⡾⠀⠀⠀⠙⠷⣄⣀⢀⣾⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠉⠙⠛⠛⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀
  MSG
end

# Cr: Emojicombos, in honor of JD Fortune.
def good_bye_sasuke_message
  <<~MSG
    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⢀⣶⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠀⢀⣴⡇⢠⣾⡇⠀⣠⣴⣿⠁⠀⠀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣤⣿⣿⣷⣿⣿⣷⣾⣿⣿⣧⣤⣶⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣶⡶⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠉⠛⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⢩⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠟⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠙⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠛⠁⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⡿⠿⠟⠛⠛⠉⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠛⠓⠦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠖⠋⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⡇⠀⠀⠀⠀⠀⠀⠀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠲⠶⢤⣤⣄⣀⣀⣀⡞⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣇⣀⣀⣤⡴⠖⠚⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠛⠛⠧⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡤⠞⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡠⠊⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠱⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣶⣿⣿⣿⣿⣶⣦⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢳⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡴⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⢰⠃⠀⠀⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡿⠟⣉⠭⠤⠤⠤⠤⠍⣉⠛⢿⣿⠀⠀⠀⠀⠀⠀⠀⠀⢰⠃⠀⠀⠸⡀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⢠⡟⠀⠀⠀⢱⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠉⠀⠀⠀⠀⠀⠀⠀⠀⠑⢄⠀⠀⠀⠀⠀⠀⠀⠀⡀⡾⠀⠀⠀⣰⠟⣶⣤⡀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⣼⠁⠀⠀⠀⠈⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⢄⠀⠀⠀⠀⠀⠀⠀⠀⡤⠂⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⡴⠃⣴⡿⢋⣿⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⢰⠇⠀⠀⠀⠀⠀⢻⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠒⠂⠀⢀⠔⠒⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠃⢀⡾⢁⣼⡿⣡⡿⠃⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⡞⠀⠀⠀⠀⠀⠀⢸⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣠⠟⢠⣾⠟⣰⡿⡇⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⣸⠃⠀⠀⠀⠀⠀⠀⢸⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡅⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠋⣠⣿⢏⣼⡟⠀⢻⡀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⢠⡏⠀⠀⠀⠀⠀⠀⠀⢸⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡴⠃⣴⡿⢣⣾⠏⠀⠀⠈⢧⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⡾⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡞⢁⣼⡟⣡⣿⠃⠀⠀⠀⠀⠸⡆⠀⠀⠀⠀
  ⠀⠀⠀⣼⠃⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠏⢠⣾⠟⣴⡿⠁⠀⠀⠀⠀⣀⣀⣽⡀⠀⠀⠀
  ⠀⠀⠠⣯⣀⣀⣀⠀⠀⠀⠀⠀⠀⢸⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⠃⣠⣿⢋⣼⣿⣥⡴⠶⠒⠉⢿⣿⡿⠋⠀⠀⠀⠀
  ⠀⠀⠀⠙⠿⣿⣿⠛⠓⠒⠦⣤⣀⣸⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣠⣤⣤⣤⣤⣶⣶⣶⣶⣶⣤⣤⡼⠁⣰⡿⢣⣾⣿⡟⠁⠀⠀⠀⠀⠘⣏⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⢈⡟⠀⠀⠀⠀⠈⢻⣿⡇⠀⢀⣀⣤⣤⣶⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⢀⣼⡟⣱⣿⣿⣿⣷⣤⣀⠀⠀⠀⠀⠸⡆⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⢸⠃⠀⠀⠀⠀⣀⣼⣿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠋⠀⣴⠏⣴⣿⣿⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⢿⡀⠀⠀⠀⠀
  ⠀⠀⠀⠀⢀⡟⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠃⢀⣾⢋⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠸⣇⠀⠀⠀⠀
  ⠀⠀⠀⠀⣸⠃⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠁⣠⡿⢡⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⢻⠀⠀⠀⠀
  ⠀⠀⠀⠀⡟⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏⠀⣴⡟⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠁⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀
  ⠀⠀⠀⢸⠃⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⣠⣾⣿⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⣇⠀⠀⠀
  ⠀⠀⠀⡎⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⡿⠟⠛⡿⠋⠉⡿⠋⠉⠀⡼⠉⠀⠀⠋⠁⠀⠰⠋⠀⠀⡿⠁⠀⢸⠁⠈⢹⠋⠉⢻⠟⠛⣿⣇⠀⠀⠀⠀⠀⠀⢹⠀⠀⠀
  ⠀⠀⢠⡇⠀⠀⠀⠀⠀⠀⢸⣿⠏⠀⠞⠀⠀⠘⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⠘⠀⠀⡿⢹⡀⠀⠀⠀⠀⠀⢸⡆⠀⠀
  ⠀⠀⢸⠀⠀⠀⠀⠀⠀⢀⡟⢻⢀⣀⣀⣀⣀⣤⣤⣤⣴⣤⣤⣤⣤⣤⣤⣶⠶⣦⣶⣶⣶⣶⣦⣤⣤⣤⣤⠤⣶⣶⡶⢤⣤⣤⣶⣾⡃⠀⢧⠀⠀⠀⠀⠀⠈⡇⠀⠀
  ⠀⠀⡿⠀⠀⠀⠀⠀⠀⣸⣱⠟⢻⠟⠛⠙⠟⠉⠉⠛⠁⠀⠘⠋⠀⢀⡾⠃⢀⣾⣿⣿⠟⠉⠃⠀⠀⠸⠀⠀⠀⠑⠀⠀⠀⠇⠀⠈⣿⠀⠸⡆⠀⠀⠀⠀⠀⣿⠀⠀
  ⠀⢰⡇⠀⠀⠀⠀⠀⢀⠏⣟⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⣀⣠⠟⠀⣠⣿⣿⣿⣏⣀⣤⣄⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⠀⢀⠟⠀⠀⢻⣀⣤⣴⣶⣿⣿⣿⡄
  ⠀⣸⣅⣀⣀⣀⣀⣀⣼⠀⠛⢶⣶⣶⣶⣶⣿⣿⣿⣿⣿⣿⣿⣿⠋⠀⣼⠟⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣏⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⡇
  ⢀⣿⣿⣿⣿⣿⣿⣿⣿⠀⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠁⢀⣾⢫⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣆⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⡇
  ⠸⠿⠿⠿⠿⠿⠿⠿⠿⠀⠼⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠟⠀⠠⠿⠱⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠆⠀⠻⠿⠿⠿⠿⠿⠿⠿⠇
  MSG
end

# Cr: https://emojicombos.com/sad-ascii-art
def sad_face_message
  <<~MSG
                                       ⎛⎝( ` ᢍ ´ )⎠⎞ᵐᵘʰᵃʰᵃ
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡤⠖⠚⠉⠁⠀⠀⠉⠙⠒⢄⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢀⠔⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⢢⡀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⡰⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣆⠀⠀
⠀⠀⠀⠀⠀⢠⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢇⠀
⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⡄
⠀⠀⠀⠀⢸⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠇
⠀⠀⠀⠀⠸⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡘
⠀⠀⠀⠀⠀⢻⠀⠀⠀⠀⠀⠀⠀⢀⣴⣶⡄⠀⠀⠀⠀⠀⢀⣶⡆⠀⢠⠇
⠀⠀⠀⠀⠀⠀⣣⠀⠀⠀⠀⠀⠀⠀⠙⠛⠁⠀⠀⠀⠀⠀⠈⠛⠁⡰⠃⠀
⠀⠀⠀⠀⢠⠞⠋⢳⢤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠜⠁⠀⠀
⠀⠀⠀⣰⠋⠀⠀⠀⢷⠙⠲⢤⣀⡀⠀⠀⠀⠀⠴⠴⣆⠴⠚⠁⠀⠀⠀⠀
⠀⠀⣰⠃⠀⠀⠀⠀⠘⡇⠀⣀⣀⡉⠙⠒⠒⠒⡎⠉⠀⠀⠀⠀⠀⠀⠀⠀
⠀⢠⠃⠀⠀⢶⠀⠀⠀⢳⠋⠁⠀⠙⢳⡠⠖⠚⠑⠲⡀⠀⠀⠀⠀⠀⠀⠀
⠀⡎⠀⠀⠀⠘⣆⠀⠀⠈⢧⣀⣠⠔⡺⣧⠀⡴⡖⠦⠟⢣⠀⠀⠀⠀⠀⠀
⢸⠀⠀⠀⠀⠀⢈⡷⣄⡀⠀⠀⠀⠀⠉⢹⣾⠁⠁⠀⣠⠎⠀⠀⠀⠀⠀⠀
⠈⠀⠀⠀⠀⠀⡼⠆⠀⠉⢉⡝⠓⠦⠤⢾⠈⠓⠖⠚⢹⠀⠀⠀⠀⠀⠀⠀
⢰⡀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠁⠀⠀⠀⢸⠀⠀⠀⠀⡏⠀⠀⠀⠀⠀⠀⠀
⠀⠳⡀⠀⠀⠀⠀⠀⠀⣀⢾⠀⠀⠀⠀⣾⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠈⠐⠢⠤⠤⠔⠚⠁⠘⣆⠀⠀⢠⠋⢧⣀⣀⡼⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠈⠁⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀
MSG
end

def sad_dinosaur_message
  <<~MSG
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡶⠛⠛⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⠋⠀⠀⠀⠈⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⢀⣠⠴⠞⠛⠉⠉⠉⠉⠉⠉⠛⠒⠾⢤⣀⠀⣀⣠⣤⣄⡀⠀⠀⠀
  ⠀⠀⠀⣠⡶⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⢭⡀⠀⠈⣷⠀⠀⠀
  ⠀⠀⡴⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢦⢀⡟⠀⠀⠀
  ⠀⣾⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢻⡅⠀⠀⠀
  ⢸⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣄⣀⠀
  ⣾⠀⠀⣠⣤⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣤⣄⠀⠀⠀⠀⠀⠀⠸⡇⠉⣷
  ⣿⠀⠰⣿⣿⣿⡗⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⣧⡴⠋
  ⣿⠀⠀⢸⠛⢫⠀⠀⢠⠴⠒⠲⡄⠀⠀⠀⠀⡝⠛⢡⠀⠀⠀⠀⠀⠀⢰⡏⠀⠀
  ⢸⡄⠀⢸⡀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⢸⠀⠀⠀⠀⠀⠀⡼⣄⠀⠀
  ⠀⢳⡄⠀⡇⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⠀⢸⠀⠀⠀⠀⢀⡼⠁⢸⡇⠀
  ⠀⠀⠙⢦⣷⡈⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠈⡇⠀⣀⡴⠟⠒⠚⠋⠀⠀
  ⠀⠀⠀⠀⠈⠛⠾⢤⣤⣀⣀⡀⠀⠀⠀⠀⣀⣈⣇⡤⣷⠚⠉⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⣰⠇⠀⠩⣉⠉⠉⠉⣩⠍⠁⠀⢷⣟⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⡟⠐⠦⠤⠼⠂⠀⠸⠥⠤⠔⠂⠘⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⣸⣧⡟⠳⠒⡄⠀⠀⠀⡔⠲⠚⣧⣀⣿⠿⠷⣶⡆⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠻⣄⢀⠀⠀⡗⠀⠀⠀⡇⠄⢠⠀⣼⠟⠀⢀⣨⠇⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠙⢶⠬⠴⢧⣤⣤⣤⣽⣬⡥⠞⠛⠛⠋⠉⠀⠀⠀⠀⠀⠀⠀
  MSG
end

# Cr: https://emojicombos.com/fist-bump-ascii-art
def success_message
  <<~MSG
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣤⣶⣶⣶⣦⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣤⣤⣤⣄⣀⣤⣾⡿⠛⠉⠉⠉⠙⠻⢿⣿⣶⣾⣿⣿⠿⣿⣷⣦⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⣿⠟⠋⠉⠛⢻⠛⣿⠏⠀⠀⠀⠀⠀⠀⠀⠳⡴⠛⠉⠀⠀⠀⠀⠈⠻⢿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⣠⣶⣿⠿⠿⠿⣿⡿⠃⠀⠀⠀⠀⠀⢻⡅⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⣼⣿⠏⠀⠀⠀⠤⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⣦⡀⠀⠀⠀⠀⠀
  ⠀⠀⣸⣿⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣷⠀⠀⠀⠀⠀
  ⠀⢰⣿⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢢⣸⣿⣆⠀⠀⠀⠀
  ⠀⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣼⠀⠀⠀⠀⠀⠀⠀⠀⠀⠰⡄⢀⠀⠀⠀⠀⠀⠀⠀⢸⡟⢻⣿⣆⠀⠀⠀
  ⢰⣿⡇⡀⠀⠀⠀⠀⠀⠀⠐⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⡏⠀⠀⠀⠀⠀⠀⠀⠘⣇⠀⢻⣿⡄⠀⠀
  ⢸⣿⡆⢸⠀⠀⠀⠀⠀⠀⠀⢹⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠁⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠘⣿⣇⠀⠀
  ⠀⢿⣷⣸⡀⠀⠀⠀⠀⠀⠀⠀⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡆⢰⣿⡇⠀⠀
  ⠀⠈⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⢻⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⣾⣿⠁⠀⠀
  ⠀⠀⠸⣿⣧⠀⠀⠀⠀⠀⠀⠀⢸⡄⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⠀⢿⣿⡀⠀⠀
  ⠀⠀⠀⢿⣿⡄⠀⠀⠀⠀⠀⠀⠸⣇⠀⠀⠀⠀⠀⠀⠀⠀⢻⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⢀⡿⠀⠘⣿⣷⡀⠀
  ⠀⠀⠀⠸⣿⣇⠀⠀⠀⠀⠀⠀⢀⣿⡀⠀⠀⠀⠀⠀⠀⠀⢸⡀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣧⠀⠀⠀⠀⠀⣀⣀⣠⣾⠃⠀⠀⠙⣿⣷⡄
  ⠀⠀⠀⠀⢻⣿⣦⡀⢤⣀⣠⣴⠿⣿⣧⠀⠀⠀⠀⠀⠀⣠⣾⡇⢀⡀⠀⠀⠀⠀⣀⣴⣿⣿⣷⠶⠛⠛⠛⠉⠉⠛⠛⠳⠀⠀⠀⠈⣿⣿
  ⠀⠀⠀⠀⠀⠙⠻⣿⣶⣤⣔⣚⣛⣿⣿⣧⡈⠙⣛⣛⣻⣿⣿⣿⣄⠉⣛⣛⣛⣛⣛⣿⡿⠉⠀⠠⠤⢀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡿
  ⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠛⠿⠟⠛⠙⠿⣿⣶⣦⣬⣭⣿⣿⣿⣿⣷⣮⣭⣽⣿⣿⡿⠀⠀⡇⠀⠀⠀⠈⢳⡀⠀⠀⠀⠀⠀⠀⢸⣿⠇
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠛⠛⠋⠉⠁⠀⠉⠛⠛⠛⠻⣿⣧⠀⢠⡇⠀⠀⠀⢀⣼⠁⠀⠀⠀⠀⠀⣠⣿⡟⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢿⣿⣾⣧⣤⣴⣶⣿⣿⣶⣶⣶⣤⣶⣾⡿⠟⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠁⠀⠀⠀⠀
  MSG
end

# Cr: https://emojicombos.com/congratulations
def congrats_message
  <<~MSG
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢀⣠⣴⣶⣿⣿⣿⣿⣿⣿⠆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣤⣶⣿⠇⠀⠀⠀⠀⠀
⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡀⠀⣀⣤⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡟⠀⠀⠀⠀⠀⠀
⠀⠀⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⣁⣼⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡴⠀⣠⣶⣿⣷⣆⠀⠀⠀⠀⢸⣿⣿⠃⠀⠀⠀⠀⠀⠀
⠀⢰⣿⣿⣿⣿⣿⣿⣿⠿⠟⠿⢿⣿⣿⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⣿⣿⣿⣿⣿⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⣠⣿⣧⣾⣿⣿⣿⣿⡟⠀⠀⠀⠀⣼⣿⡟⠀⠀⣠⠀⠀⠀⠀
⢀⣿⣿⣿⣿⣿⡿⠋⠁⠀⠀⠀⠀⠈⠛⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⠟⢹⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⢾⣿⣿⣿⠟⣻⣿⣿⣿⣷⣤⠀⠀⠀⣿⣿⣃⣤⣾⣿⣀⣤⣤⡀
⢸⣿⣿⣿⣿⡟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⣿⡟⠀⢸⣿⡇⠀⠀⠀⢀⣀⣀⡀⠀⠸⣿⣿⠁⣰⣿⣿⡿⠋⢹⣿⡇⠀⣠⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇
⢸⣿⣿⣿⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣶⣶⣶⣦⣄⠀⣿⣿⡇⠀⣼⣿⡇⠀⢀⣴⣿⣿⣿⣿⣀⣴⣿⣿⠀⠛⠻⠿⠁⠀⢸⣿⣿⣿⣿⣿⡿⠋⢻⣿⣿⠋⠉⠉⠁
⠘⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⣿⣿⣿⣿⣷⣿⣿⡇⠀⣿⣿⣧⠀⣼⣿⣿⢿⣿⣿⣿⡿⢹⣿⠀⠀⢀⣤⣶⣶⣿⣿⡟⠁⢸⣿⡇⠀⠸⣿⣏⠀⠀⠀⠀
⠀⢻⣿⣿⣿⣿⣦⣀⠀⠀⠀⠀⢀⣠⣴⣿⣿⣿⡏⠀⠘⣿⣿⣿⣿⣿⡇⠀⢻⣿⣿⣷⣿⣿⠃⠀⢿⣿⣿⠁⣼⣿⠀⣰⣿⡿⠛⢻⣿⣿⣿⠀⢸⣿⡇⠀⠀⠹⣿⣦⡀⠀⠀
⠀⠈⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⢹⣿⣿⣿⣿⠃⠀⠸⣿⣿⣿⣿⣿⠀⠀⢸⣿⡏⢠⣿⣿⡆⣿⣿⠀⠀⣼⣿⣿⣿⣦⣿⣿⠉⣷⣦⣄⠹⣿⣿⣦⠀
⠀⠀⠀⠙⠻⢿⣿⣿⣿⣿⣿⣿⡿⠟⢿⣿⣿⣿⡇⠀⠀⢸⣿⣿⣿⠿⠆⠀⠀⠹⣿⣿⣿⣿⣆⣠⣿⣿⠃⣾⣿⣿⡇⢻⣿⣷⣿⣿⠟⢿⣿⣿⣿⣿⡇⠸⣿⣿⠀⣿⣿⣿⡇
⠀⠀⠀⠀⠀⠀⠀⠉⠉⠉⠉⠀⠀⠀⢸⣿⣿⣿⣿⣤⣴⣿⣿⣿⡟⠀⠀⠀⠀⠀⠈⠹⣿⣿⣿⣿⣿⣿⠛⠛⠛⠛⠻⠀⠉⠉⠉⠀⠀⠀⠉⠛⣿⣿⣷⠀⢻⣿⣿⣿⣿⣿⠃
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⣿⣿⣿⣿⣿⣿⣿⡟⠀⠀⠀⣠⣆⠀⠀⠀⠙⠛⠛⠛⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣧⡀⠉⠛⠛⠋⠁⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⠻⠿⠿⠛⠉⠀⠀⢀⣴⣿⣿⡄⠀⠀⠀⠀⠀⠀⣿⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣶⣤⣄⣀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣷⡀⠀⠀⠀⠀⢸⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⣿⣿⣿⣿⡏⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣷⣄⠀⠀⢠⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢿⣿⣿⣿⣿⣷⣾⣿⡿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠻⠿⠿⠿⠟⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⣿⡇⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡀⠀⠀⠀⠀
MSG
end

def welcome_message
  <<~MSG
                        Rules of Twenty-One
                      +---------+ +---------+
                      |       K | |       A |
                      |         | |         |
                      |    ♠    | |    ♥    |
                      |         | |         |
                      | K       | | A       |
                      +---------+ +---------+
  - The goal of Twenty-One is to try to get as close to 21 as possible,
  without going over. If you go over 21, it's a "bust" and you lose.
  - Setup: the game consists of a "dealer" and a "player". Both
  participants are initially dealt 2 cards. The player can see their
  2 cards, but can only see one of the dealer's cards.
  - Cards 2-10 are worth their face value. Jack, Queen, and king
  are worth 10. Ace is worth 1 or 11.
  - Player turn: the player goes first, and can decide to either "hit"
  or "stay". A hit means the player will ask for another card. Remember
  that if the total exceeds 21, then the player "busts" and loses.
  The decision to hit or stay will depend on what the player's cards are
  and what the player thinks the dealer has. For example, if the dealer
  is showing a "10" (the other card is hidden), and the player has a "2"
  and a "4", then the obvious choice is for the player to "hit". The
  player can continue to hit as many times as they want. The turn is
  over when the player either busts or stays. If the player busts, the
  game is over and the dealer won.
  - Dealer turn: when the player stays, it's the dealer's turn. The
  dealer must follow a strict rule for determining whether to hit or
  stay: hit until the total is at least 17. If the dealer busts, then
  the player wins.
  MSG
end
