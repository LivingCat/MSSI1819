globals
[
  grid-x-inc               ;; the amount of patches in between two roads in the x direction
  grid-y-inc               ;; the amount of patches in between two roads in the y direction
  acceleration             ;; the constant that controls how much a car speeds up or slows down by if
                           ;; it is to accelerate or decelerate
  phase                    ;; keeps track of the phase
  num-cars-stopped         ;; the number of cars that are stopped during a single pass thru the go procedure
  num-cars                 ;; the number of cars
  current-intersection     ;; the currently selected intersection

  ;; patch agentsets
  intersections            ;; agentset containing the patches that are intersections
  roads                    ;; agentset containing the patches that are roads
  feup

  cluster-size-list        ;; list containing the number of elems for each cluster
  total-co-emissions       ;; CO emissions by all the cars

  useful-intersections

  rider-score-group-global  ;;global rider score group
  score-walking-global      ;;global walking turtle score
  walking-turtle-counter    ;;number of walking turtles

]


turtles-own
[
  speed                    ;; the speed of the turtle
  up-car?                  ;; true if the turtle moves downwards and false if it moves to the right
  wait-time                ;; the amount of time since the last time a turtle has moved
  work                     ;; the patch where they work
  house                    ;; the patch where they live
  goal                     ;; where am I currently headed

  ;;new vars
  stops                    ;; all the stops the turtle has to make (house,friend1,friend2,....,work)
  indexStop                ;; index of current goal
  co-emissions-car         ;; car total emissions of CO
  capacity                 ;;car seats available
  orig-capacity
  been-matched             ;;true if turtle was already matched in the macthing phase, false otherwise
  rider                    ;;true if gives rides
  has-car                  ;;true if has car
  matches                  ;;passengers the turtle needs to pick up
  cluster                  ;; cluster the user belongs [0,7]


  rider-score-group        ;; mean score between the rider and its passengers

  year                     ;; university year the student frequents
  course                   ;;course the student frequents
  friends                  ;;other users which are friends with the user
  num-friends

  will-friends             ;;willingness to share rides with friends [1, 5]
  will-year-colleagues     ;;willingness to share rides with colleagues of the same year [1, 5]
  will-degree-colleagues   ;;willingness to share rides with colleagues of the same degree [1, 5]
  will-feup-colleagues     ;;willingness to share rides with colleagues from feup [1, 5]

  last-patches             ;;the last 5 patches
  same-patches-counter     ;;the number of times that the last 5 patches were the same
]

patches-own
[
  intersection?   ;; true if the patch is at the intersection of two roads
  green-light-up? ;; true if the green light is above the intersection.  otherwise, false.
                  ;; false for a non-intersection patches.
  my-row          ;; the row of the intersection counting from the upper left corner of the
                  ;; world.  -1 for non-intersection patches.
  my-column       ;; the column of the intersection counting from the upper left corner of the
                  ;; world.  -1 for non-intersection patches.
  my-phase        ;; the phase for the intersection.  -1 for non-intersection patches.
  auto?           ;; whether or not this intersection will switch automatically.
                  ;; false for non-intersection patches.
]


;;;;;;;;;;;;;;;;;;;;;;
;; Setup Procedures ;;
;;;;;;;;;;;;;;;;;;;;;;

;; Initialize the display by giving the global and patch variables initial values.
;; Create num-cars of turtles if there are enough road patches for one turtle to
;; be created per road patch.
to setup

  clear-all
  setup-globals
  setup-patches  ;; ask the patches to draw themselves and set up a few variables

  ;; Make an agentset of all patches where there can be a house or road
  ;; those patches with the background color shade of brown and next to a road
  let goal-candidates patches with [
    pcolor = 38 and any? neighbors with [ pcolor = white ]
  ]
  ask one-of intersections [ become-current ]

  set-default-shape turtles "car"
  ;set-default-shape passengers "person"

  set num-cars sum cluster-size-list

  if (num-cars > count roads) [
    user-message (word
      "There are too many cars for the amount of "
      "road.  Either increase the amount of roads "
      "by increasing the GRID-SIZE-X or "
      "GRID-SIZE-Y sliders, or decrease the "
      "number of cars by lowering the NUM-CAR slider.\n"
      "The setup has stopped.")
    stop
  ]



  ;; Now create the cars and have each created car call the functions setup-cars and set-car-color
  create-turtles num-cars [

    set been-matched false
    set rider false
    set stops []
    set matches []
    set last-patches  []
    set friends no-turtles

    setup-cars
    set-car-color ;; slower turtles are blue, faster ones are colored cyan
    record-data
  ]
  ;; give the turtles an initial speed
  ask turtles [ set-car-speed ]
  set-personal-vars
  ifelse(matching-algorythm = "Random")
  [
    random-matching
  ]
  [ifelse(matching-algorythm = "Min Distance")[
    distance-matching
  ]
    [ifelse(matching-algorythm = "None")[]
      [best-matching]
  ]]

  remove-turtles-no-car-no-match
  show walking-turtle-counter
  set-rider-score-group-global
  set-stops

  reset-ticks
end



;; Initialize the global variables to appropriate values
to setup-globals
  set current-intersection nobody ;; just for now, since there are no intersections yet
  set phase 0
  set num-cars-stopped 0
  set grid-x-inc world-width / grid-size-x
  set grid-y-inc world-height / grid-size-y
  set cluster-size-list (list cluster-0 cluster-1 cluster-2 cluster-3 cluster-4 cluster-5 cluster-6 cluster-7)

  ;; don't make acceleration 0.1 since we could get a rounding error and end up on a patch boundary
  set acceleration 0.099
  set walking-turtle-counter 0
  set score-walking-global 0
end

;; Make the patches have appropriate colors, set up the roads and intersections agentsets,
;; and initialize the traffic lights to one setting
to setup-patches
  ;; initialize the patch-owned variables and color the patches to a base-color
  ask patches [
    set intersection? false
    set auto? false
    set green-light-up? true
    set my-row -1
    set my-column -1
    set my-phase -1
    set pcolor brown + 3
  ]

  ;; initialize the global variables that hold patch agentsets
  set roads patches with [
    (floor ((pxcor + max-pxcor - floor (grid-x-inc - 1)) mod grid-x-inc) = 0) or
    (floor ((pycor + max-pycor) mod grid-y-inc) = 0) or (pycor = max-pycor) or (pxcor = min-pxcor)
  ]
  set intersections roads with [
    ((floor ((pxcor + max-pxcor - floor (grid-x-inc - 1)) mod grid-x-inc) = 0) and
      (floor ((pycor + max-pycor) mod grid-y-inc) = 0))
  ]

  set useful-intersections roads with  [
    ((floor ((pxcor + max-pxcor - floor (grid-x-inc - 1)) mod grid-x-inc) = 0) and
      (floor ((pycor + max-pycor) mod grid-y-inc) = 0)) or
    ((floor ((pxcor + max-pxcor - floor (grid-x-inc - 1)) mod grid-x-inc) = 0) and (pycor = max-pycor)) or
    ((floor ((pycor + max-pycor) mod grid-y-inc) = 0) and (pxcor = min-pxcor)) or
    ((pxcor = min-pxcor) and (pycor = min-pycor)) or
    ((pxcor = min-pxcor) and (pycor = max-pycor)) or
    ((pxcor = max-pxcor) and (pycor = max-pycor))
  ]

  ask roads [ set pcolor white ]

  ask roads [

    if pxcor = max-pxcor and pycor = min-pycor[
      set feup self
      set pcolor black
    ]
  ]
  setup-intersections

