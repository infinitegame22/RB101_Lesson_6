=begin
Input: Integer (that is the index location of array)
Output: Integer (sum of array)
Examples/Rules: 

Algorithm:
Given a number to represent the roao f hte triangle of consecutive
odd numbers
2. build a nested array where each element of the outer array
is an array of the elements, representing each progressive row
of the triangle.
  - starting number to represent the initial integer of the triangle
  - triangle_arr =[]
  - tracking index = 1
  - iterating through until the size of the current array == n?
    - set a new empty array
  - push into an empty array the current number until the empty
  array size is current element index + 1 
  - iterate the starting number by two
  - iterate the index by 1
3. return the sum of the nth row of integers.
4. return the sum of the last element in the outer array
=end

def triangle(n)
  final_array = [] # This array will hold arrays which elements are odd numbers
  current_odd_number = 1
  element_tracker = 1 # This will keep track of the num_of elements in each row
  loop do
    current_row_array = [] # This will hold the odd elements on each row
    until current_row_array.size == element_tracker # Does this make it clearer?
      # The element_tracker determines how many odd element current_row_array 
    #should get in each iteration
      current_row_array << current_odd_number # keep pushing until the abv condition
      current_odd_number += 2 # adding 2 to an odd number gives us the next oodd
    end
    element_tracker += 1 # You get the gist now? 
    #the next current_array/ triangle level should have +1 elements
    final_array << current_row_array # push to the final array
    break if final_array.size == n # brk if we v n elements/levels in the final array
    # Recall that each element in the final array represents a level in the triangle
  end
  final_array.last.sum #call the Array#sum method on the lst element of the final_arr
end
​
  p triangle(5) #=> 125
  p triangle(50) #=> 125000
  p triangle(3) #=> 2