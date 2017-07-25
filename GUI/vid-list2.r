 REBOL [
    title: "List Widget Example"
    file: %list-widget-example.r
    date: 8-jul-2010
    author:   Nick Antonaccio
    purpose: {
        This examples demonstrates how to use REBOL's native GUI list
        widget to manage a grid of data values.   Columns can be sorted
        by clicking the headers.   Individual values at any column/row
        position can be edited by the user (just click the current value).
        Entire rows can be added, removed, or moved to/from user-selected
        positions.   The data block can be saved or loaded to/from file(s).
        Scrolling can be done with the mouse, arrow keys, or page-up/
        page-down keys.   Several resizing concepts are also demonstrated.
    }
]

new-style: stylize/master [
	List-text: text with [
		font: make font [name: "verdana" size: 10 valign: 'middle]
	]
	JP-list: list with [
		edge: make edge [size: 1x1 color: 0 effect: none]
	]
	etq: text white black with [
		font: make font [name: "verdana" size: 10 valign: 'middle align: 'center style: 'bold]
	]
	JP-slider: slider with [
		append init [
			color: snow
			pane/1/color: snow
		]
	]
	JP-scroller: scroller  with [
		color: 200.200.200 ;240.240.240
		
	    append init [
	           ;clip: 0x0
	           ;pane/1/image: img-scroller
			   ;pane/1/effect: 'fit
			   pane/1/size: 20x50
	           pane/1/color: black ;snow ;128.128.128
	           pane/1/edge/color: 0
	           pane/1/edge/size: 0x0
			   pane/1/effect: [draw [
				pen red line-width 2 line-cap square line 5x21 15x21 line 5x25 15x25 line 5x29 15x29]]
               pane/2/edge/size: pane/3/edge/size: 0x1
               pane/2/edge/color: pane/3/edge/color: snow
			   pane/2/effect: pane/3/effect: none
			   pane/2/colors/1: pane/3/colors/1: black
			   pane/2/effect: [draw [pen red line-width 2 line-cap square line 5x11 10x6 15x11]]
   			   pane/3/effect: [draw [pen red line-width 2 line-cap square line 5x6 10x11 15x6]]

        ]

	]
]

lb1: 0
lb2: 0
lb3: 0
x: copy []

;random/seed now/time   ; generate 5000 rows of random data:
;{repeat i 5000 [append/only x reduce [random "asdfqwertyiop" form random 1000 form i] ]}
file: request-file/filter/only/title  ["*.dat" "*.txt" "*.fbx"] reform ["Rivage-Ortho " system/version " " now/date]  ""
blk: copy []
probe delta-time [foreach b remove read/lines file [
	b1: parse b ","
	replace b1 first b1 to-date first b1
	append/only blk b1
	;if any [(length? first b) > lb1 (length? second b) > lb2 (length? third b) > lb2] []
	lb1: either (length? form first b1) > lb1 [length? form first b1][lb1]
	lb2: either (length? form second b1) > lb2 [length? form second b1][lb2]
	lb3: either (length? form third b1) > lb3 [length? form third b1][lb3]
]
]

;probe tsize-block: reduce [lb1 * 10 lb2 * 10 lb3 * 10]
set ts: [t1 t2 t3] reduce [lb1 * 10 lb2 * 10 lb3 * 10]
probe sz: t1 + t2 + t3

x: :blk
y: copy x

sort-column: func [field] [
    either sort-order: not sort-order [
        sort/compare x func [a b] [(at a field) > (at b field)]
    ] [
        sort/compare x func [a b] [(at a field) < (at b field)]
    ]  
    show li
]
key-scroll: func [scroll-amount] [
    s-pos: s-pos + scroll-amount
    if s-pos > (length? x) [s-pos: length? x]
    if s-pos < 0 [s-pos: 0]
    sl/data: s-pos / (length? x)  
    show li   show sl
]
resize-grid: func [percentage] [
    gui-size: system/view/screen-face/pane/1/size  / 2; - 10x0
    list-size/1: list-size/1 * percentage
    list-size/2: gui-size/2 - 95
    t-size: round (list-size/1 / 3)
    sl-size: as-pair 16 list-size/2
    unview/only gui view/options center-face layout gui-block [resize]
]
resize-fit: does [
    ;gui-size: system/view/screen-face/pane/1/size / 2
    probe (gui-size/1 / list-size/1 - .1)
	;resize-grid (gui-size/1 / list-size/1 - .1)
]

;insert-event-func [either event/type = 'resize [resize-fit none] [event]]
gui-size: (system/view/screen-face/size / 2) - 50x50
list-size: probe (as-pair sz gui-size/2) - 0x95
sl-size: as-pair 20 list-size/2
t-size: round (list-size/1 / 3)
s-pos: 0   sort-order: true   ovr-cnt: none

svv/vid-face/color: white
svv/vid-styles/button/colors: [255.0.0 0.0.255]

view/options center-face gui: layout gui-block: [ 
    size gui-size   across
    btn "Smaller" [resize-grid .75]
    btn "Bigger" [resize-grid 1.3333]
    btn "Fit" [resize-fit]
    btn #"^~" "Remove" [attempt [
        indx: to-integer request-text/title/default "Row to remove:"
            form ovr-cnt
        if indx = 0 [return]
        if true <> request rejoin ["Remove: " pick x indx "?"] [return]
        remove (at x indx)   show li
    ]]
    insert-btn: btn "Add" [attempt [
        indx: to-integer request-text/title/default "Add values at row #:"
            form ovr-cnt
        if indx = 0 [return]
        new-values: reduce [request-text request-text (form ((length? x) + 1)) ]
        insert/only (at x indx) new-values   show li
    ]]
    btn #"m" "Move" [
        old-indx: to-integer request-text/title/default "Move from row #:"
            form ovr-cnt
        new-indx: to-integer request-text/title "Move to row #:"
        if ((new-indx = 0) or (old-indx = 0)) [return]
        if true <> request rejoin ["Move: " pick x old-indx "?"] [return]
        move/to (at x old-indx) new-indx   show li
    ]
    btn "Save" [save to-file request-file/save x]
    btn "Load" [y: copy x: copy load request-file/only   show li]
    btn "View Data" [editor x]
	btn "Monitor" [
		sl/pane/1/color: wheat sl/pane/1/edge: make face/edge [size: 0x0 effect: none]
		sl/pane/2/edge: none
		sl/pane/3/edge: none
		show sl
	]
						; <---- !!!
    ;return
	;text "prénom"
	return space 2x0
    style header button black with [ ;50.50.50 128.128.128 with [
		;color: 128.128.128
		edge: make face/edge [size: 0x0 color: black effect: none]
		font: make face/font [name: "verdana" size: 11 style: none valign: 'middle colors: [200.200.200 255.255.255]]
		effect: none
		;init: append init [effect: none]
		;effect: make effect reduce ['gradient 0x0 160.160.160 96.96.96]
	]
    header "Rendez-vous" as-pair t1 24 [sort-column 1]
    header "Prénom" as-pair t2 24 [sort-column 2]
    h: header "Nom" as-pair (t3 - 4) 24 [sort-column 3 probe h/colors probe h/effect probe h/effects probe h/facets]
    header "R" 20x24 [if true = request "Reset?" [x: copy y show li]]
    return
	here: at
    li: list list-size [
        style cell text font [name: "verdana" size: 10 valign: 'center]
						feel [
							over: func [f o] [
								if all [o ovr-cnt <> f/data] [ovr-cnt: f/data show li]
							]
							engage: func [f a e] [
								if a = 'up [
									f/text: request-text/default f/text show li
									probe f/size/1
									probe f/feel
								]
								if a = 'scroll-line [print e/offset/y]
							]
						]
		;with [append init [ iter/size/y: font/size * 2]]
		across space 2x0
			col1: cell t1 
			col2: cell t2
			col3: cell t3
		] supply [
			either even? count [face/color: white] [face/color: 200.200.200]
			count: count + s-pos
			if none? q: pick x count [face/text: copy "" exit]
			if ovr-cnt = count [face/color: 255.210.210]
			face/data: count
			face/text: pick q index
			;face/size/2: 30
		] edge [size: 0x0 color: green] ;feel [engage: func [f a e][if a = 'scroll-line [print e/offset/y]]]
	
	;pad 2x0
    ;sl: scroller sl-size [s-pos: probe round (length? x) * value show li] ;edge [size: 0x0 color: red effect: none] ; with [dragger: make face/dragger [edge: none]]
    sl: JP-scroller sl-size [s-pos: round (length? x) * value show li] ;probe first sl/pane/2] ;[s-pos: probe round (length? x) * value show li] ;edge [size: 0x0 color: red effect: none] ; with [dragger: make face/dragger [edge: none]]

	
	
    key keycode [up] [key-scroll -1]
    key keycode [down] [key-scroll 1]
    key keycode [page-up] [key-scroll -20]
    key keycode [page-down] [key-scroll 20]
    key keycode [insert] [do-face insert-btn 1]
	
] [resize]
;probe first sl/pane/2
;li/iter/size/y: 20
