module Elegant
    exposing
        ( CommonStyle
        , SizeUnit
        , Style
        , classes
        , color
        , commonStyle
        , commonStyleToCss
        , commonStyleToStyle
        , deg
        , em
        , emptyStyle
        , inlineStyle
        , opposite
        , percent
        , pt
        , px
        , rad
        , rem
        , screenWidthBetween
        , screenWidthGE
        , screenWidthLE
        , setSuffix
        , style
        , styleToCss
        , toCommonStyle
        , toInlineStyles
        , vh
        , vw
        , withScreenWidth
        )

{-|

@docs CommonStyle
@docs commonStyle
@docs commonStyleToCss
@docs commonStyleToStyle
@docs SizeUnit
@docs Style
@docs classes
@docs deg
@docs rad
@docs color
@docs em
@docs emptyStyle
@docs inlineStyle
@docs opposite
@docs percent
@docs pt
@docs px
@docs rem
@docs screenWidthBetween
@docs screenWidthGE
@docs screenWidthLE
@docs setSuffix
@docs style
@docs styleToCss
@docs toCommonStyle
@docs toInlineStyles
@docs vh
@docs vw
@docs withScreenWidth

-}

import Elegant.Display as Display exposing (DisplayBox)
import Elegant.Helpers.Shared exposing (..)
import Elegant.Helpers.Style as CommonStyle
import Elegant.Internals.Convert
import Elegant.Internals.Setters exposing (..)
import Html exposing (Html)
import Html.Attributes
import Modifiers exposing (..)


-- import Native.BodyBuilder


{-| Contains all style for an element used with Elegant.
-}
type Style
    = Style CommonStyle.Style


{-| -}
type alias CommonStyle =
    CommonStyle.Style


{-| -}
commonStyle :
    Maybe DisplayBox
    -> List CommonStyle.ScreenWidth
    -> Maybe String
    -> CommonStyle.Style
commonStyle =
    CommonStyle.Style


{-| -}
commonStyleToStyle : CommonStyle -> Style
commonStyleToStyle =
    Style


{-| -}
style : DisplayBox -> Style
style display =
    Style
        { display = Just display
        , screenWidths = []
        , suffix = Nothing
        }


{-| -}
emptyStyle : Style
emptyStyle =
    Style
        { display = Nothing
        , screenWidths = []
        , suffix = Nothing
        }


{-| -}
setSuffix : String -> Style -> Style
setSuffix value (Style style_) =
    style_
        |> CommonStyle.setSuffix value
        |> Style


{-| -}
withScreenWidth : List CommonStyle.ScreenWidth -> Modifier Style
withScreenWidth screenWidth (Style style_) =
    style_
        |> setScreenWidths screenWidth
        |> Style


{-| -}
screenWidthBetween : Int -> Int -> DisplayBox -> Modifier Style
screenWidthBetween min max betweenStyle (Style style_) =
    style_
        |> addScreenWidth
            { min = Just min
            , max = Just max
            , style = betweenStyle
            }
        |> Style


{-| -}
screenWidthGE : Int -> DisplayBox -> Modifier Style
screenWidthGE min greaterStyle (Style style_) =
    style_
        |> addScreenWidth
            { min = Just min
            , max = Nothing
            , style = greaterStyle
            }
        |> Style


{-| -}
screenWidthLE : Int -> DisplayBox -> Modifier Style
screenWidthLE max lessStyle (Style style_) =
    style_
        |> addScreenWidth
            { min = Nothing
            , max = Just max
            , style = lessStyle
            }
        |> Style



-- Inline styling


{-| -}
toInlineStyles : Style -> List ( String, String )
toInlineStyles (Style style_) =
    style_.display
        |> Maybe.map Elegant.Internals.Convert.computeStyle
        |> Maybe.withDefault []


{-| -}
inlineStyle : DisplayBox -> List (Html.Attribute msg)
inlineStyle =
    style
        >> toInlineStyles
        >> List.map (\( a, b ) -> Html.Attributes.style a b)



{-
    ███████    ███████    ███████
   ████████   ████████   ████████
   ████       █████      █████
   ███        ████       ████
   ███        ███████    ███████
   ███         ███████    ███████
   ███            ████       ████
   ████          █████      █████
   ████████   ████████   ████████
    ███████   ███████    ███████
-}


{-| Generate all the classes of a list of Styles
-}
classes : Style -> String
classes (Style style_) =
    style_
        |> Elegant.Internals.Convert.classesNamesFromStyle
        |> String.join " "



-- stylesToCss : List Style -> List String
-- stylesToCss styles =
--     styles
--         |> List.map toCommonStyle
--         |> Elegant.Internals.Convert.stylesToCss


{-| -}
commonStyleToCss : CommonStyle -> List ( String, String )
commonStyleToCss style_ =
    style_
        |> Elegant.Internals.Convert.fetchStylesOrCompute ""


{-| -}
styleToCss : Style -> List ( String, String )
styleToCss (Style style_) =
    commonStyleToCss style_


{-| -}
toCommonStyle : Style -> CommonStyle.Style
toCommonStyle (Style style_) =
    style_



-- Alias


{-| -}
type alias SizeUnit =
    Elegant.Helpers.Shared.SizeUnit


{-| -}
px : Int -> SizeUnit
px =
    Px


{-| -}
pt : Int -> SizeUnit
pt =
    Pt


{-| -}
percent : Float -> SizeUnit
percent =
    Percent


{-| -}
vh : Float -> SizeUnit
vh =
    Vh


{-| -}
vw : Float -> SizeUnit
vw =
    Vw


{-| -}
em : Float -> SizeUnit
em =
    Em


{-| -}
rem : Float -> SizeUnit
rem =
    Rem


{-| -}
deg : Float -> Angle
deg =
    Deg


{-| -}
rad : Float -> Angle
rad =
    Rad


{-| Calculate the opposite of a size unit value.
Ex : opposite (Px 2) == Px -2
-}
opposite : SizeUnit -> SizeUnit
opposite unit =
    case unit of
        Px a ->
            Px -a

        Pt a ->
            Pt -a

        Percent a ->
            Percent -a

        Vh a ->
            Vh -a

        Vw a ->
            Vw -a

        Em a ->
            Em -a

        Rem a ->
            Rem -a


{-| -}
color : a -> { b | color : Maybe a } -> { b | color : Maybe a }
color =
    setColor << Just
