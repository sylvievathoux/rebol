REBOL []

start: 0x0
end: 50x50
pen-color: [orange red]
fill-pen-color: [orange red]
l-w: 0
;offset: 0x53
colors: reduce [coal coal + 50]
btn-box-size: 100x50
offset: to-pair reduce [0 (btn-box-size/y - 6)]
font-name: "lato light" ;lato thin regular bold black
font-style: none ;"bold"
draw-blk: copy []
over-effects: copy []

do-draw-blk: func [str [string!] /local d-b] [d-b: copy compose [
	pen (either "Quit" = str [pen-color/2][pen-color/1])
	fill-pen (either "Quit" = str [fill-pen-color/2][fill-pen-color/1])
	line-width (l-w)
	line-join square ;miter-bevel
	box (offset) (btn-box-size)
;	line (start) (end)
	]
	draw-blk: copy d-b
]

;probe draw-blk

;probe over-effects: compose/deep/only [[] [luma 20 draw (do-draw-blk)]]

new-styles: stylize [
	btn-box: box with [
		size: btn-box-size
		edge: none ;make face/edge [size: 1x1 color: coal]
		para: make face/para [origin: 2x12]
		font: make face/font compose [
			color: gray name: (font-name) size: 14 style: (either font-style [to-lit-word font-style][none]) shadow: none] ; valign: 'middle]
		colors: reduce [gray + 30 white]
		effect: make face/effect [] ;[draw draw-blk] 
		feel: make face/feel [
			over: func [face action event][
				;probe face/text
				over-effects: compose/deep/only [[] [luma 40 draw (do-draw-blk face/text)]]
				face/effect: pick over-effects not action
				face/font/color: pick face/colors not action
				show face
				face/effect: first over-effects
				face/font/color: first face/colors
			]
			
			engage: func [face action event][
				switch action [
					time [if not face/state [face/blinker: not face/blinker]]
					down [face/state: on insert face/effect 'invert]
					alt-down [face/state: on]
					up [if face/state [do-face face face/text] face/state: off remove head face/effect]
					alt-up [if face/state [do-face-alt face face/text] face/state: off]
					over [face/state: on]
					away [face/state: off]
				]
				cue face action
				show face
			]
			cue: none
			blink: none	
		]
	]
]

view center-face layout [
	backdrop coal + 20 ;size 500x200
	styles new-styles
	across space 1x10
	b1: btn-box coal "Bouton 1" [probe second face/feel]
	b2: btn-box coal "Bouton 2"
	b3: btn-box coal "Bouton 3"
	b4: btn-box coal "Quit" [probe face/text]
	b6: btn-box coal "Essai"
	return box coal to-pair reduce [probe (b6/size/x * 5 + 4) 5]
	return space 10x20
	b5: box coal 100x25 [quit]
	bn: btn [show b1] ; probe b1/font/color] ;draw-blk probe b1/feel] ;[append b1/effect/draw draw-blk show b1]
]