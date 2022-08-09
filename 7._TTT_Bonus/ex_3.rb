=begin
The computer currently picks a square at random. That's not very interesting. Let's make the computer defensive minded, so that if there's an immediate threat, then it will defend the 3rd square. We'll consider an "immediate threat" to be 2 squares marked by the opponent in a row. If there's no immediate threat, then it will just pick a random square.

GOAL: to make the computer more defensive by writing a method that checks if the player picked 2 squares in a row.  If so, the computer will pick the 3rd square. If not , then computer picks random square.

input: board
output: computer's 'O' in a more strategic defensive position

E: Test case:
  If player has two X's in a row
      X | X |  -> X | X | O
  Also if player has two X's diagonally in a row
      X |   |      X |   |
        | X |        | X |  
        |   |   =>   |   | O

D: 

A: The explanation of what the code is performing is during each move
the computer makes, the code is going to execute and look for any line
with two of either X or O and either make an offensive or defesive move
regarding which is necessary.

set square to nil

check if there are two computer markers for the chance to win as dfined
in the winning lines, then returns the square = open space

checks if the computer is at risk of losing by there being two player
pieces in one row, if so, then it sets the square the computer will move 
to in order to block that spot.

if there is no offensive or defensive move it sets square to the center square.

  then if none of the other three conditions are met it sets the square to any 
  random empty space

at_risk_square finds the values in the board on a line that counts 2 markers
then select from the board the line that includes 

=end

def at_risk_square(line, brd, marker)
  if brd.values_at(*line).count(marker) == 2
    brd.select{|k,v| line.include?(k) && v == INITIAL_SQUARE }.keys.first
  end
end

def computer_place_piece!(brd)
  square = nil

  #offense
  WINNING_LINES.each do |line|
    square = at_risk_square(line, brd, COMPUTER_MARKER)
    break if square
  end

  if !square # defense
    square = empty_squares(brd).sample
  end
  brd[square] = COMPUTER_MARKER
end
computer_place_piece!(board)


# def computer_places_piece!(brd)
#   square = empty_squares(brd).sample
#   brd[square] = COMPUTER_MARKER
# end

=begin
As usual, we'll take the most obvious, non-clever approach first.
In order to see if the player is about to win, we want to iterate
through our `WINNING_LINES` and see if any of them are at risk of
being filled; in other words, we can iterate through the `WINNING_LINES`
and look for any lines that have 2 of their values marked by the 
player.

Since our `WINNING_LINES` is an array of 3-element arrays, we can 
iterate through `WINNING_LINES` and pass in each element (again,
which are 3-element arrays) into a method to see if any of those lines
are at risk of being filled. That means we need a method to inspect 
the 3-element array and tell us if 2 of those elements are marked by
the player.
=end

def find_at_risk_square(line, board)
  if board.values_at(*line).count('X') == 2
    board.select { |k, v| line.include?(k)} # the include? method is invoked on the line in the array and compares k to the elements of the array, if it does include it, the method returns true.