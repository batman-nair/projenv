#!/bin/bash

#define the height in px of the top system-bar:
TOPMARGIN=27

# get width of screen and height of screen
SCREEN_WIDTH=$(xwininfo -root | awk '$1=="Width:" {print $2}')
SCREEN_HEIGHT=$(xwininfo -root | awk '$1=="Height:" {print $2}')

filename=web-dev.pe

while read prog dID pos
do
	echo $prog $dID $pos

	#Already running window list
	initnumWindows=$(wmctrl -l | wc -l)
	#Already running prog instance list
	initWindows=$(wmctrl -l | grep -i $prog)
	
	#Run program
	$prog & disown

	#Wait for program to create window
	while [ $(wmctrl -l | wc -l) -eq $initnumWindows ]
	do
		true
	done

	#list of prog windows after creation
	finalWindows=$(wmctrl -l | grep -i $prog)
	reqdWindow=$finalWindows
	
	#delete all windows that were opened before
	for line in $initWindows
	do
		reqdWindow=$(echo $reqdWindow | sed '/$line/d')
	done
	#get required window id
	winid=$(echo $reqdWindow | grep -i $prog | awk '{print $1}')
	echo New $prog window created $winid

	#Calculate required positioning
	if [ "$pos" == "right" ]; then

		W=$(( $SCREEN_WIDTH / 2 ))
		H=$(( $SCREEN_HEIGHT - 2 * $TOPMARGIN ))

		X=$(( $SCREEN_WIDTH / 2 ))
		Y=$TOPMARGIN

		echo To move right

	elif [ "$pos" == "left" ]; then

		W=$(( $SCREEN_WIDTH / 2 ))
		H=$(( $SCREEN_HEIGHT - 2 * $TOPMARGIN ))

		X=0
		Y=$TOPMARGIN

		echo To move left
	
	elif [ "$pos" == "full" ]; then

		W=$(( $SCREEN_WIDTH ))
		H=$(( $SCREEN_HEIGHT - 2 * $TOPMARGIN ))

		X=0
		Y=$TOPMARGIN

		echo To move full
	fi 
	
	#Move the window accordingly
	wmctrl -ir $winid -b remove,maximized_horz,maximized_vert && wmctrl -ir $winid -t $dID && wmctrl -ir $winid -e 0,$X,$Y,$W,$H 

done < "$filename"