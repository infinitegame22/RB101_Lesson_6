Before we can start coding, we need to come up with an approach to mentally map the solution. But before even starting to think about a solution, we have to first understand the problem better and decompose it more. For complex problems, a good starting point is describing the problem, and building a high level flowchart.

Description of the game:
Tic Tac Toe is a 2 player game played on a 3x3 board. Each player takes a turn and
marks a square on the board. First player to reach 3 squares in a row, including diagonals,
wins. If all 9 squares are marked and no player has 3 squares in a row, then the game is a tie.

That's a generic description, but in order to build a flow chart, we need to outline the sequence of teh gameplay a little more. 

1. Display the initial empty 3x3 board.
2. Ask the user to mark a square.
3. Computer marks a square.
4. Display the updated board state.
5. If winner, display winner.
6. If board is full, display tie.
7. If neither winner nor board is full, go to #2
8. Play again?
9. If yes, go to #1
10. Good bye!

I can see from the above sequence that there are two main loops -- one at step #7, after either the winner is found of the board is full, and another at step #9, after we ask if the user wants to play again. I  can also notice that we are using higher level pseudo-code, and it's not formal pseudo code. The reason is becase we are staying at a zoomed out higher level for now, and all the imperative code -- the step by step directions -- is encapsulated into sub-processes. For example, the "display the board" doesn't go into exactly *how* we should display the board. We'll just trust that a sub-process, or function, can take care of it. In other words, we trust we can figure that part out, but we need to focus on higher level thinking right now.

##Flowchart

Notice there's a lot of rectangle boxes, which stands for some sort of processing. The general flow is here, but it's a much higher level flowchart than what we've been working with in the past.  I can see that the sub-processes will need to work with some sort of "board". Every sub-process, from "Display board", to "User marks square", to "board full?", requires inspecting the board.  In some cases, like when we need to mark a square, we'll even have to permanently modify the board state.

With this flow chart in hand, we're finally ready to take our first step in writing some code. 

Note: yes, I could spend more time here by writing out fomal pseudo-code for each subprocess.  That would be a far more detailed approach, and would be a great technique for a program that' more complicated.  If I'm still having a hard time deconstructing the logic of this program, go ahead and take that step.  Zoom-in to each subprocess and try to outline exactly how to approach that problem.