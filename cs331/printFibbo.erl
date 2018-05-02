-module (speedFibbo).
-export([fibbo/1]).
fibbo(N) -> fib(N, 0, 1).
fib(0, Result, _Next) -> Result;
fib(Iter, Result, Next) when Iter > 0 ->
io.format("~w~n", [Next]),
fib(Iter-1, Next, Result + Next).