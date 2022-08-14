=begin
Given the triangle of consecutive odd numbers:
            1
         3     5    
      7     9    11   
  13    15    17    19  
21    23    25    27    29 
...

Calculate the sum of the numbers in the nth row of this triangle. e.g. (Input --> Output)

1 -->  1
2 --> 3 + 5 = 8
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
      current_row_array << current_odd_number # keep pushing until the abv condition # [1, 2, 3, 4...n] => current_row_array
      current_odd_number += 2 # adding 2 to an odd number gives us the next odd
    end
    element_tracker += 1 # You get the gist now? 
   #the next current_array/ triangle level should have +1 elements
    final_array << current_row_array # push to the final array = > [[1], [3, 5]...n]
    break if final_array.size == n # brk if we v n elements/levels in the final array
    # Recall that each element in the final array represents a level in the triangle
  end
  final_array.last.sum #call the Array#sum method on the lst element of the final_arr
end
​
p triangle(5) #=> 125
p triangle(50) #=> 125000
p triangle(3)  #=> 27

# try with an even number

arr = [['1', '8', '11'], ['2', '6', '13'], ['2', '12', '15'], ['1', '8', '9']]

arr.sort_by do |sub_arr|
  sub_arr.map do |num|
    num.to_i
  end
end

=begin
the sort_by method considers the return of the block and take the sub-array
as actual integers instead of string numbers.  Just with the integers themselves.
It tells sort by to output subarrays based on the integer valuse of the numbers.
Convert just for the purposes to compare by integer value rather than string value.


Why is sort not doing the sort by is doing. Bunch of elements in the collection based
on what you ask it to do.  Tell sort by to sort this colelction based on this condition.
  Ascending to descending order. Before I sort a number, I have to call what is a comparison
  operation.  I know when I sort this problem, what does sort by really do . Pass it a block and 
    know the return value of the block is how I want to sort this.  What happens underneath
    the hood, calling array object and sort by. Sorting the number 
    a<=>b comparison operation
    sort returns 0, 1, or -1. 
    1 if a > b
    0 if a ==b
    -1 if a < b
=end
    [["1", "99", "2"], ["1", "8", "9"], ["2", "6", "13"], ["2", "12", "15"]]
    [["1", "8", "9"], ["1", "99", "2"], ["2", "6", "13"], ["2", "12", "15"]]

    # p arr
# [1, 8, 11] -> ['1', '8', '11'] 2 
# [2, 6, 13] - > ['2', '6', '13']3
# [2, 12, 15]  -> ['2', '12', '15']4
# 1. [1, 8, 9]    -> ['1', '8', '9']

arr.sort do |sub_arr, sub_arr2|
  sub_arr.map { |num| num.to_i} <=> sub_arr2.map { |num| num.to_i}
end