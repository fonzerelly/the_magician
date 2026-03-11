module List.FlatMap exposing (flatMap, flatMap2, flatMap3, flatMap4, flatMap5)

{-| This module implements the `flatMap` combinator for `List`. This allows you to call functions
that return a `List` with arguments that are also `List`s without having to worry about ending up
with a `List (List a)` return type.


# FlatMaps

@docs flatMap, flatMap2, flatMap3, flatMap4, flatMap5

-}

import List exposing (concatMap)


join : List (List a) -> List a
join =
    List.foldr (++) []


{-| -}
flatMap : (a -> List b) -> List a -> List b
flatMap f list =
    List.map f list
        |> join


{-| -}
flatMap2 : (a -> b -> List c) -> List a -> List b -> List c
flatMap2 f list1 list2 =
    List.map2 f list1 list2
        |> join


{-| -}
flatMap3 : (a -> b -> c -> List d) -> List a -> List b -> List c -> List d
flatMap3 f list1 list2 list3 =
    List.map3 f list1 list2 list3
        |> join


{-| -}
flatMap4 : (a -> b -> c -> d -> List e) -> List a -> List b -> List c -> List d -> List e
flatMap4 f list1 list2 list3 list4 =
    List.map4 f list1 list2 list3 list4
        |> join


{-| -}
flatMap5 : (a -> b -> c -> d -> e -> List f) -> List a -> List b -> List c -> List d -> List e -> List f
flatMap5 f list1 list2 list3 list4 list5 =
    List.map5 f list1 list2 list3 list4 list5
        |> join
