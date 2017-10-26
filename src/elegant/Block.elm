module Block exposing (..)

import Helpers.Shared exposing (..)
import Display.Overflow
import Display
import Dimensions


overflowHidden : Modifier Display.BlockDetails
overflowHidden =
    Display.overflow [ Display.Overflow.overflowXY Display.Overflow.hidden ]


alignCenter : Modifier Display.BlockDetails
alignCenter =
    Display.alignment Display.center


alignRight : Modifier Display.BlockDetails
alignRight =
    Display.alignment Display.right


alignLeft : Modifier Display.BlockDetails
alignLeft =
    Display.alignment Display.left


maxWidth : SizeUnit -> Modifier Display.BlockDetails
maxWidth size =
    Display.dimensions [ Dimensions.maxWidth size ]


width : SizeUnit -> Modifier Display.BlockDetails
width size =
    Display.dimensions [ Dimensions.width size ]