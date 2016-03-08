import Html exposing (..)
import Html.Attributes exposing (..)
import StartApp
import Effects exposing (Effects, Never)
import String
import Transit
import TransitStyle

--> MODEL

type alias Job =
    { displayName: String,
      duration: Int,
      estimatedDuration: Int,
      fullDisplayName: String,
      image: String,
      number: Int,
      published: String,
      formattedPublished: String,
      result: Maybe String,
      timestamp: Int,
      title: String,
      culprits: List String
    }

type alias Model =
    Transit.WithTransition { jobs: List Job }


emptyModel : Model
emptyModel = ({ jobs = [], transition = Transit.initial })

--> UPDATE

type Action
    = NoOp
    | AddJob Job
    | SetJobs (List Job)

update : Action -> Model -> (Model, Effects Action)
update action model =
    case action of

    NoOp ->
        (model, Effects.none)

    AddJob job ->
        ({ model | jobs = job :: model.jobs }, Effects.none)

    SetJobs jobs ->
        ({ model | jobs = jobs }, Effects.none)

--> VIEW

(=>) = (,)

completedBuild : Job -> Html
completedBuild job =
  let
    status = Maybe.withDefault "" job.result
    statusImage = if status == "SUCCESS" then "images/tick.png" else "images/cross.png"
    culpritImage name = "images/culprits/" ++ name ++ ".jpg"
    culprit e = li [] [ img [ src (culpritImage e), class "card__avatar", style [ "width" => "50px", "height" => "50px" ] ] [] ]
  in
    li [ class "card" ] [
      div [] [
        img [ src job.image, class "card__avatar" ] [],
        h3 [ class "card__name" ] [ text job.displayName ],
        img [ src statusImage, class "card__status" ] [],
        ul [ class "list l-flex card__culprits" ] (List.map culprit job.culprits),
        p [ class "card__footer" ] [ text job.formattedPublished ]
      ]
    ]

buildingBuild : Transit.Transition -> Job -> Html
buildingBuild transition job =
     li [ class "card", style (TransitStyle.fadeSlideLeft 5000 transition) ] [
       img [ src job.image, class "card__avatar" ] [],
       h3 [ class "card__name" ] [ text job.displayName ],
       div [ class "progress progress-striped active" ] [
         div [ class "progress-bar", style [ "width" => "100%" ] ] []
       ],
        p [ class "card__footer" ] [ text job.formattedPublished ]
     ]

view : Signal.Address Action -> Model -> Html
view address model =
  let
    isFinished e = case e.result of
        Just result -> True
        Nothing -> False

    inProgress e = case e.result of
        Nothing -> True
        Just result -> False

    filteredCompleted = List.filter isFinished model.jobs
    filteredBuilding = List.filter inProgress model.jobs

    completed = List.map completedBuild filteredCompleted
    building = List.map (buildingBuild model.transition) filteredBuilding

    completedJobAmount = filteredCompleted |> List.length |> toString
    title = "Last " ++ completedJobAmount ++ " builds"

    isBuilding = if (filteredBuilding |> List.length) > 0 then True else False

    isBuildingPanel = ul [ class "l-flex l-flex--around leeroy leeroy--building" ] building
    isNotBuildingPanel = div [ class "leeroy-no-builds" ] [ text "Jenkins gonna break yo builds!" ]

    buildingPanel = if isBuilding then isBuildingPanel else isNotBuildingPanel


  in
    div [ class "l-panels" ]
      [
        div [ class "l-panel l-panel--dark l-panel--fluid"] [

          div [ class "l-inner" ] [
            h1 [ class "heading" ] [ span [ class "l-inner" ] [ img [ src "images/lego.png" ] [], text " Building" ] ],
            buildingPanel
          ]

        ],

        div [ class "l-panel l-panel--fluid"] [
          div [ class "l-inner" ] [
          h1 [ class "heading" ] [ span [ class "l-inner" ] [ text title ] ],
          ul [ class "l-flex leeroy" ] completed
          ]
        ]
    ]

--> PORTS / SIGNALS

port jobs: Signal (List Job)

setJobs = Signal.map SetJobs jobs


--> INITIATE

app = StartApp.start
           { init = (emptyModel, Effects.none),
             update = update,
             view = view,
             inputs = [setJobs]
           }

main = app.html