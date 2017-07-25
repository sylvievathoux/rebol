Rebol [
	Title:  "Scroller demo"
	Name: "scroller2"
	Author: "JP"
	Date:   "17-Dec-2016"
	Needs:  none
	File:	%scroller2.r
	Tabs:   4
	License: none
	]

print system/script/header/name
probe pth: first request-file/path
files: sort read pth

list-files: copy []

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
	           pane/1/color: black ;black ;snow ;128.128.128
	           pane/1/edge/color: 0
	           pane/1/edge/size: 0x0
			   pane/1/effect: [draw [
					pen red line-width 2 line-cap square line 5x19 15x19 line 5x23 15x23 line 5x27 15x27]]
               pane/2/edge/size: pane/3/edge/size: 0x0
               pane/2/edge/color: pane/3/edge/color: snow
			   pane/2/effect: pane/3/effect: none
			   pane/2/colors/1: pane/3/colors/1: black
			   pane/2/effect: [draw [pen red line-width 2 line-cap square line 5x11 10x6 15x11]]
   			   pane/3/effect: [draw [pen red line-width 2 line-cap square line 5x6 10x11 15x6]]

        ]

	]
]


foreach item files [append/only list-files reduce [
        item
        size? item
        modified? item      
        ]
    ]
n:   0 ;scroller starter for list
fsize: 10
ft: make face/font [name: "arial" size: fsize valign: 'middle align: 'left style: none]

view/new center-face layout [
    across
    backdrop effect [gradient 1x1 20.20.20 100.100.120]
    text as-is white bold join "Path:   " what-dir    
    return
	here: at
    li: list 400x400 220.220.220 [
        across space 1x0
        txt to-pair reduce [170 round (fsize * 1.8)] with [para: make para [wrap?: false] font: :ft][print face/text focus li] ; show li]
        txt to-pair reduce [50 round (fsize * 1.8)] 180.0.0 right with [para: make para [wrap?: false] font: ft][print face/text focus li]
        txt to-pair reduce [180 round (fsize * 1.8)] right with [para: make para [wrap?: false] font: ft][print face/text focus li]
        ] supply [
			either even? count [face/color: white] [face/color: 200.200.200]
            count: count + n ; n is the amount of scrolling for data
            either count <= length? files [ face/text: list-files/:count/:index ] [face/text: ""]          
        ] edge [size: 0x0
		] feel [
			engage: func [face action event] [
				if action = 'key [
					either word? event/key [
						print ["Special key:" event/key]
					][
						print ["Normal key:" mold event/key]
					]
				]
				if action = 'scroll-line [scr/data: max 0 scr/data + (event/offset/y / length? list-files) print n: to-integer (scr/data * (length? list-files)) show scr show li]
			]
			;over: func [face act pos] [li_over: act ]
			over: func [face action offset] [focus li] ; show li] ; print form offset show face]
		]
	;pad -3x0	
	pad -7x0	
	scr: JP-scroller 20x400 [
        n: to-integer (face/data * (length? list-files)) 
		probe reduce  [n scr/data scr/size/y]		
        show li
       ] 
	;at here
	;s: sensor 400x400
]
focus li
do-events
	
	
	
	
	
	
	
	
	
	
	
	
	
	