end

;; Give the intersections appropriate values for the intersection?, my-row, and my-column
;; patch variables.  Make all the traffic lights start off so that the lights are red
;; horizontally and green vertically.
to setup-intersections
  ask intersections[
    set intersection? true
    set green-light-up? true
    set my-phase 0
    set auto? true
    set my-row floor ((pycor + max-pycor) / grid-y-inc)
    set my-column floor ((pxcor + max-pxcor) / grid-x-inc)

    if pxcor != min-pxcor and pycor != max-pycor[
      set-signal-colors
    ]

  ]
end

;; Initialize the turtle variables to appropriate values and place the turtle on an empty road patch.
to setup-cars  ;; turtle procedure
  set speed 0
  set wait-time 0

  ifelse intersection? [
    ifelse random 2 = 0
      [ set up-car? true ]
    [ set up-car? false ]
  ]
  [ ; if the turtle is on a vertical road (rather than a horizontal one)
    ifelse (floor ((pxcor + max-pxcor - floor(grid-x-inc - 1)) mod grid-x-inc) = 0)
      [ set up-car? true ]
    [ set up-car? false ]
  ]
  ifelse up-car?
    [ set heading 180 ]
  [ set heading 90 ]

  let possible-locations no-patches
  set-cluster
  set-capacity
  set-willingnesses
  set-has-car
  while [count (possible-locations) = 0]
  [
    let distance-to-feup get-distance-to-feup
    set possible-locations calculate-intersections distance-to-feup
  ]

  move-to one-of possible-locations

end

to set-personal-vars
  ask turtles [
    set year (random 5) + 1
    set course (random 7) + 1
    set num-friends round random-normal 4 1
  ]

  ask turtles [

    let num min (list num-friends count turtles with [self != myself and num-friends > 0 and not member? self [friends] of myself])
    set friends (turtle-set friends n-of num turtles with [self != myself and num-friends > 0 and not member? self [friends] of myself])

    ask friends [
      set friends (turtle-set friends myself)
      set num-friends num-friends - 1
    ]

    set num-friends num-friends - num
  ]

end

to set-stops
  ask turtles[
    set stops (list);
  ]
  ask turtles with [rider = true] [

    ask matches [

      ifelse(member? patch-here useful-intersections)
      [
        let match-patch patch-here
        let neigh [neighbors] of match-patch
        let not-roads neigh with [not member? self roads]
        let neighbor one-of not-roads
        ask myself[ set stops lput neighbor stops]
      ]
      [
        let match-patch patch-here
        let neigh [neighbors4] of match-patch
        let not-roads neigh with [not member? self roads]
        let neighbor one-of not-roads
        ask myself[ set stops lput neighbor stops]
      ]

      die
    ]
    set stops order-patches stops patch-here
  ]

  ask turtles[
    set stops lput feup stops

    let i 26
    foreach stops[
      [the-stop] -> ask the-stop[
        set pcolor i
        set i (i + 10)
      ]
    ]

    set goal first stops
    ;;set first index current stop
    set indexStop 0
  ]

end

to random-matching
  ask turtles with [capacity > 0 and has-car][
    ;only turtles that haven't been matched can become riders and take passengers
    if(been-matched = false) [
      let num min (list capacity count turtles with [been-matched = false and self != myself])
      let aux-matches  n-of num turtles with [been-matched = false and self != myself]
      ask aux-matches [
        set been-matched true
      ]

      let aux-matches-list [ ]
      ask aux-matches [ set aux-matches-list lput self aux-matches-list ]
      ;set rider-score-group score-group aux-matches-list self
      set rider-score-group score-group aux-matches-list self
      set been-matched true
      set rider true
      set matches aux-matches
    ]
  ]
end

to distance-matching
  let list-distances []
  ask turtles with [capacity > 0 and has-car][
    ask turtles with [self != myself] [
      let triple (list myself self distance myself)
      set list-distances lput triple list-distances
    ]
  ]
  ;sort using distances
  set list-distances sort-by [ [triple1 triple2] -> item 2 triple1 < item 2 triple2 ] list-distances


  foreach list-distances [
    [i]-> if not [been-matched] of item 1 i and not [rider] of item 1 i and not [been-matched] of item 0 i and [capacity] of item 0 i > 0
    [
      ask item 0 i [
        set matches lput item 1 i matches
        set capacity capacity - 1
        set rider true
      ]
      ask item 1 i [
        set been-matched true
      ]
    ]
  ]

  ask turtles [
    set matches turtles with [member? self [matches] of myself]
  ]

   ask turtles with [rider = true][
      let aux-matches-list [ ]
      ask matches [ set aux-matches-list lput self aux-matches-list ]
      set rider-score-group score-group aux-matches-list self
  ]

end

to best-matching
  ask turtles with [capacity > 0 and has-car][
    if not been-matched[
      show capacity
      let possible-set turtles with [distance myself < 30 and self != myself]
      if count possible-set > 0[
        ;tem de se reduzir o possible set talvez fazer o score para cada pessoa e tirar as que têm menos de 0.5
        let possible []
        let reduced-possible-set no-turtles
        let num min (list 18 count possible-set)
        set reduced-possible-set max-n-of num possible-set [score-person self myself]

        ask reduced-possible-set[
          set possible lput self possible
        ]

        let possible-groups []
        let range-capacity []
        ifelse capacity = 1[
          set range-capacity (list 1)
        ][
          set range-capacity (range 1 (capacity + 1))
        ]
        foreach range-capacity
        [ [i] ->
          let perms []

          set perms comb i possible

          foreach perms[
            [perm] -> set possible-groups lput perm possible-groups
          ]
        ]
        let scored-groups score-groups possible-groups self
        let max-score-index 0
        let max-score 0
        foreach range length scored-groups[
          [i] -> if item i scored-groups > max-score[
            set max-score item i scored-groups
            set max-score-index i
          ]
        ]

        set rider-score-group max-score

        set matches turtles with [member? self item max-score-index possible-groups]
        set been-matched true
        set rider true
        ask matches[
          set been-matched true
        ]
        type "capacity/matches" type capacity type "/" print matches
        set rider-score-group score-group  item max-score-index possible-groups self
      ]
    ]
  ]

end

to-report score-person [person rider-turtle]
  let group (list person)
  let social-result social-score group rider-turtle
  let detour-result detour-score group rider-turtle
  report detour-result * social-result
end


to-report score-groups [possible-groups rider-turtle]
  let result-scores []
  foreach possible-groups[
    [i] ->
    set result-scores lput score-group i rider-turtle result-scores
  ]
  report result-scores
end

to-report score-group [group rider-turtle]
  let social-result social-score group rider-turtle
  let full-car-result full-car-score group rider-turtle
  let detour-result detour-score group rider-turtle
  report detour-result * full-car-result * social-result
end

