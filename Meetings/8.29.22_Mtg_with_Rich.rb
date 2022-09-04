def uppercase(value)
  value.upcase!
end

name = 'William'
uppercase(name)
puts name #

=begin
On line 5 the local variable `name` is initialized to the string object 'William'. On line 6, `name` is passed to the method `uppercase` as an argument. On lines 1 - 3 we see the method `uppercase` defined.  The string object `'William'` is passed in as the argument, and is assigned to the local variable `value`. 



On line 2, we invoke the `upcase` with a `!` method which mutates in place the object `'William'`` referenced by the variable `value`.  



So on line 7 the output is 'WILLIAM' and the return value is nil. This demonstrates a mutating method that mutates the original object in place, and acts as pass by reference.
=end


Front: name = 'William'
Back: the local variable `name` is initialized to the string object 'William'. 

Template: The local variable `name` is initialized to the string `William`. 

# outputs if we were using a pass by value strategy:

def plus(x, y)
  x = x + y # => 5
end

a = 3 
b = plus(a, 2) # =  (3, 2)

puts a # => 3
puts b # => 5

=begin
On line 7, the local variable `a` is initialized to the integer 3. On line 8, the local variable `b` is initialized to the result of invoking the method `plus` and passing it the two arguments `a` and 2. 

Our `plus` method is defined on lines 3 - 5. The local variable `a` is pointing to the integer 3 and is assigned to the local variable `x`. The integer argument 2 is assigned to the local variable `y`. `x` is reassigned to the result of adding `x` and `y`, which is 5.  The integer output on line 10 is 3. Reassignment is not a mutating method in Ruby.  Thus, `a` maintains its connection to its original object. And `b` is assigned the return value of our method invocation which is 5 in this case.  
=end

def increment(number)
  p number.object_id
  number + 1
end

number = 1
p number.object_id 
two = increment(number)
p number.object_id

=begin
the integer  has a permanent space in computer memory. Will its object id always be the same? 
AXE vs IS


=end