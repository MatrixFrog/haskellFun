While randomly browsing StackOverflow today, I found someone mention the "99 problems" for Haskell. The 9th and 10th problems inspired me to come up with this little bit of Haskelly goodness. I'm sure I'm not the first to come up with it but I thought I'd share it anyway.

First of all, problem 9 from the 99 problems says:

  Pack consecutive duplicates of list elements into sublists. If a list contains repeated elements they should be placed in separate sublists.
  Example:
  *Main> pack ['a', 'a', 'a', 'a', 'b', 'c', 'c', 'a', 'a', 'd', 'e', 'e', 'e', 'e']
  ["aaaa","b","cc","aa","d","eeee"]

And here's my solution:

> pack :: (Eq a) => [a] -> [[a]]
> pack [] = []
> pack (x:xs) = takeWhile (== x) (x:xs) : pack (dropWhile (== x) (x:xs))

Then problem 10 builds on that by asking:

  Run-length encoding of a list. Use the result of problem 9 to implement the so-called run-length encoding data compression method. Consecutive duplicates of elements are encoded as tuples (N, E) where N is the number of duplicates of the element E.
  Example:
  *Main> encode "aaaabccaadeeee"
  [(4,'a'),(1,'b'),(2,'c'),(2,'a'),(1,'d'),(4,'e')]

My solution was:

> encodeP10 :: (Eq a) => [a] -> [(Int,a)]
> encodeP10 = map (\xs -> (length xs, head xs)) . pack

This immediately reminded me of the "See and say" sequence. Apparently Wikipedia calls it the "Look and say" sequence (http://en.wikipedia.org/wiki/Look-and-say_sequence) but anyway: Here's how it works: You start with the number 1. Then to get the next number in the sequence you describe what you're seeing. In this case, you're seeing the number 1, one time, so "one 1" or "11". To get the next number after that, you describe what you see again: "two 1s" or "21". Now you have a 2 followed by a 1: "one 2, one 1" or "1211". Then "one 1, one 2, two 1s" (111221) then "three 1s, two 2s, one 1" (312211) and so on. 

To start this off, we need a function that takes a single list of repeated digits, like [2,2,2,2,2], and returns the "description" of that list, like [5,2]. I'm using a list [5,2] instead of a tuple (5,2) because we're going to concatenate it with other such lists.

The type is 

> describe :: [Int] -> [Int]

because this sequence will only make sense for integers, and the implementation is just

> describe xs = [length xs, head xs]

This "encode" function is just like the one from problem 10, except it returns a flat list instead of a list of tuples:
encode [2,1] = [1,2,1,1]

> encode :: [Int] -> [Int]
> encode = concatMap describe . pack

If I used map instead, I would get [[1,2],[1,1]]. concatMap gives me one big flat list.

I set the seed to 1 because that's how the sequence goes, by convention. But once I get it working, I can seed it with a different number and see if anything interesting happens.

> seed = [1]
> seeAndSaySequence :: [[Int]]
> seeAndSaySequence = seed:(map encode seeAndSaySequence)

This of course uses the clever Haskelly trick of defining a list in terms of itself. So the Nth element of the list is (encode X) where X is the (N-1)th element.

Now let's get a function that takes the list [1,2,1,1] to the number 1211, so that the output looks nicer. You want to use Integer here, not Int, because otherwise you start getting weird overflow errors very quickly. I wish Haskell was like Python and just switched seamlessly between 32-bit integers and "infinitely large" integers.

> listToInt :: [Int] -> Integer
> listToInt = read . (concatMap show)

Then we map this function over the sequence, and we're done!

> readableSeeAndSay :: [Integer]
> readableSeeAndSay = map listToInt seeAndSaySequence

For example, to use it in an interactive session, type "take 10 readableSeeAndSay":
[1,11,21,1211,111221,312211,13112221,1113213211,31131211131221,13211311123113112211]

The following exercises are left to the reader (or to me in the future, if I ever get around to them):

1. Prove that the sequence will never include a digit higher than 3.
2. Try setting the seed to 2, 3, or some other number, and see what interesting patterns emerge. I guess two digit numbers are allowed, and you would specify them as [2,4] or whatever. 
3. Have someone else pick a seed, and then have them show you the value of (readableSeeAndSay !! 10) or something. See if you can reverse the sequence generation process, either mentally or programmatically, to figure out what seed they chose.