to-report social-score [group rider-turtle]
  let result 1
  foreach group[
    [elem]->
    ifelse member? elem [friends] of rider-turtle [ set result result *  [will-friends] of rider-turtle]
    [ ifelse [year] of elem = [year] of rider-turtle and [course] of elem = [course] of rider-turtle [ set result result *  [will-year-colleagues] of rider-turtle]
      [ ifelse [course] of elem = [course] of rider-turtle [ set result result *  [will-degree-colleagues] of rider-turtle]
        [  set result result *  [will-feup-colleagues] of rider-turtle
    ]]]
  ]
  report result
end

to-report full-car-score [group rider-turtle]

  if[orig-capacity] of rider-turtle = 0
  [report 1]

  report length group / [orig-capacity] of rider-turtle
end

to-report detour-score [group rider-turtle]
  let patches-list []
  foreach group[
    [elem]-> set patches-list lput [patch-here] of elem patches-list
  ]
  let ordered-patches order-patches patches-list [patch-here] of rider-turtle
  let group-distance path-distance ordered-patches [patch-here] of rider-turtle
  let minimum-distance [distance feup] of rider-turtle
  let r-min 0.1

  let alpha 0
  ifelse minimum-distance = 0[
    set alpha ( ln r-min )/ 0.01
  ]
  [
    set alpha ( ln r-min )/ minimum-distance
  ]

  ifelse group-distance < minimum-distance[
   report 1
  ]
  [ifelse group-distance < 2 * minimum-distance[
    report e ^((group-distance - minimum-distance) * alpha)
    ][
    report r-min
    ]]


end

to-report score-walking [walking-turtle]
  let bottom-percentile 0.010812230  ;; lowest 1-percentile
  let top-percentile  63.50558397    ;; highest 99-percentile
  let new-min 0

  let distance0 3
  let distance1 40

  let old-range (top-percentile - bottom-percentile)
  let new-range (sqrt (world-width ^ 2 + world-height ^ 2 )) - new-min

  let minimum-distance (((distance0 - bottom-percentile) * new-range) / old-range) + new-min
  let maximum-distance (((distance1 - bottom-percentile) * new-range) / old-range) + new-min

  let group-distance [distance feup] of walking-turtle
  let r-min 0.1

  let alpha 0
  ifelse (maximum-distance - minimum-distance) = 0[
    set alpha ( ln r-min )/ 0.01
  ]
  [
    set alpha ( ln r-min )/(maximum-distance - minimum-distance)
  ]

  ifelse group-distance < minimum-distance[
   report 1
  ]
  [ifelse group-distance < maximum-distance[
    report e ^((group-distance - minimum-distance) * alpha)
    ][
    report r-min
    ]]
end


to-report order-patches[patches-list starting-patch]
  if length patches-list = 0[report (list)]
  let possible-orders permutations patches-list
  let minimum-distance 999999999999999
  let minimum-order []
  foreach possible-orders[
    [order] -> let dist path-distance order starting-patch
    if dist < minimum-distance[
      set minimum-distance dist
      set minimum-order order
    ]
  ]
  report minimum-order
end

to-report path-distance [patches-list starting-patch]
  let full-path patches-list
  set full-path insert-item 0 full-path starting-patch
  set full-path lput feup full-path
  let full-distance 0

  foreach range (length full-path - 1)[
    [i] -> ask item i full-path[
      set full-distance full-distance + distance item (i + 1) full-path
    ]
  ]
  report full-distance
end


