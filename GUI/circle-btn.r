REBOL []

btn-box-size: 100x25
v-offset: 4x3
v-end: to-pair reduce [7 btn-box-size/y - 4]
h-offset: to-pair reduce [3 btn-box-size/y - 4]
h-end: btn-box-size + -3x-3
start: 0x0
end: 50x50
center-radius: copy [circle 10x10 7]
circ: true
vert: false
pen-color: copy [orange red green blue yellow white]
fill-pen-color: copy [orange red green blue yellow white]
l-w: 0
colors: reduce [coal coal + 50]
offset: to-pair reduce [0 (btn-box-size/y - 3)]

menus-colors: copy ["Fichier" green "Nouveau" green "Enregistrer" green "Annuler" orange "Ouvrir" blue "Quitter" red "Imprimer" blue "Refaire" orange "Préférences" yellow]

font-name: "lato light" ;lato thin regular bold black
font-style: none ;"bold"

draw-blk: copy []

over-effects: copy []

do-draw-blk: func [str [string!] /local color d-b] [
	color: select menus-colors str
	d-b: copy compose [
	pen (color)
	fill-pen (color)
	line-width (l-w)
	line-join square ;miter-bevel
	(either vert [compose [box (v-offset) (v-end) 20]][compose [box (h-offset) (h-end) 20]])
	]
	draw-blk: copy d-b
]

;probe draw-blk

;probe over-effects: compose/deep/only [[] [luma 20 draw (do-draw-blk)]]

new-styles: stylize [
	btn-box: box with [
		size: btn-box-size
		color: coal
		edge: none ;make face/edge [size: 1x1 color: coal]
		para: make face/para [origin: 28x2]
		font: make face/font compose [
			align: 'left color: gray + 20 name: (font-name) size: 13 style: (either font-style [to-lit-word font-style][none]) shadow: none valign: 'middle]
		colors: reduce [gray + 20 white]
		effect: [aspect] ;[draw draw-blk] 
		feel: make face/feel [
			over: func [face action event][
				;probe face/text
				over-effects: compose/deep/only [[aspect] [aspect luma 7 draw (do-draw-blk face/text)]]
				face/effect: pick over-effects not action
				face/font/color: pick face/colors not action
				show face
				face/effect: first over-effects
				face/font/color: first face/colors
			]
			
			engage: func [face action event][
				switch action [
					time [if not face/state [face/blinker: not face/blinker]]
					down [face/state: on insert face/effect 'invert print face/text]
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
	b1: btn-box "Fichier" ;[probe second face/feel] ;%add-file-48.png 
	b2: btn-box "Imprimer" ;%print-64.png 
	b3: btn-box "Nouveau"
	b4: btn-box "Annuler" ;[probe face/text]
	b5: btn-box "Refaire"
	b6: btn-box "Quitter" [quit]
	;return box to-pair reduce [(b6/size/x * 5 + 4) 5]
	return space 10x20
	bn: btn [show b1] ; probe b1/font/color] ;draw-blk probe b1/feel] ;[append b1/effect/draw draw-blk show b1]
]