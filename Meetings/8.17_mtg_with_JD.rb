=begin

1. Given a string, Alternate eaech character with uppercase and lowercase letters starting with the first letter as uppercase.

Set cap variable to true
iterate through each strings character
  if cap is true
    set cap to false
    upcase the character
  if cap is false
    set cap to true
    downcase the character
join the characters into a string


=end
def alternate_caps(string)
  caps_variable = true
  string.chars.map do |char|
    if caps_variable
      caps_variable = false
      char.upcase
    else
      caps_variable = true
      char.downcase
    end
  end.join
end

p alternate_caps('Hello Dolly')
p alternate_caps('Howdy cowboy!')

def staggered_case(string)
  cap = true
  string.chars.map do |chr|
  if cap
    cap = false
    chr.upcase
  else
    cap = true
    chr.downcase
  end
  end.join
end



=begin

you have n number of switches starting in the off position. for n times for each round starting at round 1 and ending at n, iterate through the switches. if a switches number is evenly divisible by the current round number, switch it's position. 3 - 3, 6, 9
return an array of the switches that are still on (as numbers based on their position)

Set switches array to array of size 'n' with all elements false
from 1 to n iterate through every round
  iterate through every switch tracking switch number
    if the current switch number (reference from 1, not 0) is evenly divisible by the round number
        alternate the switch to the opposite of it's current boolean
helper method-

set a empty new array to collect the switches that are currently set to true
iterate through the switches array tracking the index value
  if the switch is set to true
    push the index value + 1 into the new_array
return the new array
=end

def lights_on(n)
  switches_array = Array.new(n, false)
  (1..n).each do |round|
    switches_array.each.with_index do |element, idx|
      if (idx + 1) % round == 0
        switches_array[idx] = !element
      end
    end
  end
  switches_array
end

p lights_on(2)

p lights_on(3) #== [true, false, false]

=begin

you have n number of switches starting in the off position. for n times for each round starting at round 1 and ending at n, iterate through the switches. if a switches number is evenly divisible by the current round number, switch it's position. 3 - 3, 6, 9
return an array of the switches that are still on (as numbers based on their position)

Set switches array to array of size 'n' with all elements false
from 1 to n iterate through every round
  iterate through every switch tracking switch number
    if the current switch number (reference from 1, not 0) is evenly divisible by the round number
        alternate the switch to the opposite of it's current boolean
helper method-

set a empty new array to collect the switches that are currently set to true
iterate through the switches array tracking the index value
  if the switch element is set to true
    push the index value + 1 into the new_array
return the new array
=end

def lights_on(n)
  switches_array = Array.new(n, false)
  (1..n).each do |round|
    switches_array.each.with_index do |element, idx|
      if (idx + 1) % round == 0
        switches_array[idx] = !element
      end
    end
  end
  collect_switches(switches_array)
end

def collect_switches(switches_array)
  final_on_array = []

  switches_array.each.with_index do |_, index|
    if switches_array[index] == true
      final_on_array << (index + 1)
    end
  end
  final_on_array
end

p lights_on(2)

p lights_on(3)
p lights_on(4)

def lights_on(n)
  on_switches = []
  switch = 1
  until switch ** 2 > n
    on_switches << switch ** 2
    switch += 1
  end
  on_switches
end

=begin

https://launchschool.com/exercises/e0500589

In the easy exercises, we worked on a problem where we had to count the number of uppercase and lowercase characters, as well as characters that were neither of those two. Now we want to go one step further.

Write a method that takes a string, and then returns a hash that contains 3 entries: one represents the percentage of characters in the string that are lowercase letters, one the percentage of characters that are uppercase letters, and one the percentage of characters that are neither.

You may assume that the string will always contain at least one character.

P:
input: String
output: Hash

Goal: counting the number of instances and returning three percentatges in a Hash

E: letter_percentages('abCdef 123') == { lowercase: 50.0, uppercase: 10.0, neither: 40.0 }

lowercase: a b d e f 5/10 
uppercase: C 1/10
neither: 4/10

D: string     array of characters?                  -> hash

A: 
Initialize an empty hash with three keys, lowercase, uppercase, and neither
Initialize lowercase count, uppercase count, and neither count for later math use.
Store length of string in its own variable
Convert the string to characters Array
  iterate over the characters
    if character is lowercase (
      add to lowercase count by 1
    elsif character is uppercase
      increment uppercase count by 1
    otherwise increment neither count by 1
  divide each count by the string length and assign the output to the appropriate value in the hash
return the Hash

Examples
=end


def letter_percentages(string)
  percentage_hash = { lowercase: 0, uppercase: 0, neither: 0 }

  lowercase_count = 0
  uppercase_count = 0
  neither_count   = 0
  string_length   = string.length

  string.chars.each do |char|
    if ('a'..'z').include?(char)
      lowercase_count += 1
    elsif ('A'..'Z').include?(char)
      uppercase_count += 1
    else
      neither_count += 1
    end
  end

  p lowercase_count
  p uppercase_count
  p neither_count
  

  percentage_hash[:lowercase]= (lowercase_count.to_f/string_length) * 100
  percentage_hash[:uppercase]= (uppercase_count.to_f/string_length) * 100
  percentage_hash[:neither]= (neither_count.to_f/string_length) * 100

  percentage_hash
end



p letter_percentages('abCdef 123') == { lowercase: 50.0, uppercase: 10.0, neither: 40.0 }
p letter_percentages('AbCd +Ef') == { lowercase: 37.5, uppercase: 37.5, neither: 25.0 }
p letter_percentages('123') == { lowercase: 0.0, uppercase: 0.0, neither: 100.0 }