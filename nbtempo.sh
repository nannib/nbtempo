#!/bin/bash
#NBTempo by Nanni Bassetti  - http://www.nannibassetti.com  - digitfor@gmail.com
#web site: http://scripts4cf.sf.net

# 

check_cancel()
{
	if [ $? -gt 0 ]; then
		exit 1
	fi
}

check_timebody()
{
timebody_yn="$(yad --form --image="dialog-question" \
	--title "Data gathering check" \
	--text "Have you already created a timeline for this device\?" \
	--field="Answer:CB" '?!No!Yes!')"
check_cancel

timebody_yn="$(echo $timebody_yn | tr "|" " ")"

}

if [ "$(id -ru)" != "0" ];then
	gksu -k -S -m "Enter root password to continue" -D "NBTEMPO requires root user priveleges." echo
fi

yad --title="NBTEMPO 1.1" --text "Welcome to NBTEMPO 1.1\n by Nanni bassetti\n http://ww.nannibassetti.com\n"
check_cancel

img="$(yad --file-selection \
	--multiple \
	--height 400 \
	--width 600 \
	--title "Disk Image or Device Selection" \
	--text " Insert image file or dev (e.g. /dev/sda or disk.img)\n")"
check_cancel

dr="$(yad --file-selection --directory \
	--height 400 \
	--width 600 \
	--title "Insert destination directory mounted in rw " \
	--text " Select or create a directory (e.g. /media/sdb1/results) \n")"
check_cancel


gmt="$(yad --entry \
	--width 350 \
	--title "Insert the UTC or GMT time (e.g. UTC+1 or GMT+1)" \
	--entry-label="Insert the UTC or GMT time (e.g. UTC+1 or GMT+1)" \
	--text "Leave empty for local time settings" \
	--entry-text="")" 
check_cancel


s="$(yad --entry \
	--title "Time skew" \
	--text "Insert the time skew in seconds (e.g. 600 for 10 minutes)" \
	--entry-text="0")" 
check_cancel


fdate="$(yad --calendar \
	--title "From date" \
	--text "Insert FROM date" \
	--date-format=%Y-%m-%d)" 
check_cancel

todate="$(yad --calendar \
	--title "To date" \
	--text "Insert TO date" \
	--date-format=%Y-%m-%d)"
check_cancel

sudo mmls $img | tee $dr/data-$fdate-$todate.txt;

if [ "$gmt" != "" ]; then
z="$(echo "-z "$gmt)"
fi

sudo echo "device: "$img" from: "$fdate" to: "$todate" Time Zone: "$gmt" time skew: "$s >> $dr/data-$fdate-$todate.txt

check_timebody

while [ "$timebody_yn" = "? " ]; do
check_timebody
done

if [ "$timebody_yn" = "No " ]; then
sudo tsk_gettimes $img $z -s $s | tee $dr/times.txt | yad  --progress --title "time body creating" --width=600 --rtl --auto-close --auto-kill 
fi

sudo mactime -b $dr/times.txt -d $fdate..$todate | tee $dr/report-$fdate-$todate.csv | yad  --progress --title "time line creating - WAIT!!!"  --width=600 --rtl --auto-close --auto-kill 

if [ $? = 0 ]; then
	yad  --width 600 \--title "nbtempo" --text "Operation succeeded!\n\nYour report is $dr"
else
	yad --width 600 --title "nbtempo" --text "NBTEMPO encountered errors.\n\nPlease check your settings and try again"
fi
echo "Done!";
