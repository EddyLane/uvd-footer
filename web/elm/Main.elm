import Html exposing (..)
import Html.Attributes exposing (..)

(=>) = (,)

building : Html
building =
   div [] [
     img [ src "images/jenkins-faded.png", class "card__avatar" ] [],
     h3 [ class "card__name" ] [ text "Title of the build" ],
     div [ class "progress progress-striped active" ] [
       div [ class "progress-bar", style [ "width" => "100%" ] ] []
     ],
     p [ class "card__footer" ] [ text "2015-06-04" ]
   ]

view : Html
view =
  div []
      [
        div [ class "l-panel l-panel--dark l-panel--fluid"] [

          h1 [ class "heading" ] [
            span [ class "l-inner" ]
                 [ text "Building ",
                   img [ src "images/lego.png" ] [ ]
                 ]
          ],

          div [ class "l-inner" ] [
            div [ class "leeroy-no-builds" ] [ text "Jenkins gonna break yo builds!" ],
            ul [ class "l-flex l-flex--around leeroy leeroy--building" ]
               [  li [ class "card" ] [ building ]
               ]
          ]

        ],

        div [ class "l-panel l-panel--dark l-panel--fluid"] [

          h1 [ class "heading" ] [
            span [ class "l-inner" ]
                 [ text "Last 5 Builds"]
          ],

          div [ class "l-inner" ] [
            div [ class "l-flex leeroy" ] []
          ]

        ]

    ]


main = view
