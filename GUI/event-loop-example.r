REBOL [
    purpose: {Demonstrate breaking from one event loop to go to another.}
]

view/new center-face layout/size [
    ;origin 0
    h1 400 rate 1 feel [
        engage: func [face act evt] [
            face/text: reform [now/time mode]
            show face
        ]
    ]
] 400x150

mode: "Initial Loop"
;started: now while [now < (started + 00:00:04)] [ wait 0.1]
wait 3.0
mode: "Final Loop"
wait 3.0 ;none
mode: "another loop"
wait none