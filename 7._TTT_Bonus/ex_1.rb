# Write a method called `joinor` that will produce the following result:
=begin
input: array, possible extra parameters like semi colon and word
output: string of the elements of the array conjoined with the word 'or' which is the default

GOAL: write a method that takes an array, a conjoiner and a default 'or' as three parameters and returns the elements in a string joined by default with the word 'or' or conjoined with the arguments given

E: [1, 2] => "1 or 2" => default 'or' used
([1, 2, 3], '; ') => '1; 2; or 3'
([1, 2, 3], ', ', 'and') => "1, 2, and 3"

D: array => string

A: initialize empty string object
three parameters: array, punctuation, conjunction = 'or'
output the statement with the elements in order
iterate over the elements in the array
 - add a punctuation mark onto all the elements except for the last one
 - append the conjunction in front of the last element
 - push all of this info into the empty string object
return the new string
=end
def joinor(array, punctuation = ',', conjunction = 'or')
  string_output = ''
  array.map do |num|
    #num = num.to_s
    if num == array[-1] 
      string_output << conjunction + " #{num.to_s}"
    elsif array.length == 2
      string_output << "#{num} "
    else
      string_output << "#{num.to_s}" + ', '
    end
  end
  string_output
end

p joinor([1, 2])                   # => "1 or 2"
p joinor([1, 2, 3])                # => "1, 2, or 3"
p joinor([1, 2, 3], '; ')          # => "1; 2; or 3"
p joinor([1, 2, 3], ', ', 'and')   # => "1, 2, and 3"

# Then, use this method in the TTT game when prompting the user to mark a square.