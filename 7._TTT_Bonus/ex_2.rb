=begin
Keep score of how many times that player and computer each win. Don't use global or instance variables. Make it so the first player to 5 wins the game.

Define a method that keeps score up to 5...could be the champion...draw a crown?

input: integer count of wins
output: output to the screen the count of each win at the end of the game.  
when count reaches 5 wins then print to the screen, game champion!! with a crown if possible

| *    *    * |
|**   ***   **|
|*************|
|*************|
|*************|

E: Output each round: wins for computer: 3
                      wins for player: 2
                      1st to 5 wins!

Test case: Congratulations to the Computer!
           The Computer has reached 5 wins!
            Computer is the crown champion!
            | *    *    * |
            |**   ***   **|
            |*************|
            |*************|
            |*************|

D: integer count -> string

A: initialize count to 0 for player
intialize count to 0 for computer
IF Computer wins round
  add 1 to computer count 
ELSE add 1 to player count
print the current count to the screen for each player
IF the count for either player hits 5, print the champion message
to the screen.
=end

score = {"Player" => 0, "Computer" => 0}

def round_count(string, score)
  if string == 'Player'
    score["Player"] += 1
  end
  if
    score["Computer"] += 1
  end
  if score["Player"] == 5 || score["Computer"] == 5
    puts "Congratulations to #{string}!".center(50)
    puts "The #{string} has reached 5 wins!".center(50)
    puts "#{string} is the crown champion!".center(50)
    puts "| *    *    * |".center(50)
    puts "|**   ***   **|".center(50)
    puts "|*************|".center(50)
    puts "|*************|".center(50)
  end
end

round_count('Player', score)