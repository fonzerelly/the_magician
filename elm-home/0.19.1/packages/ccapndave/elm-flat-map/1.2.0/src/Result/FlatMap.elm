module Result.FlatMap exposing (flatMap, flatMap2, flatMap3, flatMap4, flatMap5)

{-| This module implements the `flatMap` combinator for `Result`. This allows you to call functions
that return a `Result` with arguments that are also `Result`s without having to worry about ending up
with a `Result (Result a)` return type.

In the event of an error only the first error is returned as there is no monoid in Elm and its
annoying to have to pass in a concatenation function.


# FlatMaps

@docs flatMap, flatMap2, flatMap3, flatMap4, flatMap5

-}


join : Result x (Result x a) -> Result x a
join mx =
    case mx of
        Ok x ->
            x

        Err err ->
            Err err


{-| -}
flatMap : (a -> Result x b) -> Result x a -> Result x b
flatMap f result =
    Result.map f result
        |> join


{-| -}
flatMap2 : (a -> b -> Result x c) -> Result x a -> Result x b -> Result x c
flatMap2 f result1 result2 =
    Result.map2 f result1 result2
        |> join


{-| -}
flatMap3 : (a -> b -> c -> Result x d) -> Result x a -> Result x b -> Result x c -> Result x d
flatMap3 f result1 result2 result3 =
    Result.map3 f result1 result2 result3
        |> join


{-| -}
flatMap4 : (a -> b -> c -> d -> Result x e) -> Result x a -> Result x b -> Result x c -> Result x d -> Result x e
flatMap4 f result1 result2 result3 result4 =
    Result.map4 f result1 result2 result3 result4
        |> join


{-| -}
flatMap5 : (a -> b -> c -> d -> e -> Result x f) -> Result x a -> Result x b -> Result x c -> Result x d -> Result x e -> Result x f
flatMap5 f result1 result2 result3 result4 result5 =
    Result.map5 f result1 result2 result3 result4 result5
        |> join
