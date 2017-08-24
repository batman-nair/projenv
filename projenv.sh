#!/bin/bash

#define the height in px of the top system-bar:
TOPMARGIN=27

# get width of screen and height of screen
SCREEN_WIDTH=$(xwininfo -root | awk '$1=="Width:" {print $2}')
SCREEN_HEIGHT=$(xwininfo -root | awk '$1=="Height:" {print $2}')

saving=1

while test $# -gt 0; do
        case "$1" in
			-h|--help)
				echo "projenv - Save and open window arrangements"
				echo " "
				# echo "projenv [options] application [arguments]"
				# echo " "
				echo "options:"
				echo "-h, --help                show brief help"
				echo "-o, --open=FILE       	open a projenv file"
				echo "-s, --save=FILE      		save current window arrangement"
				exit 0
				;;
			-s)
				shift
				filename=$1
				saving=1
				shift
				;;
			-o)
				shift
				filename=$1
				saving=0
				shift
				;;
			*)
				break
				;;
        esac
done

if [ -z $filename ]; then
	echo Quicksave file taken
	filename="quicksave.pe"
fi

if [ $saving == 1 ]; then
	rm "$filename"
	while read winid dID PID X Y W H CMD_FLAG NAME
	do
		# echo ps --no-headers -p $PID -o cmd
		cmd=$(ps --no-headers -p $PID -o cmd)
		echo -e "$cmd\t$dID $X $Y $W $H" >> "$filename"

	done <<< "$(wmctrl -lGpx)"

else
	while read line
	do
		# echo $prog $dID $pos
		prog=$(echo -e "$line" | cut -f1 | awk '{ print $1 }')
		winDetails=( $(echo -e "$line" | cut -f2) )
		dID=${winDetails[0]}
		pos=${winDetails[1]}

		#Already running window list
		initnumWindows=$(wmctrl -l | wc -l)
		#Already running prog instance list
		initWindowsWinID="$(wmctrl -lp | awk '{ print $1 }')"
		
		echo running $prog
		#Run program
		eval $prog & disown

		#Wait for program to create window
		timedOut=0
		timeout=$((SECONDS+3))
		while [ $(wmctrl -l | wc -l) -eq $initnumWindows ]
		do
			if [ $SECONDS -gt $timeout ]; then
				echo Program window open timed out 
				timedOut=1
				break
			fi
		done
		if [ $timedOut -eq 1 ]; then
			echo Executing next command
			continue
		fi
		#list of prog windows after creation
		finalWindows="$(wmctrl -lxp)"
		reqdWindow="$finalWindows"
		

		#delete all windows that were opened before
		while read -r WinID; do
			echo "before delete $reqdWindow"
		    echo try delete WinID $WinID
			reqdWindow=$(echo "$reqdWindow" | grep -v $WinID)
			echo "after delete $reqdWindow"
		done <<< "$initWindowsWinID"

		#get required window id
		echo Init "$initWindowsPID"
		echo final "$finalWindows"
		echo reqd "$reqdWindow"

		winid=$(echo $reqdWindow | awk '{print $1}')
		echo New $prog window created $winid

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

		elif [[ $pos =~ ^[0-9]* ]]; then
			X=${winDetails[1]}
			Y=${winDetails[2]}
			W=${winDetails[3]}
			H=${winDetails[4]}

		fi 
		
		#Move the window accordingly
		echo "wmctrl -ir $winid -b remove,maximized_horz,maximized_vert && wmctrl -ir $winid -t $dID && wmctrl -ir $winid -e 0,$X,$Y,$W,$H "
		wmctrl -ir $winid -b remove,maximized_horz,maximized_vert && wmctrl -ir $winid -t $dID && wmctrl -ir $winid -e 0,$X,$Y,$W,$H 

	done < "$filename"

fi