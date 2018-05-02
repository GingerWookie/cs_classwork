-module(slowFibbo).
-export([slowFibbo/1]).
slowFibbo(0) -> 0;
slowFibbo(1) -> 1;
slowFibbo(N) -> slowFibbo(N-1) + slowFibbo(N-2).
