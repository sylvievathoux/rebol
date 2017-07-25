;;//
rebol [
	Title: "Personnal Home Broadcast"
	File: %phb.r
    Author: "Jipé"
    Version: 0.0.5
    Needs: [view 2.7.8]
    Date: 1-Jan-2017
	Purpose: 	{ Broadcast the server address over the local network,
				and a list of ports to connect to.
				}
]

phb: make object! [

	timeout: 0:00:05
	initial-port: 11110
	max-ports: 3
	ports-list: copy []
	wait-list: copy []
	wait-time: 1.0
	connected-list: copy []
	server-str:
	local-ip:
	sender:
	str-ports:
	idx:
	set-mode: none
	
	init: does [
		;;Opens udp port and broadcasts server port address to local network
		system/schemes/default/timeout: 0:00:05 probe initial-port
		sender: open/lines join udp://255.255.255.255: initial-port
		;;System/network/host or /host-address >> 127.0.0.1 on linux !!
		set 'local-ip get in second get-modes sender 'interfaces 'addr
		set-modes sender [broadcast: on]	
		;;Populates ports list to be sent with max-ports port number
		repeat num max-ports [append ports-list initial-port + num]
		;;Waiting interval while listening to all ports
		insert wait-list wait-time
		;;Inits waiting ports
		foreach port ports-list [
			append wait-list open/lines join udp://: port
		]
		;;Server loop
		udp-loop
	]
	;;Server loop
	udp-loop: does [
	
		forever [
			either ((length? wait-list) - 1) < 1 [
				;;All open ports are busy...
				str-ports: {No more free ports to connect to.^/Ask your admin to add more ports.}
				insert sender str-ports
				;break 
				][
				foreach w wait-list [
					;;Broadcasts alternatively each listening port of the wait-list
					if not (any [decimal? w integer? w none? w]) [
						insert sender trim rejoin [local-ip ":" w/local-port]
						;;Then wait for connection
						p: wait wait-list
						;;If connection
						if not none? p [
							;;Gets the message and don't forget to COPY!! the p/object
							str: copy p
							;;Removes the newly connected-list port from the list
							remove find ports-list p/port-id
							;;And adds it to the yet connected-list ports list
							append/only connected-list reduce [p/port-id p/remote-ip]
							server-str: rejoin [  
								newline ">> Connection of remote host " p/remote-ip " - Received : " trim/lines str
								newline ">> Remaining ports : " pick reduce ["No more free ports..." form head ports-list] (length? wait-list) = 2
								newline ">> connected-list : " mold connected-list
							] 
							;;Closes p port and removes it from the available ports list
							close p
							remove find wait-list p
							print server-str
							server-str: copy ""
						]	
					]
				]
			]
			
			wait 1
			
		]
		
	]
	
]

phb/init
