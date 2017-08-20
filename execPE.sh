#!/bin/bash

#define the height in px of the top system-bar:
TOPMARGIN=27

# get width of screen and height of screen
SCREEN_WIDTH=$(xwininfo -root | awk '$1=="Width:" {print $2}')
SCREEN_HEIGHT=$(xwininfo -root | awk '$1=="Height:" {print $2}')

filename=$1

while read prog dID pos
do
	# echo $prog $dID $pos

	#Already running window list
	initnumWindows=$(wmctrl -l | wc -l)
	#Already running prog instance list
	initWindows="$(wmctrl -lx | grep -i $prog)"
	
	#Run program
	$prog & disown

	#Wait for program to create window
	while [ $(wmctrl -l | wc -l) -eq $initnumWindows ]
	do
		true
	done

	#list of prog windows after creation
	finalWindows="$(wmctrl -lx | grep -i $prog)"
	reqdWindow="$finalWindows"
	

	#delete all windows that were opened before
	while read -r line; do
		# echo "before delete $reqdWindow"
	    # echo try delete line $line
		reqdWindow="${reqdWindow//$line}" 
		# echo "after delete $reqdWindow"
	done <<< "$initWindows"

	#get required window id
	# echo Init "$initWindows"
	# echo final "$finalWindows"
	# echo reqd "$reqdWindow"

	winid=$(echo $reqdWindow | grep -i $prog | awk '{print $1}')
	# echo New $prog window created $winid

	#Calculate required positioning
	if [ "$pos" == "right" ]; then

		W=$(( $SCREEN_WIDTH / 2 ))
		H=$(( $SCREEN_HEIGHT - 2 * $TOPMARGIN ))

		X=$(( $SCREEN_WIDTH / 2 ))
		Y=$TOPMARGIN

		# echo To move right $X,$Y,$W,$H

	elif [ "$pos" == "left" ]; then

		W=$(( $SCREEN_WIDTH / 2 ))
		H=$(( $SCREEN_HEIGHT - 2 * $TOPMARGIN ))

		X=0
		Y=$TOPMARGIN

		# echo To move left $X,$Y,$W,$H
	
	elif [ "$pos" == "full" ]; then

		W=$(( $SCREEN_WIDTH ))
		H=$(( $SCREEN_HEIGHT - 2 * $TOPMARGIN ))

		X=0
		Y=$TOPMARGIN

		# echo To move full $X,$Y,$W,$H
	
	elif [ "$pos" == "bottom-left" ]; then

		W=$(( $SCREEN_WIDTH / 2 ))
		H=$(( $SCREEN_HEIGHT / 2 - 2 * $TOPMARGIN ))

		X=0
		Y=$(( $SCREEN_HEIGHT / 2 + $TOPMARGIN ))

		# echo To move bottom-left $X,$Y,$W,$H
	
	elif [ "$pos" == "bottom-right" ]; then

		W=$(( $SCREEN_WIDTH / 2 ))
		H=$(( $SCREEN_HEIGHT / 2 - 2 * $TOPMARGIN ))

		X=$(( $SCREEN_WIDTH / 2 ))
		Y=$(( $SCREEN_HEIGHT / 2 + $TOPMARGIN ))

		# echo To move bottom-right $X,$Y,$W,$H

	elif [ "$pos" == "top-left" ]; then

		W=$(( $SCREEN_WIDTH / 2 ))
		H=$(( $SCREEN_HEIGHT / 2 - 2 * $TOPMARGIN ))

		X=0
		Y=$TOPMARGIN

		# echo To move top-left $X,$Y,$W,$H
	
	elif [ "$pos" == "top-right" ]; then

		W=$(( $SCREEN_WIDTH / 2 ))
		H=$(( $SCREEN_HEIGHT / 2 - 2 * $TOPMARGIN ))

		X=$(( $SCREEN_WIDTH / 2 ))
		Y=$TOPMARGIN

		# echo To move top-left $X,$Y,$W,$H

	fi 
	
	#Move the window accordingly
	# echo "wmctrl -ir $winid -b remove,maximized_horz,maximized_vert && wmctrl -ir $winid -t $dID && wmctrl -ir $winid -e 0,$X,$Y,$W,$H "
	wmctrl -ir $winid -b remove,maximized_horz,maximized_vert && wmctrl -ir $winid -t $dID && wmctrl -ir $winid -e 0,$X,$Y,$W,$H 

done < "$filename"