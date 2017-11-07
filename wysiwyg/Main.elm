module Main exposing (..)

import BodyBuilder as B exposing (Node)
import Color exposing (Color)
import Elegant exposing (px, vh, percent, Modifiers)
import Box
import Background
import Display
import Types exposing (..)
import View
import Update


init : ( Model, Cmd Msg )
init =
    { element = defaultDiv 1
    , selectedId = 1
    , autoIncrement = 2
    }
        ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    Update.identity <|
        case msg of
            CreateP ->
                defaultP |> putElementAsChildIntoModel model

            CreateH1 ->
                defaultH1 |> putElementAsChildIntoModel model

            CreateGrid ->
                defaultGrid |> putElementAsChildIntoModel model

            SelectEl id ->
                model |> setSelectedId id

            ChangeBoxColor color ->
                model |> changeBoxColorOfCurrentElement color

            AddColumn ->
                model |> addColumnInGrid

            AddRow ->
                model


addChildToTree : Element msg -> Tree msg -> Tree msg
addChildToTree child parent =
    case parent of
        Block block ->
            block
                |> .children
                |> flip List.append [ child ]
                |> setChildrenIn block
                |> Block

        Grid grid ->
            grid
                |> .children
                |> flip List.append [ child ]
                |> setChildrenIn grid
                |> Grid

        GridItem gridItem ->
            gridItem
                |> .children
                |> flip List.append [ child ]
                |> setChildrenIn gridItem
                |> GridItem

        Text content ->
            Text content


addChildToElement : Element msg -> Element msg -> Element msg
addChildToElement ({ tree } as parent) child =
    tree
        |> addChildToTree child
        |> setTreeIn parent


changeBoxColorOfCurrentElement : Color.Color -> Model -> Model
changeBoxColorOfCurrentElement color ({ element, selectedId } as model) =
    element
        |> changeOnlyCurrentElementColor color selectedId
        |> setElementIn model


putElementAsChildIntoModel : Model -> (Int -> Element Msg) -> Model
putElementAsChildIntoModel ({ selectedId, element, autoIncrement } as model) childCreator =
    element
        |> putElementAsChildIntoSelectedElement selectedId (childCreator autoIncrement)
        |> setElementIn model
        |> setSelectedId autoIncrement
        |> setAutoIncrement (autoIncrement + 1)


putElementAsChildIntoSelectedElement : Int -> Element msg -> Element msg -> Element msg
putElementAsChildIntoSelectedElement selectedId child ({ id, tree } as parent) =
    if id == selectedId then
        tree
            |> addChildToTree child
            |> setTreeIn parent
    else
        tree
            |> addChildToChildren (putElementAsChildIntoSelectedElement selectedId child)
            |> setTreeIn parent


addChildToChildren : (Element msg -> Element msg) -> Tree msg -> Tree msg
addChildToChildren elementModifier tree =
    case tree of
        Block block ->
            block
                |> .children
                |> List.map elementModifier
                |> setChildrenIn block
                |> Block

        Grid grid ->
            grid
                |> .children
                |> List.map elementModifier
                |> setChildrenIn grid
                |> Grid

        GridItem gridItem ->
            gridItem
                |> .children
                |> List.map elementModifier
                |> setChildrenIn gridItem
                |> GridItem

        Text content ->
            Text content


addColumnInGrid : Model -> Model
addColumnInGrid model =
    model


changeOnlyCurrentElementColor : Color.Color -> Int -> Element msg -> Element msg
changeOnlyCurrentElementColor color selectedId ({ id, tree } as element) =
    if id == selectedId then
        tree
            |> changeColor color
            |> setTreeIn element
    else
        case tree of
            Block heading ->
                heading
                    |> .children
                    |> List.map (changeOnlyCurrentElementColor color selectedId)
                    |> setChildrenIn heading
                    |> Block
                    |> setTreeIn element

            Grid grid ->
                grid
                    |> .children
                    |> List.map (changeOnlyCurrentElementColor color selectedId)
                    |> setChildrenIn grid
                    |> Grid
                    |> setTreeIn element

            GridItem gridItem ->
                gridItem
                    |> .children
                    |> List.map (changeOnlyCurrentElementColor color selectedId)
                    |> setChildrenIn gridItem
                    |> GridItem
                    |> setTreeIn element

            Text content ->
                element


changeColorInAttributes :
    Color
    -> { a | style : Elegant.CommonStyle }
    -> { a | style : Elegant.CommonStyle }
changeColorInAttributes color attributes =
    attributes.style
        |> changeColorOfStyle color
        |> setStyleIn attributes


changeColor : Color.Color -> Tree msg -> Tree msg
changeColor color tree =
    case tree of
        Block heading ->
            heading
                |> .attributes
                |> changeColorInAttributes color
                |> setAttributesIn heading
                |> Block

        Grid grid ->
            grid
                |> .attributes
                |> changeColorInAttributes color
                |> setAttributesIn grid
                |> Grid

        GridItem gridItem ->
            gridItem
                |> .attributes
                |> changeColorInAttributes color
                |> setAttributesIn gridItem
                |> GridItem

        Text content ->
            Text content


changeColorOfStyle : Color.Color -> Elegant.CommonStyle -> Elegant.CommonStyle
changeColorOfStyle color ({ display } as style) =
    case display of
        Nothing ->
            Elegant.commonStyle (Just Display.None) [] Nothing

        Just displayyy ->
            case displayyy of
                Display.None ->
                    Elegant.commonStyle (Just Display.None) [] Nothing

                Display.ContentsWrapper ({ maybeBox } as contents) ->
                    let
                        newBox =
                            case maybeBox of
                                Nothing ->
                                    let
                                        defaultBox =
                                            Box.default

                                        defaultBackground =
                                            Background.default
                                    in
                                        { defaultBox | background = Just { defaultBackground | color = Just color } }

                                Just box ->
                                    let
                                        background =
                                            Maybe.withDefault Background.default box.background
                                    in
                                        { box | background = Just { background | color = Just color } }
                    in
                        { style | display = Just (Display.ContentsWrapper { contents | maybeBox = Just newBox }) }


main : Program Never Model Msg
main =
    B.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = View.view
        }