to-report permutations [#lst] ;Return all permutations of `lst`
  let n length #lst
  if (n = 0) [report #lst]
  if (n = 1) [report (list #lst)]
  if (n = 2) [report (list #lst reverse #lst)]
  let result []
  let idxs range n
  foreach idxs [? ->
    let xi item ? #lst
    foreach (permutations remove-item ? #lst) [?? ->
      set result lput (fput xi ??) result
    ]
  ]
  report result
end

to-report comb [_m _s]
  if (_m = 0) [ report [[]] ]
  if (_s = []) [ report [] ]
  let _rest butfirst _s
  let _lista map [? -> fput item 0 _s ?] comb (_m - 1) _rest
  let _listb comb _m _rest
  report (sentence _lista _listb)
end

to-report calculate-intersections [distancia]

  let result roads  with [
    (sqrt (((pxcor - [pxcor] of feup) ^ 2) + ((pycor - [pycor] of feup) ^ 2))) <  (distancia + 0.5) and
    (sqrt (((pxcor - [pxcor] of feup) ^ 2) + ((pycor - [pycor] of feup) ^ 2))) >  (distancia - 0.5)
  ]
  report result

end


;; Find a road patch without any turtles on it and place the turtle there.
to put-on-empty-road  ;; turtle procedure
  move-to one-of roads with [ not any? turtles-on self ]
end


to set-has-car
  let probs-no-car [
    0.904761904761905
    0.169230769230769
    0.910714285714286
    0.678832116788321
    0.571428571428571
    0
    0.578947368421053
    0.875
  ]

  let prob-no-car item cluster probs-no-car
  let random-num random-float 1

  ifelse random-num <= prob-no-car
  [set has-car false]
  [set has-car true]

end

to set-will-friends
  let will-friends-probs [
    [0 0 0 0.142857142857143 1]
    [0 0 0 0.169230769230769 1]
    [0 0 0.125 0.446428571428571 1]
    [0 0 0.029197080291971 0.27007299270073 1 ]
    [0 0 0 0.142857142857143 1 ]
    [0 0 0.072916666666667 0.322916666666667 1]
    [0.368421052631579 0.631578947368421 1 1 1]
    [0 0 0 0.125 1]
  ]

  let selected-cluster-probs item cluster will-friends-probs
  let random-num random-float 1
  let i 0
  let prob-will-friends (item i selected-cluster-probs)

  while [random-num > prob-will-friends]
  [
    set i (i + 1)
    set prob-will-friends (item i selected-cluster-probs)
  ]

  set will-friends i / 4

end

to set-will-year-colleagues
  let will-year-colleagues-probs [
    [0 0.111111111111111 0.253968253968254 0.682539682539683 1]
    [0.076923076923077 0.2 0.584615384615385 0.984615384615385 1]
    [0 0.035714285714286 0.232142857142857 0.696428571428571 1]
    [0.007299270072993 0.021897810218978 0.18978102189781 0.656934306569343 1]
    [0.071428571428572 0.166666666666667 0.30952380952381 0.714285714285714 1]
    [0 0.010416666666667 0.1875 0.5 1]
    [0.473684210526316 0.763157894736842 0.973684210526316 1 1]
    [0 0.03125 0.0625 0.59375 1]
  ]

  let selected-cluster-probs item cluster will-year-colleagues-probs
  let random-num random-float 1
  let i 0
  let prob-will-year-colleagues (item i selected-cluster-probs)

  while [random-num > prob-will-year-colleagues]
  [
    set i (i + 1)
    set prob-will-year-colleagues (item i selected-cluster-probs)
  ]

  set will-year-colleagues i / 4

end


to set-will-degree-colleagues
  let will-degree-colleagues-probs [
    [0.015873015873016 0.19047619047619 0.412698412698413 0.793650793650794 1]
    [0.123076923076923 0.523076923076923 1 1 1]
    [0 0.035714285714286 0.321428571428571 0.732142857142857 1]
    [0.007299270072993 0.051094890510949 0.35036496350365 0.766423357664234 1]
    [0.119047619047619 0.261904761904762 0.523809523809524 0.761904761904762 1]
    [0 0 0.177083333333333 0.604166666666667 1]
    [0.5 0.789473684210526 0.789473684210526 0.973684210526316 1]
    [0 0.03125 0.21875 0.75 1]

  ]

  let selected-cluster-probs item cluster will-degree-colleagues-probs
  let random-num random-float 1
  let i 0
  let prob-will-degree-colleagues (item i selected-cluster-probs)

  while [random-num > prob-will-degree-colleagues]
  [
    set i (i + 1)
    set prob-will-degree-colleagues (item i selected-cluster-probs)
  ]

  set will-degree-colleagues i / 4

end


to set-will-feup-colleagues
  let will-feup-colleagues-probs [
    [0.063492063492064 0.365079365079365 0.650793650793651 0.888888888888889 1]
    [0.384615384615385 0.8 1 1 1]
    [0 0.178571428571429 0.553571428571429 0.839285714285714 1]
    [0.058394160583942 0.291970802919708 0.642335766423358 0.875912408759124 1]
    [0.214285714285714 0.476190476190476 0.666666666666667 0.857142857142857 1]
    [0.03125 0.166666666666667 0.46875 0.729166666666667 1]
    [0.657894736842105 0.842105263157895 1 1 1]
    [0 0.15625 0.53125 0.84375 1]
  ]

  let selected-cluster-probs item cluster will-feup-colleagues-probs
  let random-num random-float 1
  let i 0
  let prob-will-feup-colleagues (item i selected-cluster-probs)

  while [random-num > prob-will-feup-colleagues]
  [
    set i (i + 1)
    set prob-will-feup-colleagues (item i selected-cluster-probs)
  ]

  set will-feup-colleagues i / 4

end



to set-willingnesses
  set-will-friends
  set-will-year-colleagues
  set-will-degree-colleagues
  set-will-feup-colleagues
end

to set-capacity

  let cap-probs [
    [
      [1	0.166666666666667]
      [3	0.833333333333333]
      [4	1 ]
    ]
    [
      [1	0.12962962962963]
      [2	0.166666666666667]
      [3	0.203703703703704]
      [4	0.981481481481482]
      [5	1]
    ]
    [
      [1	0.6]
      [4	1]

    ]
    [
      [0	0.022727272727273]
      [1	0.159090909090909]
      [3	0.227272727272727]
      [4	0.954545454545455]
      [5	1]
    ]
    [
      [0	0.055555555555556]
      [1	0.277777777777778]
      [2	0.388888888888889]
      [3	0.5]
      [4	0.944444444444444]
      [5	1]
    ]
    [
      [1	0.09375]
      [2	0.104166666666667]
      [3	0.1875]
      [4	1]
    ]
    [
      [0	0.0625]
      [1	0.3125]
      [4	1]
    ]
    [
      [1	0.25]
      [3	0.5]
      [4	1]
    ]
  ]

  let selected-cluster-probs item cluster cap-probs

  let random-num random-float 1
  let i 0
  let line-cluster (item i selected-cluster-probs)
  let prob-capacity (item 1 line-cluster)

  while [random-num > prob-capacity]
  [
    set i (i + 1)
    set line-cluster (item i selected-cluster-probs)
    set prob-capacity (item 1 line-cluster)
  ]

  set capacity (item 0 line-cluster)
  set orig-capacity (item 0 line-cluster)

end

to set-cluster
  set cluster 0
  while [(item cluster cluster-size-list) = 0]
    [set cluster (cluster + 1)]

  set cluster-size-list replace-item cluster cluster-size-list ((item cluster cluster-size-list) - 1)

end
to-report get-distance-to-feup


  ;; gamma-values has alpha lambda 1-percentile 99-percentile
  let gamma-values [
    [1.1115022971624800 0.09816997717 0.170626425	49.46164323]
    [1.1230955616184066 0.09319105317 0.188534124	52.37843607]
    [2.9336791010654757 2.06130526549 0.200574976	4.023409760]
    [1.5774280653014760 0.10067907987 0.683103823	57.87916990]
    [0.6704063202145226 0.08264474742 0.010812230	45.95371822]
    [1.0998642740712024 0.07605486588 0.209738185	63.50558397]
    [0.9972550439242437 0.07672745832 0.129179405	59.93797531]
    [4.3890765134902980 3.09703304149 0.320843180	3.441911164]
  ]
  let selected-cluster item cluster gamma-values
  let alpha item 0 selected-cluster
  let lambda item 1 selected-cluster


  let bottom-percentile 0.010812230 ;; lowest 1-percentile
  let top-percentile  63.50558397 ;; highest 99-percentile

  let distance0 0
  while [distance0 < bottom-percentile or  distance0 > top-percentile] ;; if its not in that range, another value is calculated
  [
    set distance0 random-gamma alpha lambda
  ]
  let new-min 0 ; it may be greater than 0 to avoid being to close to feup
  let old-range (top-percentile - bottom-percentile)
  let new-range (sqrt (world-width ^ 2 + world-height ^ 2 )) - new-min
  let distance-patches (((distance0 - bottom-percentile) * new-range) / old-range) + new-min



  report distance-patches

end

;;;;;;;;;;;;;;;;;;;;;;;;
;; Runtime Procedures ;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; Run the simulation
to go

  if not any? turtles [ stop ] ;; exits if there are no more turtles

  ask current-intersection [ update-variables ]

  ;; have the intersections change their color
  set-signals
  set num-cars-stopped 0

  ;; set the cars’ speed, move them forward their speed, record data for plotting,
  ;; and set the color of the cars to an appropriate color based on their speed
  ask turtles [
    remove-turtles-at-goal
  ]

  ask turtles [
    ifelse member? patch-here last-patches[
      set same-patches-counter same-patches-counter + 1
    ][
      if length last-patches >= 5[
        set last-patches remove-item 0 last-patches
      ]
      set last-patches lput patch-here last-patches
      set same-patches-counter 0
    ]

    if same-patches-counter > 50 and goal != feup [
      show "estava preso vou passar ao proximo"
      set same-patches-counter 0
      set indexStop (indexStop + 1)
      set goal (item indexStop stops)
    ]
    face next-patch ;; car heads towards its goal
    set-car-speed
    fd speed
    record-data     ;; record data for plotting
    set-car-color   ;; set color to indicate speed
    calculate-emissons
  ]
  label-subject ;; if we're watching a car, have it display its goal
  next-phase ;; update the phase and the global clock

  set total-co-emissions total-co-emissions + (sum [co-emissions-car] of turtles)


  tick

end

to calculate-emissons
  let a 71.7
  let b 35.4
  let c 11.3
  let d -0.248
  let e0 0

  set co-emissions-car (a + c * speed + e0 * (speed ^ 2))/ (1 + b * speed + d * (speed ^ 2))

end

to choose-current
  if mouse-down? [
    let x-mouse mouse-xcor
    let y-mouse mouse-ycor
    ask current-intersection [
      update-variables
      ask patch-at -1 1 [ set plabel "" ] ;; unlabel the current intersection (because we've chosen a new one)
    ]
    ask min-one-of intersections [ distancexy x-mouse y-mouse ] [
      become-current
    ]
    display
    stop
  ]
end

;; Set up the current intersection and the interface to change it.
to become-current ;; patch procedure
  set current-intersection self
  set current-phase my-phase
  set current-auto? auto?
  ask patch-at -1 1 [
    set plabel-color black
    set plabel "current"
  ]
end

;; update the variables for the current intersection
to update-variables ;; patch procedure
  set my-phase current-phase
  set auto? current-auto?
end

;; have the traffic lights change color if phase equals each intersections' my-phase
to set-signals
  ask intersections with [ auto? and phase = floor ((my-phase * ticks-per-cycle) / 100) ] [
    set green-light-up? (not green-light-up?)
    set-signal-colors
  ]
end

;; This procedure checks the variable green-light-up? at each intersection and sets the
;; traffic lights to have the green light up or the green light to the left.
to set-signal-colors  ;; intersection (patch) procedure
  ifelse power? [
    ifelse green-light-up? [
      ask patch-at -1 0 [ set pcolor red ]
      ask patch-at 0 1 [ set pcolor green ]
    ]
    [
      ask patch-at -1 0 [ set pcolor green ]
      ask patch-at 0 1 [ set pcolor red ]
    ]
  ]
  [
    ask patch-at -1 0 [ set pcolor white ]
    ask patch-at 0 1 [ set pcolor white ]
  ]
end

;; set the turtles' speed based on whether they are at a red traffic light or the speed of the
;; turtle (if any) on the patch in front of them
to set-car-speed  ;; turtle procedure
  ifelse pcolor = red [
    set speed 0
  ]
  [
    ifelse up-car?
      [ set-speed 0 -1 ]
    [ set-speed 1 0 ]
  ]
end

;; set the speed variable of the turtle to an appropriate value (not exceeding the
;; speed limit) based on whether there are turtles on the patch in front of the turtle
to set-speed [ delta-x delta-y ]  ;; turtle procedure
                                  ;; get the turtles on the patch in front of the turtle
  let turtles-ahead turtles-at delta-x delta-y

  ;; if there are turtles in front of the turtle, slow down
  ;; otherwise, speed up
  ifelse any? turtles-ahead [
    ifelse any? (turtles-ahead with [ up-car? != [ up-car? ] of myself ]) [
      set speed 0
    ]
    [
      set speed [speed] of one-of turtles-ahead
      slow-down
    ]
  ]
  [ speed-up ]
end

;; decrease the speed of the car
to slow-down  ;; turtle procedure
  ifelse speed <= 0
    [ set speed 0 ]
  [ set speed speed - acceleration ]
end

;; increase the speed of the car
to speed-up  ;; turtle procedure
  ifelse speed > speed-limit
    [ set speed speed-limit ]
  [ set speed speed + acceleration ]
end

;; set the color of the car to a different color based on how fast the car is moving
to set-car-color  ;; turtle procedure
  ifelse speed < (speed-limit / 2)
    [ set color blue ]
  [ set color cyan - 2 ]
end

;; keep track of the number of stopped cars and the amount of time a car has been stopped
;; if its speed is 0
to record-data  ;; turtle procedure
  ifelse speed = 0 [
    set num-cars-stopped num-cars-stopped + 1
    set wait-time wait-time + 1
  ]
  [ set wait-time 0 ]
end

to change-light-at-current-intersection
  ask current-intersection[
    set green-light-up? (not green-light-up?)
    set-signal-colors
  ]
end

;; cycles phase to the next appropriate value
to next-phase
  ;; The phase cycles from 0 to ticks-per-cycle, then starts over.
  set phase phase + 1
  if phase mod ticks-per-cycle = 0 [ set phase 0 ]
end

to remove-turtles-at-goal
  ;;if i am on my goal then i update my go

  if (member? patch-here [neighbors4] of goal)[
    if(indexStop >= (length stops - 1))
      [die]
  ]
end

to remove-turtles-no-car-no-match
  ask turtles with [not been-matched and not has-car][
    show score-walking self
    set walking-turtle-counter walking-turtle-counter + 1
    set score-walking-global  score-walking-global  + score-walking self
    print "nao tive boleia :("
    die
  ]
end

;; establish goal of driver and move to next patch along the way
to-report next-patch

  if (member? patch-here [neighbors4] of goal)[
    ifelse(indexStop < (length stops - 1))
    [
      set indexStop (indexStop + 1)
      set goal (item indexStop stops)
    ]
    [
      ;;come back to the first stop
      set indexStop 0
      set goal first stops
    ]
  ]

  ;; CHOICES is an agentset of the candidate patches that the car can
  ;; move to (white patches are roads, green and red patches are lights)
  let choices neighbors with [ pcolor = white or pcolor = red or pcolor = green ]
  ;; choose the patch closest to the goal, this is the patch the car will move to
  let choice min-one-of choices [ distance [ goal ] of myself ]
  ;; report the chosen patch
  report choice

end

to watch-a-car
  stop-watching ;; in case we were previously watching another car
  watch one-of turtles
  ask subject [

    inspect self
    set size 2 ;; make the watched car bigger to be able to see it

    ask house [
      set pcolor yellow          ;; color the house patch yellow
      set plabel-color yellow    ;; label the house in yellow font
      set plabel "house"
      inspect self
    ]
    ask work [
      set pcolor orange          ;; color the work patch orange
      set plabel-color orange    ;; label the work in orange font
      set plabel "work"
      inspect self
    ]
    set label [ plabel ] of goal ;; car displays its goal
  ]
end

to stop-watching
  ;; reset the house and work patches from previously watched car(s) to the background color
  ask patches with [ pcolor = yellow or pcolor = orange ] [
    stop-inspecting self
    set pcolor 38
    set plabel ""
  ]
  ;; make sure we close all turtle inspectors that may have been opened
  ask turtles [
    set label ""
    stop-inspecting self
  ]
  reset-perspective
end

to label-subject
  if subject != nobody [
    ask subject [
      if goal = house [ set label "house" ]
      if goal = work [ set label "work" ]
    ]
  ]
end

to set-rider-score-group-global
  ifelse count turtles with [rider] = 0
  [set rider-score-group-global 0]
  [set rider-score-group-global mean [rider-score-group] of turtles with [rider]]
end


;; Reporters
to-report report-total-co-emissions
  report total-co-emissions
end

to-report report-number-riders
  report count turtles
end

to-report report-num-cars-stopped
  report num-cars-stopped
end

to-report report-mean-speed-cars
  if count turtles = 0
  [report 0]
  report mean [speed] of turtles
end

to-report report-average-wait-time-cars
  if count turtles = 0
  [report 0]
  report mean [wait-time] of turtles
end

to-report report-average-rider-score-group
  report rider-score-group-global
end

to-report report-average-walking-turtle-score
  if(walking-turtle-counter = 0)
  [report 1]
  report score-walking-global / walking-turtle-counter
end

to-report report-number-walking-turtles
  report walking-turtle-counter
end



; Copyright 2008 Uri Wilensky.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
340
10
897
568
-1
-1
9.0
1
15
1
1
1
0
0
0
1
-30
30
-30
30
1
1
1
ticks
30.0

PLOT
945
395
1163
570
Average Wait Time of Cars
Time
Average Wait
0.0
100.0
0.0
5.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [wait-time] of turtles"

PLOT
1185
185
1401
360
Average Speed of Cars
Time
Average Speed
0.0
100.0
0.0
1.0
true
false
"set-plot-y-range 0 speed-limit" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [speed] of turtles"

SLIDER
110
10
205
43
grid-size-y
grid-size-y
1
9
9.0
1
1
NIL
HORIZONTAL

SLIDER
10
10
104
43
grid-size-x
grid-size-x
1
9
9.0
1
1
NIL
HORIZONTAL

SWITCH
10
85
155
118
power?
power?
0
1
-1000

PLOT
945
185
1159
360
Stopped Cars
Time
Stopped Cars
0.0
100.0
0.0
100.0
true
false
"set-plot-y-range 0 num-cars" ""
PENS
"default" 1.0 0 -16777216 true "" "plot num-cars-stopped"

BUTTON
220
45
305
78
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
220
10
304
43
Setup
setup
NIL
1
T
OBSERVER
NIL
0
NIL
NIL
1

SLIDER
10
165
155
198
speed-limit
speed-limit
0.1
1
1.0
0.1
1
NIL
HORIZONTAL

MONITOR
200
90
305
135
Current Phase
phase
3
1
11

SLIDER
10
130
155
163
ticks-per-cycle
ticks-per-cycle
1
100
21.0
1
1
NIL
HORIZONTAL

SLIDER
160
225
305
258
current-phase
current-phase
0
99
0.0
1
1
%
HORIZONTAL

BUTTON
9
265
154
298
Change light
change-light-at-current-intersection
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SWITCH
9
225
154
258
current-auto?
current-auto?
0
1
-1000

BUTTON
159
265
304
298
Select intersection
choose-current
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
10
330
155
363
watch a car
watch-a-car
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
160
330
305
363
stop watching
stop-watching
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

INPUTBOX
940
15
1005
75
cluster-0
6.0
1
0
Number

INPUTBOX
1015
15
1080
75
cluster-1
6.0
1
0
Number

INPUTBOX
1090
15
1155
75
cluster-2
5.0
1
0
Number

INPUTBOX
1165
15
1230
75
cluster-3
13.0
1
0
Number

INPUTBOX
940
90
1005
150
cluster-4
4.0
1
0
Number

INPUTBOX
1015
90
1080
150
cluster-5
9.0
1
0
Number

INPUTBOX
1095
90
1160
150
cluster-6
4.0
1
0
Number

INPUTBOX
1170
90
1235
150
cluster-7
3.0
1
0
Number

PLOT
1190
395
1390
545
Total CO Emissions
Time
Emission rate
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot total-co-emissions"

CHOOSER
1255
25
1393
70
matching-algorythm
matching-algorythm
"Random" "Min Distance" "Best!" "None"
2

MONITOR
200
145
262
190
num-cars
num-cars
17
1
11

@#$#@#$#@
## ACKNOWLEDGMENT

This model is from Chapter Five of the book "Introduction to Agent-Based Modeling: Modeling Natural, Social and Engineered Complex Systems with NetLogo", by Uri Wilensky & William Rand.

* Wilensky, U. & Rand, W. (2015). Introduction to Agent-Based Modeling: Modeling Natural, Social and Engineered Complex Systems with NetLogo. Cambridge, MA. MIT Press.

This model is in the IABM Textbook folder of the NetLogo Models Library. The model, as well as any updates to the model, can also be found on the textbook website: http://www.intro-to-abm.com/.

## ERRATA

The code for this model differs somewhat from the code in the textbook. The textbook code calls the STAY procedure, which is not defined here. One of our suggestions in the "Extending the model" section below does, however, invite you to write a STAY procedure.

## WHAT IS IT?

The Traffic Grid Goal model simulates traffic moving in a city grid. It allows you to control traffic lights and global variables, such as the speed limit and the number of cars, and explore traffic dynamics.

This model extends the Traffic Grid model by giving the cars goals, namely to drive to and from work. It is the third in a series of traffic models that use different kinds of agent cognition. The agents in this model use goal-based cognition.

## HOW IT WORKS

Each time step, the cars face the next destination they are trying to get to (either work or home) and attempt to move forward at their current speed. If their current speed is less than the speed limit and there is no car directly in front of them, they accelerate. If there is a slower car in front of them, they match the speed of the slower car and decelerate. If there is a red light or a stopped car in front of them, they stop.

Each car has a house patch and a work patch. (The house patch turns yellow and the work patch turns orange for a car that you are watching.) The cars will alternately drive from their home to work and then from their work to home.

There are two different ways the lights can change. First, the user can change any light at any time by making the light current, and then clicking CHANGE LIGHT. Second, lights can change automatically, once per cycle. Initially, all lights will automatically change at the beginning of each cycle.

## HOW TO USE IT

Change the traffic grid (using the sliders GRID-SIZE-X and GRID-SIZE-Y) to make the desired number of lights. Change any other setting that you would like to change. Press the SETUP button.

At this time, you may configure the lights however you like, with any combination of auto/manual and any phase. Changes to the state of the current light are made using the CURRENT-AUTO?, CURRENT-PHASE and CHANGE LIGHT controls. You may select the current intersection using the SELECT INTERSECTION control. See below for details.

Start the simulation by pressing the GO button. You may continue to make changes to the lights while the simulation is running.

### Buttons

SETUP -- generates a new traffic grid based on the current GRID-SIZE-X and GRID-SIZE-Y and NUM-CARS number of cars. Each car chooses a home and work location. All lights are set to auto, and all phases are set to 0%.

GO -- runs the simulation indefinitely. Cars travel from their homes to their work and back.

CHANGE LIGHT -- changes the direction traffic may flow through the current light. A light can be changed manually even if it is operating in auto mode.

SELECT INTERSECTION -- allows you to select a new "current" intersection. When this button is depressed, click in the intersection which you would like to make current. When you've selected an intersection, the "current" label will move to the new intersection and this button will automatically pop up.

WATCH A CAR -- selects a car to watch. Sets the car's label to its goal. Displays the car's house in yellow and the car's work in orange. Opens inspectors for the watched car and its house and work.

STOP WATCHING -- stops watching the watched car and resets its labels and house and work colors.

### Sliders

SPEED-LIMIT -- sets the maximum speed for the cars.

NUM-CARS -- sets the number of cars in the simulation (you must press the SETUP button to see the change).

TICKS-PER-CYCLE -- sets the number of ticks that will elapse for each cycle. This has no effect on manual lights. This allows you to increase or decrease the granularity with which lights can automatically change.

GRID-SIZE-X -- sets the number of vertical roads there are (you must press the SETUP button to see the change).

GRID-SIZE-Y -- sets the number of horizontal roads there are (you must press the SETUP button to see the change).

CURRENT-PHASE -- controls when the current light changes, if it is in auto mode. The slider value represents the percentage of the way through each cycle at which the light should change. So, if the TICKS-PER-CYCLE is 20 and CURRENT-PHASE is 75%, the current light will switch at tick 15 of each cycle.

### Switches

POWER? -- toggles the presence of traffic lights.

CURRENT-AUTO? -- toggles the current light between automatic mode, where it changes once per cycle (according to CURRENT-PHASE), and manual, in which you directly control it with CHANGE LIGHT.

### Plots

STOPPED CARS -- displays the number of stopped cars over time.

AVERAGE SPEED OF CARS -- displays the average speed of cars over time.

AVERAGE WAIT TIME OF CARS -- displays the average time cars are stopped over time.

## THINGS TO NOTICE

How is this model different than the Traffic Grid model? The one thing you may see at first glance is that cars move in all directions instead of only left to right and top to bottom. You will probably agree that this looks much more realistic.

Another thing to notice is that, sometimes, cars get stuck: as explained in the book this is because the cars are mesuring the distance to their goals "as the bird flies", but reaching the goal sometimes require temporarily moving further from it (to get around a corner, for instance). A good way to witness that is to try the WATCH A CAR button until you find a car that is stuck. This situation could be prevented if the agents were more cognitively sophisticated. Do you think that it could also be avoided if the streets were layed out in a pattern different from the current one?

## THINGS TO TRY

You can change the "granularity" of the grid by using the GRID-SIZE-X and GRID-SIZE-Y sliders. Do cars get stuck more often with bigger values for GRID-SIZE-X and GRID-SIZE-Y, resulting in more streets, or smaller values, resulting in less streets? What if you use a big value for X and a small value for Y?

In the original Traffic Grid model from the model library, removing the traffic lights (by setting the POWER? switch to Off) quickly resulted in gridlock. Try it in this version of the model. Do you see a gridlock happening? Why do you think that is? Do you think it is more realistic than in the original model?

## EXTENDING THE MODEL

Can you improve the efficiency of the cars in their commute? In particular, can you think of a way to avoid cars getting "stuck" like we noticed above? Perhaps a simple rule like "don't go back to the patch you were previously on" would help. This should be simple to implement by giving the cars a (very) short term memory: something like a `previous-patch` variable that would be checked at the time of choosing the next patch to move to. Does it help in all situations? How would you deal with situations where the cars still get stuck?

Can you enable the cars to stay at home and work for some time before leaving? This would involve writing a STAY procedure that would be called instead moving the car around if the right condition is met (i.e., if the car has reached its current goal).

At the moment, only two of the four arms of each intersection have traffic lights on them. Having only two lights made sense in the original Traffic Grid model because the streets in that model were one-way streets, with traffic always flowing in the same direction. In our more complex model, cars can go in all directions, so it would be better if all four arms of the intersection had lights. What happens if you make that modification? Is the flow of traffic better or worse?

## RELATED MODELS

- "Traffic Basic": a simple model of the movement of cars on a highway.

- "Traffic Basic Utility": a version of "Traffic Basic" including a utility function for the cars.

- "Traffic Basic Adaptive": a version of "Traffic Basic" where cars adapt their acceleration to try and maintain a smooth flow of traffic.

- "Traffic Basic Adaptive Individuals": a version of "Traffic Basic Adaptive" where each car adapts individually, instead of all cars adapting in unison.

- "Traffic 2 Lanes": a more sophisticated two-lane version of the "Traffic Basic" model.

- "Traffic Intersection": a model of cars traveling through a single intersection.

- "Traffic Grid": a model of traffic moving in a city grid, with stoplights at the intersections.

- "Gridlock HubNet": a version of "Traffic Grid" where students control traffic lights in real-time.

- "Gridlock Alternate HubNet": a version of "Gridlock HubNet" where students can enter NetLogo code to plot custom metrics.

The traffic models from chapter 5 of the IABM textbook demonstrate different types of cognitive agents: "Traffic Basic Utility" demonstrates _utility-based agents_, "Traffic Grid Goal" demonstrates _goal-based agents_, and "Traffic Basic Adaptive" and "Traffic Basic Adaptive Individuals" demonstrate _adaptive agents_.

## HOW TO CITE

This model is part of the textbook, “Introduction to Agent-Based Modeling: Modeling Natural, Social and Engineered Complex Systems with NetLogo.”

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Rand, W., Wilensky, U. (2008).  NetLogo Traffic Grid Goal model.  http://ccl.northwestern.edu/netlogo/models/TrafficGridGoal.  Center for Connected Learning and Computer-Based Modeling, Northwestern Institute on Complex Systems, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the textbook as:

* Wilensky, U. & Rand, W. (2015). Introduction to Agent-Based Modeling: Modeling Natural, Social and Engineered Complex Systems with NetLogo. Cambridge, MA. MIT Press.

## COPYRIGHT AND LICENSE

Copyright 2008 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

<!-- 2008 Cite: Rand, W., Wilensky, U. -->
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
true
0
Polygon -7500403 true true 180 15 164 21 144 39 135 60 132 74 106 87 84 97 63 115 50 141 50 165 60 225 150 285 165 285 225 285 225 15 180 15
Circle -16777216 true false 180 30 90
Circle -16777216 true false 180 180 90
Polygon -16777216 true false 80 138 78 168 135 166 135 91 105 106 96 111 89 120
Circle -7500403 true true 195 195 58
Circle -7500403 true true 195 47 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Experiment 10 people" repetitions="40" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>report-total-co-emissions</metric>
    <metric>report-number-riders</metric>
    <metric>report-num-cars-stopped</metric>
    <metric>report-mean-speed-cars</metric>
    <metric>report-average-wait-time-cars</metric>
    <metric>report-average-rider-score-group</metric>
    <metric>report-average-walking-turtle-score</metric>
    <metric>report-number-walking-turtles</metric>
    <enumeratedValueSet variable="cluster-0">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-2">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-3">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-4">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-5">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-6">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-7">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matching-algorythm">
      <value value="&quot;None&quot;"/>
      <value value="&quot;Random&quot;"/>
      <value value="&quot;Min Distance&quot;"/>
      <value value="&quot;Best!&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grid-size-x">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grid-size-y">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="power?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="current-phase">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ticks-per-cycle">
      <value value="21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="current-auto?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment 50 people" repetitions="40" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>report-total-co-emissions</metric>
    <metric>report-number-riders</metric>
    <metric>report-num-cars-stopped</metric>
    <metric>report-mean-speed-cars</metric>
    <metric>report-average-wait-time-cars</metric>
    <metric>report-average-rider-score-group</metric>
    <metric>report-average-walking-turtle-score</metric>
    <metric>report-number-walking-turtles</metric>
    <enumeratedValueSet variable="cluster-0">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-1">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-2">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-3">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-4">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-5">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-6">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-7">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matching-algorythm">
      <value value="&quot;None&quot;"/>
      <value value="&quot;Random&quot;"/>
      <value value="&quot;Min Distance&quot;"/>
      <value value="&quot;Best!&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grid-size-x">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grid-size-y">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="power?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="current-phase">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ticks-per-cycle">
      <value value="21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="current-auto?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment 75 people" repetitions="40" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>report-total-co-emissions</metric>
    <metric>report-number-riders</metric>
    <metric>report-num-cars-stopped</metric>
    <metric>report-mean-speed-cars</metric>
    <metric>report-average-wait-time-cars</metric>
    <metric>report-average-rider-score-group</metric>
    <metric>report-average-walking-turtle-score</metric>
    <metric>report-number-walking-turtles</metric>
    <enumeratedValueSet variable="cluster-0">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-1">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-2">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-3">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-4">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-5">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-6">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-7">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matching-algorythm">
      <value value="&quot;None&quot;"/>
      <value value="&quot;Random&quot;"/>
      <value value="&quot;Min Distance&quot;"/>
      <value value="&quot;Best!&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grid-size-x">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grid-size-y">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="power?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="current-phase">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ticks-per-cycle">
      <value value="21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="current-auto?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment 100 people" repetitions="40" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>report-total-co-emissions</metric>
    <metric>report-number-riders</metric>
    <metric>report-num-cars-stopped</metric>
    <metric>report-mean-speed-cars</metric>
    <metric>report-average-wait-time-cars</metric>
    <metric>report-average-rider-score-group</metric>
    <metric>report-average-walking-turtle-score</metric>
    <metric>report-number-walking-turtles</metric>
    <enumeratedValueSet variable="cluster-0">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-1">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-2">
      <value value="11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-3">
      <value value="26"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-4">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-5">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-6">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-7">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matching-algorythm">
      <value value="&quot;None&quot;"/>
      <value value="&quot;Random&quot;"/>
      <value value="&quot;Min Distance&quot;"/>
      <value value="&quot;Best!&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grid-size-x">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grid-size-y">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="power?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="current-phase">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ticks-per-cycle">
      <value value="21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="current-auto?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment 150 people" repetitions="40" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>report-total-co-emissions</metric>
    <metric>report-number-riders</metric>
    <metric>report-num-cars-stopped</metric>
    <metric>report-mean-speed-cars</metric>
    <metric>report-average-wait-time-cars</metric>
    <metric>report-average-rider-score-group</metric>
    <metric>report-average-walking-turtle-score</metric>
    <metric>report-number-walking-turtles</metric>
    <enumeratedValueSet variable="cluster-0">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-1">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-2">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-3">
      <value value="39"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-4">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-5">
      <value value="27"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-6">
      <value value="11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-7">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matching-algorythm">
      <value value="&quot;None&quot;"/>
      <value value="&quot;Random&quot;"/>
      <value value="&quot;Min Distance&quot;"/>
      <value value="&quot;Best!&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grid-size-x">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grid-size-y">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="power?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="current-phase">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ticks-per-cycle">
      <value value="21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="current-auto?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment 175 people" repetitions="40" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>report-total-co-emissions</metric>
    <metric>report-number-riders</metric>
    <metric>report-num-cars-stopped</metric>
    <metric>report-mean-speed-cars</metric>
    <metric>report-average-wait-time-cars</metric>
    <metric>report-average-rider-score-group</metric>
    <metric>report-average-walking-turtle-score</metric>
    <metric>report-number-walking-turtles</metric>
    <enumeratedValueSet variable="cluster-0">
      <value value="21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-1">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-2">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-3">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-4">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-5">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-6">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-7">
      <value value="11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matching-algorythm">
      <value value="&quot;None&quot;"/>
      <value value="&quot;Random&quot;"/>
      <value value="&quot;Min Distance&quot;"/>
      <value value="&quot;Best!&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grid-size-x">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grid-size-y">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="power?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="current-phase">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ticks-per-cycle">
      <value value="21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="current-auto?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment 200 people" repetitions="40" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>report-total-co-emissions</metric>
    <metric>report-number-riders</metric>
    <metric>report-num-cars-stopped</metric>
    <metric>report-mean-speed-cars</metric>
    <metric>report-average-wait-time-cars</metric>
    <metric>report-average-rider-score-group</metric>
    <metric>report-average-walking-turtle-score</metric>
    <metric>report-number-walking-turtles</metric>
    <enumeratedValueSet variable="cluster-0">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-1">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-2">
      <value value="21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-3">
      <value value="52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-4">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-5">
      <value value="36"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-6">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-7">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matching-algorythm">
      <value value="&quot;None&quot;"/>
      <value value="&quot;Random&quot;"/>
      <value value="&quot;Min Distance&quot;"/>
      <value value="&quot;Best!&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grid-size-x">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grid-size-y">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="power?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="current-phase">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ticks-per-cycle">
      <value value="21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="current-auto?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment 250 people" repetitions="40" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>report-total-co-emissions</metric>
    <metric>report-number-riders</metric>
    <metric>report-num-cars-stopped</metric>
    <metric>report-mean-speed-cars</metric>
    <metric>report-average-wait-time-cars</metric>
    <metric>report-average-rider-score-group</metric>
    <metric>report-average-walking-turtle-score</metric>
    <metric>report-number-walking-turtles</metric>
    <enumeratedValueSet variable="cluster-0">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-1">
      <value value="31"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-2">
      <value value="26"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-3">
      <value value="65"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-4">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-5">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-6">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-7">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matching-algorythm">
      <value value="&quot;None&quot;"/>
      <value value="&quot;Random&quot;"/>
      <value value="&quot;Min Distance&quot;"/>
      <value value="&quot;Best!&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grid-size-x">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grid-size-y">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="power?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="current-phase">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ticks-per-cycle">
      <value value="21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="current-auto?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment 300 people" repetitions="40" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>report-total-co-emissions</metric>
    <metric>report-number-riders</metric>
    <metric>report-num-cars-stopped</metric>
    <metric>report-mean-speed-cars</metric>
    <metric>report-average-wait-time-cars</metric>
    <metric>report-average-rider-score-group</metric>
    <metric>report-average-walking-turtle-score</metric>
    <metric>report-number-walking-turtles</metric>
    <enumeratedValueSet variable="cluster-0">
      <value value="36"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-1">
      <value value="37"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-2">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-3">
      <value value="78"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-4">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-5">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-6">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-7">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matching-algorythm">
      <value value="&quot;None&quot;"/>
      <value value="&quot;Random&quot;"/>
      <value value="&quot;Min Distance&quot;"/>
      <value value="&quot;Best!&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grid-size-x">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grid-size-y">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="power?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="current-phase">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ticks-per-cycle">
      <value value="21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="current-auto?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment 350 people" repetitions="40" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>report-total-co-emissions</metric>
    <metric>report-number-riders</metric>
    <metric>report-num-cars-stopped</metric>
    <metric>report-mean-speed-cars</metric>
    <metric>report-average-wait-time-cars</metric>
    <metric>report-average-rider-score-group</metric>
    <metric>report-average-walking-turtle-score</metric>
    <metric>report-number-walking-turtles</metric>
    <enumeratedValueSet variable="cluster-0">
      <value value="42"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-1">
      <value value="43"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-2">
      <value value="37"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-3">
      <value value="91"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-4">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-5">
      <value value="64"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-6">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster-7">
      <value value="21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matching-algorythm">
      <value value="&quot;None&quot;"/>
      <value value="&quot;Random&quot;"/>
      <value value="&quot;Min Distance&quot;"/>
      <value value="&quot;Best!&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grid-size-x">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grid-size-y">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="power?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="current-phase">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ticks-per-cycle">
      <value value="21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="current-auto?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
