module Responsive exposing (isMobile)


{-| Gibt an ob die Fensterbreite einem Smartphone entspricht (unter 600px).
-}
isMobile : Int -> Bool
isMobile windowWidth =
    windowWidth < 600
