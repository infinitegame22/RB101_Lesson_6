require 'pry'

def select_nums(arr)
  new_arr = []
  arr.each do |num|
    new_arr << num if num.odd? <= 15 || num % 3 == 0
  end
  new_arr
end

p select_nums([1, 2, 5, 6, 9, 12, 15, 17, 19, 21])
