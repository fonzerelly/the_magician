module Maybe.FlatMap exposing (flatMap, flatMap2, flatMap3, flatMap4, flatMap5)

{-| This module implements the `flatMap` combinator for `Maybe`. This allows you to call functions
that return a `Maybe` with arguments that are also `Maybe`s without having to worry about ending up
with a `Maybe (Maybe a)` return type.

For example:

    getHeadFromMaybeList : Maybe List -> Maybe a
    getHeadFromMaybeList =
        flatMap List.head


# FlatMaps

@docs flatMap, flatMap2, flatMap3, flatMap4, flatMap5

-}


join : Maybe (Maybe a) -> Maybe a
join mx =
    case mx of
        Just x ->
            x

        Nothing ->
            Nothing


{-| -}
flatMap : (a -> Maybe b) -> Maybe a -> Maybe b
flatMap f maybe =
    Maybe.map f maybe
        |> join


{-| -}
flatMap2 : (a -> b -> Maybe c) -> Maybe a -> Maybe b -> Maybe c
flatMap2 f maybe1 maybe2 =
    Maybe.map2 f maybe1 maybe2
        |> join


{-| -}
flatMap3 : (a -> b -> c -> Maybe d) -> Maybe a -> Maybe b -> Maybe c -> Maybe d
flatMap3 f maybe1 maybe2 maybe3 =
    Maybe.map3 f maybe1 maybe2 maybe3
        |> join


{-| -}
flatMap4 : (a -> b -> c -> d -> Maybe e) -> Maybe a -> Maybe b -> Maybe c -> Maybe d -> Maybe e
flatMap4 f maybe1 maybe2 maybe3 maybe4 =
    Maybe.map4 f maybe1 maybe2 maybe3 maybe4
        |> join


{-| -}
flatMap5 : (a -> b -> c -> d -> e -> Maybe f) -> Maybe a -> Maybe b -> Maybe c -> Maybe d -> Maybe e -> Maybe f
flatMap5 f maybe1 maybe2 maybe3 maybe4 maybe5 =
    Maybe.map5 f maybe1 maybe2 maybe3 maybe4 maybe5
        |> join
