require 'pry'

def double_num(num)
  num * 2
  
end

arr = [1, 2, 3].map do |num|
  double_num(num)
  binding.pry
end

p arr