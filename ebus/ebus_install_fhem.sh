#!/bin/sh
# amunra
INTERACTIVE=True
ASK_TO_REBOOT=0
calc_wt_size() {
# NOTE: it's tempting to redirect stderr to /dev/null, so supress error
# output from tput. However in this case, tput detects neither stdout or
# stderr is a tty and so only gives default 80, 24 values
WT_HEIGHT=17
WT_WIDTH=$(tput cols)
if [ -z "$WT_WIDTH" ] || [ "$WT_WIDTH" -lt 60 ]; then
WT_WIDTH=80
fi
if [ "$WT_WIDTH" -gt 178 ]; then
WT_WIDTH=120
fi
WT_MENU_HEIGHT=$(($WT_HEIGHT-8))
}
#_________________________________________________________
do_finish() {
exit 0
}
#________________________________________________

#________________________________________________
do_install_gaebus(){
	sudo wget http://sourceforge.net/p/fhem/code/HEAD/tree/trunk/fhem/contrib/98_GAEBUS.pm?format=raw -O 98_GAEBUS.pm
}
#
# Interactive use loop
#
calc_wt_size
while true; do
FUN=$(whiptail --title "eBus Install and Configuration Tool $(hostname)" --menu "Setup Options" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Finish --ok-button Select \
"1 FHEM" "Install FHEM" \
"2 EBUSD Package" "Install EBUSD Debian Package" \
"3 EBUSD Config Package" "Install EBUSD Config Debian Package" \
"4 ECMD Heizkurve 430" "Install ECMD Heatingcurve for VRC 430" \
"4 ECMD Heizkurve 470" "Install ECMD Heatingcurve for VRC 470" \
"5 GAEBUS" "Install GAEBUS FHEM Modul" \
3>&1 1>&2 2>&3)
RET=$?
if [ $RET -eq 1 ]; then
	do_finish
elif [ $RET -eq 0 ]; then
	case "$FUN" in
		1\ *) do_dummy ;;
		2\ *) do_dummy2 ;;
		3\ *) do_dummy3 ;;
		4\ *) do_dummy4 ;;
		5\ *) do_install_gaebus ;;
		6\ *) do_about ;;
		*) whiptail --msgbox "Programmer error: unrecognized option" 20 60 1 ;;
	esac || whiptail --msgbox "There was an error running option $FUN" 20 60 1
	else
		exit 1
fi
done
