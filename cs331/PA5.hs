-- PA5.hs
-- Dylan Tucker

-- For CS F331 / CSCE A331 Spring 2018
-- Solutions to Assignment 5 Exercise B
-- Start provided by Dr. Chappel

module PA5 where

listLength [] = 0
listLength (x:xs) = 1 + listLength(xs)

-- collatz
collatz :: Integer -> [Integer]
collatz 1 = []
collatz n 
        | odd n = 3*n+1:collatz(3*n+1)
        | even n = div n 2: collatz(div n 2) 
-- counter
counter :: [Integer] -> [Integer]
counter = map collatz xs

-- collatzCounts
collatzCounts :: [Integer]
collatzCounts = collatz 2
  


-- findList
findList :: Eq a => [a] -> [a] -> Maybe Int
findList _ _ = Just 42  -- DUMMY; REWRITE THIS!!!


-- operator ##
(##) :: Eq a => [a] -> [a] -> Int
_ ## _ = 42  -- DUMMY; REWRITE THIS!!!


-- filterAB
filterAB :: (a -> Bool) -> [a] -> [b] -> [b]
filterAB _ _ bs = bs  -- DUMMY; REWRITE THIS!!!


-- sumEvenOdd
sumEvenOdd :: Num a => [a] -> (a, a)
{-
  The assignment requires sumEvenOdd to be written using a fold.
  Something like this:

    sumEvenOdd xs = fold* ... xs where
        ...

  Above, "..." should be replaced by other code. The "fold*" must be
  one of the following: foldl, foldr, foldl1, foldr1.
-}
sumEvenOdd _ = (0, 0)  -- DUMMY; REWRITE THIS!!!

--listLength
--from list.hs example from Dr.Chappel
