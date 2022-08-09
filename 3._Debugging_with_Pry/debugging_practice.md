## Steps to Debugging

The debugging process baries tremendously from person to person, but below are some steps I can follow early on until I've started to hone my own habits.

1. Reproduce the Error

  The first step in debugging any problem is usually reproducing the problem. Programmers need a deterministic way to consistently reproduce the problem, and only then can we start to isolate the root cause. There's an old joke where programmers will say "works on my machine" because they can't reproduce an error that occurs in the production environment. This will become mroe important as I build more sophisticated applications with various external dependencies and moving parts. Reproducing the exact error will often end up being more than half the battle in many tricky situations. 

2. Determine the Boundaries of the Error

  Once I can consistently reproduce the problem, it's time to tweak the data that caused the error. For example, the stack trace earlier was generated by this code `post.categories << news`. Does calling `post.categories` cause issues? What about just calling `post`? What happens if we try to append a different object, like this: `post.categories << sports`? How does modifying the data affect the program behavior? Do we get expected errors, or does a new error occur that sheds light on the underlying problem?

  What we're trying to modify the data or code to get an idea of the scope of the error and determine the boundaries of the problem. This will lead to a deeper understanding of the problem, and allow us to implement a better solution. Most problems can be solved in many ways, and the deeper I understand teh problem, the more holistic the solution will be.

3. Trace the Code

  Once I understand the boundaries of the problem, it's time to trace the code. 

```Ruby
def car(new_car)
  make = make(new_car)
  model = model(new_car)
  [make, model]
end

def make(new_car)
  new_car.split(" ")[0]
end

def model(new_car)
  new_car.split(" ")[2]
end

make, model = car("Ford Mustang")
make == "Ford"
model.start_with?("M")
```
The code is fairly straightforward. One aspect of it that's a bit tricky is the return value of the `car` method and the assignment from that method to local variables `make` and `model`. When an array is assignted to two variables on the same line, each element of that array gets assigned to one of the variables. In the example above, the first array element gets assigned to `make` and the second array element gets assigned to `model`. This type of assignment, where we assign more than one value on the same line, is called "multiple assignment".

When we try to see if `model` starts with the character `"M"`, we get an error.  After reproducing the problem consistently and testing various data inputs, I notice that `model` always returns `nil`. In this example, `make` is expected to be `"Ford"` and `model` is expected to be `"Mustang"`. It looks like we've got a bug here.

Let's trace the code backwards. When I first call `car`, a string is passed in as an argument. The string represented by the local variable `new_car` is passed into two helper methods: `make` and `model`. Inside each of these methods, the intention is to split `new_car` into two new strings: `"Ford"` and `"Mustang"`. The `make` method should return `"Ford"` and the `model` method should return `"Mustang"`. In this case, the `make` method returns the correct value but the `model` does not. Based on these observations, we know that the bu in this code originates from the `model` method. This is called *trapping the error*. 

4. Understand the Problem Well

  After narrowing the source of the bug to the `model` method, it's time to break down the code within the method. We know that the return value of this method is always `nil`, so let's inspect each return value in order to pinpoint the source of the unexpected return value. 

  ```Ruby
  def model(new_car)
    new_car # => "Ford Mustang"
  end
  ```
  That's the expected return value of `new_car`. No issues so far.

  ```Ruby
  def model(new_car)
    new_car.split(" ") # => ["Ford", "Mustang"]
  end
  ```
  The return value here is an array, which is expected based on our knowledge of how `#split` works.

  ```Ruby
  def model(new_car)
    new_car.split(" ")[2] # => nil
  end
  ```
  Aha! It looks like the unexpected return value here is the result of calling `[2]` on the `["Ford", "Mustang"]` array. The return value is `nil` because there is no element at index `2` in this array. Since arrays have a zero-based index, we need to call `[1]` in order to return `"Mustang"` from the array. 

  ```Ruby
  def model(new_car)
    new_car.split(" ") # => "Mustang"
  end
  ```

5. Implement a Fix

  There are often multiple ways and multiple layers in which I can make the fix. For example, we could suppress the error from being thrown with this code: 

  ```Ruby
  model.start_with?("M") rescue false # => false
  ```
We'll still have the original error in the `model` method, though. In some cases, you'll be using a library or code that I can't modify. In those situations, I have no choice but to deal with edge cases in my own code. In this example, we should fix the offending code in the `model` method. 

One very important note is to fix *one problem at a time*. It's common to notice additional edge cases or problems as I'm implementing a fix. Resist the urge to fix multiple problems at once. 

*** --- ***
I'll almost never want to use the trailing `rescue` like we did in the above example. It's usually a **code smell** that I haven't thought carefully about the possible problems that could go wrong, and therefore I haven't thought about how to handle the potential error conditions. Also, by not specifying any particular error to recue, I'm suppressing all possible errors, including potentially very destructive ones thta may impact your program in unexpected ways. 
*** --- ***

6. Test the Fix

  Finally, after implementing a fix, make sure to verify that the code fixed the problem by using a similar set of tests from step #2. After I learn about automated testing, I'll want to add an additional automated test to prevent regression. For now, I can test manually. 

## Techniques for Debugging

1. Line by Line

  My best debugging tool is my patience, which is why we mentioned temperament first in this article. Most bugs in my code will be from overlooking a detail, rather than a complete misunderstanding of a concept. Being careful, patient and developing a habit of reading code line-by-line, word-by-word, character-by-character is my most powerful ability as a programmer. If I am naturally impatient or like to gloss over details, I must train myself to behave differently when programming. All other debugging tips and tools won't matter if I am not detail oriented.

2. Rubber Duck

  Rubber duck debugging sounds crazy, but its effectiveness is so well known that it has its own Wikipedia page.  The process centers around using some object, like a care bear