REBOL [
	title: "Paint"
	file: %paint24.r
	author: "Frank Sievertsen"
	version: 1.0.2
]

context [
	color: fill-color: start: draw-image: draw-pos: tmp: none
	type: 'box
	undos: [] redos: []
	segments: []
	empty: false
	l-w: 2
	transparency: 0
	
	svv/vid-face/color: white
	svv/vid-styles/button/colors: [255.0.0 70.0.180]

	draw: func [offset /local tmp] [ ;print 3
		either type = 'polygon  [
			either empty [
				clear find/last draw-image/effect/draw 'polygon
				compose [polygon (segments)]
			][
				compose [
					pen (color/color)
					fill-pen (either none? fill-color/color [none][to-tuple rejoin [fill-color/color "." transparency]])
					line-width (l-w)
					line-join round ;miter-bevel
					line (offset - 1x1) (offset + 1x1)
					polygon (segments)
					;line (start) (first back back tail segments)  ;(either tmp: first back back tail segments [tmp offset][offset offset])
				]
			]
		][
			compose [
				pen (color/color)
				fill-pen (either none? fill-color/color [none][to-tuple rejoin [fill-color/color "." transparency]])
				line-width (l-w)
				line-join round ;miter-bevel
				(type) (start) (either type = 'circle [ ;print 1
					tmp: offset - start
					to-integer square-root add tmp/x ** 2 tmp/y ** 2
				][offset])
			]
		]
	]
	
	view center-face lay: layout/size [
	
		backdrop effect compose [gradient 1x1 (sky) (water)]
		across
		here: at
		draw-image: image white 699x400 effect [draw []]
		feel [engage: func [face action event] [
			
			if all [type start type <> 'polygon] [
				if find [over away] action [
					;append draw-pos draw event/offset
					append clear draw-pos draw event/offset
					;probe draw-image/effect/draw
					show face
				]
				if action = 'up [
					append/only undos draw-pos
					;probe draw-pos
					draw-pos: tail draw-pos
					start: none
					;probe draw-image/effect/draw
				]
			]
			if type = 'polygon [
				if action = 'down [  ;print 1
					append segments event/offset
					append clear draw-pos draw event/offset
					show face
					empty: true
				]
				if action = 'up [
					append/only undos draw-pos
					;probe draw-pos
					draw-pos: tail draw-pos
					start: none
					draw-image/effect/draw

				]
			]
			if all [type action = 'down] [ ;probe type
				start: event/offset
			]
		]]
		do [draw-pos: draw-image/effect/draw]
		guide
		style text text [
			tmp: first back find face/parent-face/pane face
			tmp/feel/engage tmp 'down none
			tmp/feel/engage tmp 'up none
		]
		vtext 200 bold gold as-is rejoin ["World's smallest^/paint program (" round/to (length? read system/options/script) / 1000 0.01 "K)"]
		;across
		return
		label "Tool:" 
		return
		radio [type: 'line clear segments empty: false] text "Line"
		return
		radio [type: 'box clear segments empty: false] on text "Box"
		return
		radio [type: 'circle clear segments empty: false] text "Circle"
		return
		radio [type: 'polygon clear segments empty: false] text "Polygon"
		return
		style color-box box 15x15 [
			face/color: either face/color [request-color/color face/color] [request-color]
		] ibevel
		color: color-box 0.0.0 text "Pen"
		return
		fill-color: color-box text "Fill-pen"
		return
		text "Transparency" []
		return
		transp: slider 100x15 [ transparency: round face/data * 255 tr/text: join round face/data * 100 "%" show tr]
		return
		tr: text 100 "0 %"
		at here + 0x401 ;across return
		space 1
		style footer button 174x35 50.0.150 with [
			edge: make face/edge [size: 0x0 color: black effect: none]
			font: make face/font [name: "tahoma" size: 12 style: none valign: 'middle colors: [170.170.170 255.255.255]]
			effect: none
		]

		footer "Undo" [if not empty? undos [
			append/only redos copy last undos
			draw-pos: clear last undos
			remove back tail undos
			;segments: copy []
			show draw-image
		]]
		;return
		footer "Redo" [if not empty? redos [
			append/only undos draw-pos
			draw-pos: insert draw-pos last redos
			remove back tail redos
			show draw-image
		]]
		;return
		footer "Clear" [
			if not confirm "Clear image?" [exit]
			clear draw-pos: head draw-pos
			clear probe segments
			empty: false
			undos: copy [] redos: copy []
			show draw-image
		]
		;return
		footer "Quit" 150.0.0 200.70.70 [quit] ;"Size" [print join round (length? read system/options/script) / 1000 " ko"]

		] 900x500
]