REBOL [
    Title: "Imagination"
    Date: 15-Nov-2004
    Version: 0.0.0
    File: %imagination.r

    Author: "errru"

    Needs: [view 1.2.55]

    Note: {Design and idea borrowed from a beautiful SWF demo by Hin Jang (www.hinjang.com}
]

imagination: context [
    
    ;; settings
    window-size: 900x500
    segments: 10
    transform-scale: 1.0 ;; < 1 for subpixel accuracy, > 1 for nice jitter

    ;; time for mouse event processing (zero means just 1 event per iteration)
    wait-time:      0:00:00.01

    ;; velocity settings
    vpower: 1.5
    vscale: 5
    
    ;; colorization freqs
    w1: 2
    w2: 3
    w3: 5

    font: make face/font [name: "Trebuchet MS" size: 20 color: 255.0.0]
    text: "imagination"

    ;; internal data
    coords: copy []
    coords-length: segments * 16
    shift: 0
    cursor1: cursor2: f-canvas: last-time: none

    window: layout/tight compose [
        f-canvas: box (window-size) white "imagination" effect [
            draw []
        ] font [
            name: "Trebuchet MS" size: 28 style: none align: 'center valign: 'middle color: red shadow: none
        ] para [
            wrap?: false
        ] feel [
            over: func [face action offset] [
                cursor2: offset
            ]
            engage: func [face action event] [
                cursor2: event/offset
            ]
        ]
    ]

    transform': func [x y] [as-pair x / transform-scale y / transform-scale]
    
    get-cc: func [p w] [to-integer (1 + sine p * w) * 127]
    get-color: func [p] [
        to-tuple reduce [
            get-cc p w1
            get-cc p w2
            get-cc p w3
        ]
    ]
    
    vfunc: func [v] [(to-decimal abs v) ** vpower * (sign? v) * vscale]

    init: has [
        c p l
        x1 y1 dx1 dy1
        x2 y2 dx2 dy2
        x3 y3
        x4 y4 dx4 dy4
        x5 y5
    ][
        insert-event-func func [face event] [
            either event/type = 'close [unview/all quit] [event]
        ]
    
        ;print "hello"
		view/new/options center-face window [all-over]

        forever [
            time: now/time/precise
            if none? last-time [last-time: time]
            tdelta: to-decimal time - last-time
            wait wait-time
            if cursor1 [
                repend coords [
                    (to-decimal cursor2/x) - 5 + random 10
                    (to-decimal cursor2/y) - 5 + random 10
                    vfunc cursor2/x - cursor1/x
                    vfunc cursor2/y - cursor1/y
                ]
                if coords-length < length? coords [
                    remove/part coords 16
                    shift: shift + 2 // (w1 * w2 * w3 * 360)
                ]
            ]
            cursor1: cursor2
            c: coords
            forskip c 4 [
                set [x1 y1 dx1 dy1] c
                x1: min max -500 x1 + (dx1 * tdelta) 500 + window-size/x
                y1: min max -500 y1 + (dy1 * tdelta) 500 + window-size/y
                change c reduce [x1 y1 dx1 either all [y1 > (window-size/y * 0.75) dy1 > 0] [dy1 * -0.5] [dy1]]
            ]
            clear f-canvas/effect/draw
            repend f-canvas/effect/draw ['transform 0 0x0 transform-scale transform-scale 0x0]
            c: coords
            p: shift
            forskip c 8 [
                set [x1 y1 dx1 dy1 x2 y2 dx2 dy2 x4 y4 dx4 dy4 x5 y5] c
                if y5 [
                    x3: x4 * 2 - x5
                    y3: y4 * 2 - y5
                    repend f-canvas/effect/draw [
                        'line-width 10 * ((1 + sine p * 10) / 2 ** 2) + 1
                        'pen get-color p
                        'curve
                            transform' x1 y1
                            transform' x2 y2
                            transform' x3 y3
                            transform' x4 y4
                    ]
                ]
                p: p + 1
            ]
            show f-canvas
            last-time: time
        ]
    ]
]

imagination/init


