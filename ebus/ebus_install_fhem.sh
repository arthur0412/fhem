#!/bin/sh
# you can install this installer with there commands
# sudo wget http://sourceforge.net/projects/ebus-installer/files/eBusInstaller/ebus_install_fhem.sh/download -O ebus_install_fhem.sh 
# sudo chmod 775 ebus_install_fhem.sh
# sudo ./ebus_install_fhem.sh
#
# Author's: amunra, reinhart

Version="V0.8.1"

#######################
#   please change me  #
Duplicate=false       # False=change in orignal fhem.cfg, true=make a copy fhem-install.cfg
IPRaspi="10.0.0.6"    # IP Adresses of the eBus Raspberry
Modify_cfg=true       # Config Files where modified for a correct Function
cleaning=true         # delete Install Files in $ebusinstallerdir
repoamunra=false	  # Change repo to amunra0412
#######################

# Log="/opt/fhem/log/fhem-install.log"
Log="/var/log/ebusinstaller.log"
BackupDir="/opt/fhem/backup/"$(date +"%Y%m%d")
ebusinstallerdir=$HOME"/ebusinstaller"
# eBusd Variablen
ebusdversion="ebusd-2.0_armhf.deb"
ebusdurl="https://github.com/john30/ebusd/releases/download/v2.0/$ebusdversion -O "

# eBusd Config Variablen
ebusdcfgversion="ebusd-configuration-2.0.5aa482c-de_all.deb"
ebusdcfgurl="https://github.com/john30/ebusd-configuration/releases/download/v2.0.1/$ebusdcfgversion -O "

# GAEBUS Variablen
gaebusdev="ebus2"
address="localhost:8888"
interval="900"

# FHEM Variablen
fhemplcmd='/opt/fhem/fhem.pl 7072'

# Download Files
url="http://sourceforge.net/projects/ebus-installer/files/eBusInstaller/"
urlpostfix="/download -O "

# Change to amunra0412 github repo
if [ $repoamunra = "true" ]; then
	url="https://raw.githubusercontent.com/arthur0412/fhem/master/ebus/installerfiles/"
	urlpostfix=" -O "
fi

hkurvecfg=$url"hkurve.cfg"$urlpostfix
bai01=$url"bai01.cfg"$urlpostfix
gaebus="http://sourceforge.net/p/fhem/code/HEAD/tree/trunk/fhem/contrib/98_GAEBUS.pm?format=raw -O "
ebuscfg=$url"EBUS.cfg"$urlpostfix
valvescfg=$url"valves.cfg"$urlpostfix
valvesmodule=$url"39_VALVES.pm"$urlpostfix
timercfg=$url"timer.cfg"$urlpostfix
bai02=$url"bai02.cfg"$urlpostfix
myUtils=$url"99_myUtils.pm"$urlpostfix
MyUtilsHeader=$url"99_myUtils_Header.pm"$urlpostfix
broadcastcsv=$url"broadcast.csv"$urlpostfix
templatescsv=$url"_templates.csv"$urlpostfix
ebusdlogrotate=$url"ebusd.logrotate"$urlpostfix
ebusddefault=$url"ebusd.default"$urlpostfix
customtabletuitar=$url"ftui.tar.gz"$urlpostfix

INTERACTIVE=true
ASK_TO_REBOOT=0

# Check if user is root
if [ "$(id -u)" != "0" ]; then
	echo "[ ERROR ] You must be root to run this script !!!"
		exit 1
fi

# prepare Filename for modification
if [ "$Duplicate" = "true" ]; then
   Filename=fhem-installer.cfg  
 else
   Filename=fhem.cfg
fi

# only for backupdir
Filedate=`date "+%d%m%H%M"`
echo Filedatum=$Filedate, $Filename, $IPRaspi, $Log 
echo Filedatum=$Filedate, $Filename, $IPRaspi, $Log >>$Log

prepinstaller() {
	if [ ! -f $ebusinstallerdir ]; then
		echo '[ .. ] prepare ebusinstaller: '$ebusinstallerdir
		echo $(date +"%m-%d-%Y %T")	'[ .. ] prepare ebusinstaller: '$ebusinstallerdir >> $Log
		sudo mkdir -p $ebusinstallerdir
		sudo chmod 777 $ebusinstallerdir
		echo '[ ok ] prepare ebusinstaller: '$ebusinstallerdir' done'
		echo $(date +"%m-%d-%Y %T")	'[ ok ] prepare ebusinstaller: '$ebusinstallerdir' done' >> $Log
	fi
	return
}

cleanupinstaller() {
	if [ "$cleaning" = "true" ]; then
		if [ ! -f $ebusinstallerdir ]; then
			echo '[ .. ] cleanup ebusinstaller: '$ebusinstallerdir
			echo $(date +"%m-%d-%Y %T")	'[ .. ] cleanup ebusinstaller: '$ebusinstallerdir >> $Log
			sudo rm -r -f $ebusinstallerdir
			echo '[ ok ] cleanup ebusinstaller: '$ebusinstallerdir' done'
			echo $(date +"%m-%d-%Y %T")	'[ ok ] cleanup ebusinstaller: '$ebusinstallerdir' done' >> $Log
		fi
	fi 
}

checkfhemcon() {
	echo '[ .. ] test connection to FHEM Server'
	echo $(date +"%m-%d-%Y %T")	'[ .. ] test connection to FHEM Server' >> $Log
	fhemcon=`sudo perl $fhemplcmd 'list TYPE=Global NAME' | awk '{split($0,a," "); print a[1]}'` >> $Log
	# result=`echo "$con" | awk '{split($0,a," "); print a[1]}'`
	echo '[ .. ] test connection to FHEM Server Result:' $fhemcon
	echo '[ ok ] test connection to FHEM Server done'
	echo $(date +"%m-%d-%Y %T")	'[ ok ] test connection to FHEM Server done' >> $Log
	return
}

backupfhemfile() {

	fhemfile=${1}

	echo '[ .. ] backup '$ebusinstallerdir/$fhemfile
	if [ -e $ebusinstallerdir/$fhemfile ]; then
		
		if [ -e "/opt/fhem/FHEM/"$fhemfile ]; then  # If File exist
			if [ ! -d $BackupDir ]; then # Create Backup dir if not exist
				echo '[ .. ] create backup directory ('$BackupDir')'
				echo $(date +"%m-%d-%Y %T")	'[ .. ] create backup directory ('$BackupDir')' >> $Log
				sudo mkdir -p $BackupDir >> $Log
				sudo chmod 777 $BackupDir >> $Log
				echo '[ ok ] create backup directory ('$BackupDir') done'
				echo $(date +"%m-%d-%Y %T")	'[ ok ] create backup directory ('$BackupDir') done' >> $Log
			fi
			
			# Backup File
			echo '[ .. ] backup '$fhemfile
			echo $(date +"%m-%d-%Y %T")	'[ .. ] backup '$fhemfile >> $Log
			sudo cp /opt/fhem/FHEM/$fhemfile $BackupDir/$fhemfile$(date +"_%Y%m%d_%H%m%S") >> $Log
			echo '[ ok ] backup '$fhemfile' done'
			echo $(date +"%m-%d-%Y %T")	'[ ok ] backup '$fhemfile' done' >> $Log
		fi
		
		# File not exist
		echo '[ .. ] copy '$fhemfile
		echo $(date +"%m-%d-%Y %T")	'[ .. ] copy '$fhemfile >> $Log
		sudo cp $ebusinstallerdir/$fhemfile /opt/fhem/FHEM/$fhemfile
		sudo chown -R fhem:dialout /opt/fhem/FHEM/$fhemfile >> $Log # set permissions
		echo '[ ok ] copy '$fhemfile' done'
		echo $(date +"%m-%d-%Y %T")	'[ ok ] copy '$fhemfile' done' >> $Log
	fi
	return
}

backupfhemcfg() {
	
   # save existing fhem.cfg 
	echo '[ .. ] save existing fhem.cfg'
	echo $(date +"%m-%d-%Y %T")	'[ .. ] save existing fhem.cfg' >> $Log
	cp /opt/fhem/fhem.cfg /opt/fhem/fhem-installer.cfg
	if [ ! -e $BackupDir ]; then
		sudo mkdir -p $BackupDir
		sudo chmod 777 $BackupDir 
	fi
	cp /opt/fhem/fhem.cfg $BackupDir/fhem.cfg$(date +"_%Y%m%d_%H%m%S")
	echo '[ ok ] save existing fhem.cfg done'
	echo $(date +"%m-%d-%Y %T")	'[ ok ] save existing fhem.cfg done' >> $Log
	
	return
}

downloadfile() {
	urlfiename=${1}
	localfilename=${2}
	
	echo '[ .. ] download '$urlfiename$localfilename
	echo $(date +"%m-%d-%Y %T")	'[ .. ] download '$urlfiename$localfilename >> $Log
	sudo wget $urlfiename$localfilename >> $Log 2>&1
	# sudo wget $urlfiename$localfilename >> $Log # display progress
	# Check Filesize
	if [ "$(stat -c%s $localfilename)" = 0 ]; then echo '[ error ] Download failed - size of $localfilename is 0 bytes'; echo '[ error ] Download failed - size of $localfilename is 0 bytes' >> $Log; whiptail --title "File download failed - installation aborted" --msgbox "[ error ] Download failed - size of $localfilename is 0 bytes" 8 78; return 0; fi
	echo '[ ok ] download '$localfilename' done'
	echo $(date +"%m-%d-%Y %T")	'[ ok ] download '$localfilename' done' >> $Log
	
	return
}

calc_wt_size() {
 # NOTE: it's tempting to redirect stderr to /dev/null, so supress error
 # output from tput. However in this case, tput detects neither stdout or
 # stderr is a tty and so only gives default 80, 24 values
 WT_HEIGHT=18
 WT_WIDTH=$(tput cols)
 if [ -z "$WT_WIDTH" ] || [ "$WT_WIDTH" -lt 80 ]; then
   WT_WIDTH=80
 fi

 if [ "$WT_WIDTH" -gt 80 ]; then
   WT_WIDTH=80
 fi

 WT_MENU_HEIGHT=$(($WT_HEIGHT-8))
}
#_________________________________________________________
do_finish() {
exit 0
}
#_________________________________________________________
do_about() {
exit 0
}

blockingexisitingfhementries(){

	for Name in $*
	do
		echo '[ .. ] blocking existing '$Name' defines'
		echo $(date +"%m-%d-%Y %T")	'[ .. ] blocking existing '$Name' defines' >> $Log
		sed -e 's/define '"$Name"'/# define '"$Name"'/g' -i /opt/fhem/fhem-installer.cfg 
		sed -e 's/attr '"$Name"'/# attr '"$Name"'/g' -i /opt/fhem/fhem-installer.cfg 
		sed -e 's/set '"$Name"'/# set '"$Name"'/g' -i /opt/fhem/fhem-installer.cfg
		echo '[ ok ] blocking existing '$Name' defines done'
		echo $(date +"%m-%d-%Y %T")	'[ ok ] blocking existing '$Name' defines done' >> $Log
	done

}
#_________________________________________________________
do_parser(){
	DevName=${1}
	# echo running parser: $DevName

	# save existing fhem.cfg 
	backupfhemcfg
	
	# check existing entry and blocking
	blockingexisitingfhementries $DevName

	if [ $DevName = "EBUS" ]; then
		blockingexisitingfhementries "Aussentemp Vorlauf Ruecklauf PumpeWatt Fanspeed HKurve HeizkurveSchreiben"
	fi
	echo '[ ok ] check existing entry and blocking done'
	echo $(date +"%m-%d-%Y %T")	'[ ok ] check existing entry and blocking done' >> $Log
   
   # add the new extensions ebus1, EBUS, Heizkurve
   echo '[ ok ] add extensions in '$DevName.cfg
   echo $(date +"%m-%d-%Y %T")	'[ ok ] add extensions in '$DevName.cfg >> $Log
   if [ -e $ebusinstallerdir"/$DevName.cfg" ]; then
     cat $ebusinstallerdir/$DevName.cfg >> /opt/fhem/fhem-installer.cfg
   fi
   
   # add the new extensions in 99_myUtils.pm
   if [ -e $ebusinstallerdir"/99_myUtils.pm" ]; then
     echo add the new extensions in 99_myUtils.pm
	 echo add the new extensions in 99_myUtils.pm >>$Log
     sudo cp /opt/fhem/FHEM/99_myUtils.pm $BackupDir/99_myUtils.pm
     sudo cat $ebusinstallerdir/99_myUtils.pm >> /opt/fhem/FHEM/99_myUtils.pm
     rm $ebusinstallerdir/99_myUtils.pm
   fi

   if [ "$Duplicate" = "false" ]; then
     echo '[ .. ] copy installer.cfg into fhem.cfg'
     echo $(date +"%m-%d-%Y %T")	'[ .. ] copy installer.cfg into fhem.cfg' >> $Log
     cp /opt/fhem/fhem-installer.cfg /opt/fhem/$Filename
	 echo '[ ok ] copy installer.cfg into fhem.cfg done'
	 echo $(date +"%m-%d-%Y %T")	'[ ok ] copy installer.cfg into fhem.cfg done' >> $Log
   fi 
    
   # cleaning installpath 
   if [ "$cleaning" = "true" ]; then
	cleanupinstaller
   fi  
}   

#_________________________________________________________ 
do_install_ebusd(){

	eusadapterportdefault="/dev/ttyUSB0"
	eusadapterport=$(whiptail --inputbox "Please check and enter the eBus Adapter Port (/dev/ttyUSB0)" 8 78 $eusadapterportdefault --title "ebus Adapter Port" 3>&1 1>&2 2>&3)
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
		prepinstaller
		echo '[ .. ] installation eBusd is startet'
		echo $(date +"%m-%d-%Y %T")	'[ .. ] installation eBusd is startet' >> $Log
		downloadfile "$ebusdurl" $ebusinstallerdir/$ebusdversion
		echo '[ ok ] download eBusd finished'
		echo $(date +"%m-%d-%Y %T")	'[ ok ] download eBusd finished' >> $Log
		sudo sudo dpkg -i --force-overwrite $ebusinstallerdir/$ebusdversion
		echo '[ ok ] install eBusd finished'
		echo $(date +"%m-%d-%Y %T")	'[ ok ] install eBusd finished' >> $Log
		
		# do_install_ebuscfg
		
		echo '[ .. ] # set eBusd start parameter (/etc/default/ebusd)'
		echo $(date +"%m-%d-%Y %T")	'[ .. ] set eBusd start parameter (/etc/default/ebusd)' >> $Log
		usbfinal=`echo $eusadapterport | sed 's/\//\\\\\//g'`
		sed -e 's/\-\-scanconfig/\-d '"$usbfinal"' \-p 8888 \-l \/var\/log\/ebusd.log \-\-scanconfig/g' -i /etc/default/ebusd
		echo '[ ok ] set eBusd start parameter (/etc/default/ebusd) done'
		echo $(date +"%m-%d-%Y %T")	'[ ok ] set eBusd start parameter (/etc/default/ebusd) done' >> $Log

		sudo chown -R root:root /etc/logrotate.d/ebusd >> $Log # set permissions for root user and group
		
		sudo service ebusd restart
		
		# cleaning installpath	
		if [ "$cleaning" = "true" ]; then
			cleanupinstaller
		fi  
	else
		return 0
	fi
}

#_________________________________________________________
do_install_ebuscfg(){
	
	prepinstaller
	
	echo '[ .. ] installation eBuscfg is startet'
	echo $(date +"%m-%d-%Y %T")	'[ .. ] installation eBuscfg is startet' >> $Log
	downloadfile "$ebusdcfgurl" $ebusinstallerdir/$ebusdcfgversion
	echo '[ ok ] download eBuscfg finished'
	echo $(date +"%m-%d-%Y %T")	'[ ok ] download eBuscfg finished' >> $Log
	sudo sudo dpkg -i --force-overwrite $ebusinstallerdir/$ebusdcfgversion
	echo '[ ok ] install eBuscfg finished'
	echo $(date +"%m-%d-%Y %T")	'[ ok ] install eBuscfg finished' >> $Log
	
	sudo service ebusd restart
	
	# do_reload_cfg
}
#_________________________________________________________ 
# do_reload_cfg(){
  
  # reload broadcast, logrotate and default for a correct configurtion
  # if [ "$Modify_cfg" = "true" ]; then
    # sudo wget http://sourceforge.net/projects/ebus-installer/files/eBusInstaller/broadcast.csv/download -O $ebusinstallerdir/broadcast.csv
    # echo download broadcast finished
    # echo download broadcast is finished >>$Log
    # sudo wget http://sourceforge.net/projects/ebus-installer/files/eBusInstaller/_templates.csv/download -O $ebusinstallerdir/_templates.csv
    # echo download _template.csv finished
    # echo download _template.csv is finished >>$Log
	
	# downloadfile "$ebusdlogrotate" $ebusinstallerdir/ebusd.logrotate
	
	# downloadfile "$ebusddefault" $ebusinstallerdir/ebusd.default

    # # check broadcast
    # if [ -e $ebusinstallerdir"/broadcast.csv" ]; then
      # if [ -e "/etc/ebusd/vaillant/broadcast.csv" ]; then
        # sudo cp -pa $ebusinstallerdir/broadcast.csv /etc/ebusd/vaillant/broadcast.csv
      # else
        # echo broadcast.csv is misssing, please check the congfigs in /etc/ebusd/
        # echo broadcast.csv is misssing, please check the congfigs in /etc/ebusd/ >>$Log 
      # fi
    # fi

    # # check template
    # if [ -e $ebusinstallerdir"/_templates.csv" ]; then
      # if [ -e "/etc/ebusd/vaillant/_templates.csv" ]; then
        # sudo cp -pa $ebusinstallerdir/_templates.csv /etc/ebusd/vaillant/_templates.csv
      # else
        # echo _template.csv is misssing, please check the congfigs in /etc/ebusd/
        # echo _template.csv is misssing, please check the congfigs in /etc/ebusd/ >>$Log 
      # fi
    # fi
    
	# check logrotate
	# if [ -e $ebusinstallerdir"/ebusd.logrotate" ]; then
		# sudo cp -pa $ebusinstallerdir/ebusd.logrotate /etc/logrotate.d/ebusd
	# fi

	# if [ -e $ebusinstallerdir"/ebusd.default" ]; then
		# sudo cp -pa $ebusinstallerdir/ebusd.default /etc/default/ebusd
	# fi

	# check 470 for write
	# if [ -e "/etc/ebusd/vaillant/15.470.csv" ]; then
	  # sed -e 's/r;wi,,Hc1HeatCurve/r;w,,Hc1HeatCurve/g' -i /etc/ebusd/vaillant/15.470.csv
	  # echo Hc1HeatCurve 470 is mofified
	  # echo Hc1HeatCurve 470 is mofified >>$Log
	# fi
	# fi

	# cleaning installpath  
	# if [ "$cleaning" = "true" ]; then
		# cleanupinstaller
	# fi 

	# sudo service ebusd restart
# }

#_________________________________________________________
do_install_ecmdbasis(){

	ebusdhost=$(whiptail --inputbox "Please enter Hostname/IP-Address and Port of the ebusd Server?" 8 78 $address --title "ebusd Hostname/IP-Address" 3>&1 1>&2 2>&3)
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
		# echo "User selected Ok and entered " $ebusdhost
		address=$ebusdhost
		
		prepinstaller
		
		# download and extract ebus1.cfg
		downloadfile "$bai01" $ebusinstallerdir/bai01.cfg
		
		# download and extract EBUS.cfg
		downloadfile "$ebuscfg" $ebusinstallerdir/EBUS.cfg
		
		# change IP for Raspi
		sed -e 's/localhost:8888/'"$address"'/g' -i $ebusinstallerdir/EBUS.cfg
		
		# Backup bai01.cfg
		backupfhemfile bai01.cfg

		do_parser EBUS
		
	else
		return 0
	fi
	
}

#_________________________________________________________
do_install_hcurve() {

	thermostat=$(whiptail --title "Select your room thermostat" --menu "Choose an option" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT \
	"430" "calorMATIC VRC 430" \
	"470" "calorMATIC VRC 470 / 470f" 3>&1 1>&2 2>&3)

	exitstatus=$?
	if [ $exitstatus = 0 ]; then
		
		prepinstaller
		
		# download Heizkurve.cfg
		downloadfile "$hkurvecfg" $ebusinstallerdir/Heizkurve.cfg

		# download bai01.cfg
		downloadfile "$bai01" $ebusinstallerdir/bai01.cfg

		# Backup bai01.cfg
		backupfhemfile bai01.cfg
		
		# # change 430 to ???
		echo '[ .. ] modify Hc1HeatCurve to '$thermostat
		echo $(date +"%m-%d-%Y %T")	'[ .. ] modify Hc1HeatCurve to '$thermostat >> $Log
		sed -e 's/-c 430 Hc1HeatCurve/-c '$thermostat' Hc1HeatCurve/g' -i /opt/fhem/FHEM/bai01.cfg
		echo '[ ok ] modify Hc1HeatCurve to '$thermostat' done'
		echo $(date +"%m-%d-%Y %T")	'[ ok ] modify Hc1HeatCurve to '$thermostat' done' >> $Log
		
		do_parser Heizkurve
		
	else
		return 0
	fi

}

#_________________________________________________________
do_install_valves(){
	
	prepinstaller
	
	# Check Module
	if [ ! -e /opt/fhem/FHEM/39_VALVES.pm ]; then
	 downloadfile "$valvesmodule" $ebusinstallerdir/39_VALVES.pm
	 backupfhemfile 39_VALVES.pm
	fi
	
	# Backup fhem.cfg
	backupfhemcfg

	# Download valves config
	downloadfile "$valvescfg" $ebusinstallerdir/valves.cfg
     
	# check if existing
	if [ -e $ebusinstallerdir"/valves.cfg" ]; then 
		sudo cat $ebusinstallerdir/valves.cfg >> /opt/fhem/fhem-installer.cfg
		echo valves.cfg is modified
		echo valves.cfg is modified >>$Log
	fi 
	
	blockingexisitingfhementries "ValWichtung FileLog_ValWichtung weblink_ValWichtung ValSchwelle ValAutoHeizkurve ValWinter Heizkurve_Check"

	if [ "$Duplicate" = "false" ]; then
		cp /opt/fhem/fhem-installer.cfg /opt/fhem/$Filename
		echo fhem.cfg is modified
		echo fhem.cfg is modified >>$Log      
	fi 
  
	# cleaning installpath 
	if [ "$cleaning" = "true" ]; then
		cleanupinstaller
	fi  

	whiptail --title "Plese define Heizkoerper1-Heizkoerper3 in fhem.cfg" --msgbox "*********** Plese define Heizkoerper1-Heizkoerper3 in fhem.cfg ***********\n" 8 78
	echo **************************************************************** >>$Log
	echo ****** Plese define Heizkoerper1-Heizkoerper3 in fhem.cfg ****** >>$Log
	echo **************************************************************** >>$Log
} 

#_________________________________________________________
do_install_timer(){

thermostat=$(whiptail --title "Select your room thermostat" --menu "Choose an option" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT \
"430" "calorMATIC VRC 430" \
"470" "calorMATIC VRC 470 / 470f" 3>&1 1>&2 2>&3)

exitstatus=$?
if [ $exitstatus = 0 ]; then
		
	prepinstaller
	
	# Backup fhem.cfg
	backupfhemcfg

	# Download timer.cfg
	downloadfile "$timercfg" $ebusinstallerdir/timer.cfg

	# Download bai02.cfg
	downloadfile "$bai02" $ebusinstallerdir/bai02.cfg

	# Download 99_myUtils.pm
	downloadfile "$myUtils" $ebusinstallerdir/99_myUtils.pm

	# Download 99_myUtils_Header.pm
	downloadfile "$MyUtilsHeader" $ebusinstallerdir/99_myUtils_Header.pm
	 
	# check if existing
	blockingexisitingfhementries "ZProg ZeitfensterSchreiben"

	if [ -e $ebusinstallerdir"/timer.cfg" ]; then 
		sudo cat $ebusinstallerdir/timer.cfg >> /opt/fhem/fhem-installer.cfg
		echo timer.cfg is modified
		echo timer.cfg is modified >>$Log
	fi 

	# check if existing bai01.cfg
	if [ -e "/opt/fhem/FHEM/bai01.cfg" ]; then
		for Name in  ZeitfensterSchreiben Mo Di Mi Do Fr Sa So
		do
			echo search and replace.. $Name
			echo search and replace.. $Name >>$Log
			sed -e 's/get '"$Name"'/# get '"$Name"'/g' -i /opt/fhem/FHEM/bai01.cfg 
		done
	fi

	# install ECMD Definition
	cat $ebusinstallerdir/bai02.cfg >> /opt/fhem/FHEM/bai01.cfg

	# check if existing 99_myUtils.pm
	if [ ! -e "/opt/fhem/FHEM/99_myUtils.pm" ]; then 
		# install Header for 99_myUtils.pm, non exist
		if [ -e $ebusinstallerdir"/99_myUtils_Header.pm" ]; then
			cat $ebusinstallerdir/99_myUtils_Header.pm >> /opt/fhem/FHEM/99_myUtils.pm
			echo install 99_myUtils_Header.pm
			echo install 99_myUtils_Header.pm >>$Log
		fi   
	fi

	# install Vaillant Definition in 99_myUtils.pm 
	if [ -e $ebusinstallerdir"/99_myUtils.pm" ]; then
		cat $ebusinstallerdir/99_myUtils.pm >> /opt/fhem/FHEM/99_myUtils.pm
		echo install 99_myUtils.pm
		echo install 99_myUtils.pm >>$Log
		sudo chmod 666 /opt/fhem/FHEM/99_myUtils.pm 
	fi   

	if [ "$Duplicate" = "false" ]; then
		cp /opt/fhem/fhem-installer.cfg /opt/fhem/$Filename 
		echo fhem.cfg is modified
		echo fhem.cfg is modified >>$Log
	fi 

	echo '[ .. ] modify write to '$thermostat
	echo $(date +"%m-%d-%Y %T")	'[ .. ] modify write to '$thermostat >> $Log
	sed -e 's/write -c 430/write -c '$thermostat'/g' -i /opt/fhem/FHEM/bai01.cfg
	echo '[ ok ] modify write to '$thermostat' done'
	echo $(date +"%m-%d-%Y %T")	'[ ok ] modify write to '$thermostat' done' >> $Log

	# cleaning installpath 
	if [ "$cleaning" = "true" ]; then
		cleanupinstaller
	fi

else
	return 0
fi

} 

#_________________________________________________________
do_install_gaebus(){

	ebusdhost=$(whiptail --inputbox "Please enter Hostname/IP-Address and Port of the ebusd Server?" 8 78 $address --title "ebusd Hostname/IP-Address" 3>&1 1>&2 2>&3)
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
	
		# echo "User selected Ok and entered " $ebusdhost
		address=$ebusdhost
		
		prepinstaller
		
		downloadfile "$gaebus" $ebusinstallerdir/98_GAEBUS.pm
		
		echo '[ .. ] copy 98_GAEBUS.pm to FHEM dir'
		echo $(date +"%m-%d-%Y %T")	'[ .. ] copy 98_GAEBUS.pm to FHEM dir' >> $Log
		sudo cp -f $ebusinstallerdir/98_GAEBUS.pm /opt/fhem/FHEM/98_GAEBUS.pm >> $Log
		echo '[ ok ] copy 98_GAEBUS.pm to FHEM dir done'
		echo $(date +"%m-%d-%Y %T")	'[ ok ] copy 98_GAEBUS.pm to FHEM dir done' >> $Log

		echo '[ .. ] set permission 755'
		echo $(date +"%m-%d-%Y %T")	'[ .. ] set permission 755' >> $Log	
		sudo chmod 755 /opt/fhem/FHEM/98_GAEBUS.pm >> $Log
		echo '[ ok ] set permission 755 done'
		echo $(date +"%m-%d-%Y %T")	'[ ok ] set permission 755 done' >> $Log

		checkfhemcon # Check connetion to FHEM Server

		if [ "$fhemcon" = "global" ]; then # connection to FHEM Server ist ok.
			output=`sudo perl $fhemplcmd 'list TYPE=GAEBUS NAME'`
			echo "$output" | while read a; do result=`echo $a | awk '{split($0,a," "); print a[1];}';` 
				if [ "$result" != "" ]; then # result not null
					if [ "$result" = "$gaebusdev" ]; then # name already exist
						echo '[ .. ] name already exist rename and disable it'
						echo $(date +"%m-%d-%Y %T")	'[ .. ]  name already exist rename and disable it' >> $Log
						sudo perl $fhemplcmd 'attr '$gaebusdev' disable 1' >> $Log
						echo '[ .. ] rename '$gaebusdev' to '$gaebusdev$(date +"_%Y%m%d_%H%m%S")
						sudo perl $fhemplcmd 'rename '$result' '$gaebusdev$(date +"_%Y%m%d_%H%m%S") >> $Log
						echo '[ .. ] save config...'
						sudo perl $fhemplcmd 'save' >> $Log
						sudo perl $fhemplcmd 'rereadcfg' >> $Log
						echo '[ ok ] name already exist rename and disable it done'
						echo $(date +"%m-%d-%Y %T")	'[ ok ]  name already exist rename and disable it done' >> $Log
					else
						echo '[ .. ] GAEBUS device '$result' exist disable it'
						echo $(date +"%m-%d-%Y %T")	'[ .. ]  GAEBUS device '$result'exist disable it' >> $Log
						sudo perl $fhemplcmd 'attr '$result' disable 1' >> $Log
						echo '[ ok ] GAEBUS device '$result' exist disable it done'
						echo $(date +"%m-%d-%Y %T")	'[ ok ]  GAEBUS device '$result'exist disable it done' >> $Log
					fi
				fi
			done

			echo '[ .. ] define new GAEBUS device'
			echo $(date +"%m-%d-%Y %T")	'[ .. ]  define new GAEBUS device' >> $Log
			sudo perl $fhemplcmd 'define '$gaebusdev' GAEBUS '$address' '$interval';attr '$gaebusdev' ebusWritesEnabled 1;attr '$gaebusdev' room GAEBUS' >> $Log
			echo '[ .. ] save config...'
			sudo perl $fhemplcmd 'save' >> $Log
			echo '[ ok ] define new GAEBUS device done'
			echo $(date +"%m-%d-%Y %T")	'[ ok ]  define new GAEBUS device done' >> $Log
		fi
		
		# cleaning installpath	
		if [ "$cleaning" = "true" ]; then
			cleanupinstaller
		fi

	else
		return 0
	fi

}
#_________________________________________________________ 
do_install_ftui(){

	prepinstaller
	
	# Backup fhem.cfg
	backupfhemcfg
	
	# backup existing tablet ui files
	if [ -d /opt/fhem/www/tablet ]; then
		echo '[ .. ] backup existing tablet ui files'
		echo $(date +"%m-%d-%Y %T")	'[ .. ]  backup existing tablet ui files' >> $Log
		sudo mkdir -p $BackupDir
		sudo chmod 777 $BackupDir
		sudo cp -r /opt/fhem/www/tablet $BackupDir/tablet 
		echo '[ ok ] backup existing tablet ui files done'
		echo $(date +"%m-%d-%Y %T")	'[ ok ] backup existing tablet ui files done' >> $Log
	fi

	# Donwload and exctract Tablet UI File
	downloadfile "$customtabletuitar" $ebusinstallerdir/ftui.tar.gz
	sudo tar -xzf $ebusinstallerdir/ftui.tar.gz -C /

	# check existing entry and blocking
	sed -e 's/define tablet_ui/# define tablet_ui/g' -i /opt/fhem/fhem-installer.cfg
	
	# define Tablet UI
	echo '[ .. ] define Tablet UI'
	echo $(date +"%m-%d-%Y %T")	'[ .. ]  define Tablet UI' >> $Log
	echo define tablet_ui HTTPSRV ftui/ ./www/tablet Tablet-UI >>/opt/fhem/fhem-installer.cfg
	echo '[ ok ] define Tablet UI done'
	echo $(date +"%m-%d-%Y %T")	'[ ok ] define Tablet UI done' >> $Log

	if [ "$Duplicate" = "false" ]; then
		cp /opt/fhem/fhem-installer.cfg /opt/fhem/fhem.cfg  
	fi  

	# cleaning installpath  
	if [ "$cleaning" = "true" ]; then
		cleanupinstaller
	fi   
	
}  
#_________________________________________________________ 
do_install_fhem(){  
   # save existing fhem.cfg 
   if [ -e /opt/fhem/fhem.cfg ]; then
     if [ ! -e $BackupDir ]; then
       sudo mkdir -p $BackupDir
       sudo chmod 777 $BackupDir 
       echo Backupdir created
       echo Backupdir created >>$Log
     fi
     cp /opt/fhem/fhem.cfg $BackupDir/fhem.cfg     
   fi

   if [ -e /etc/rc.local ]; then
      sudo rm /etc/rc.local
   fi
   
   cd /opt
   #sudo apt-get -y update
   #sudo apt-get -y upgrade     # make a problem with the followed wget

   sudo wget http://fhem.de/fhem-5.7.tar.gz
   echo Fhem is downloded
   echo Fhem is downloded >>$Log
   wait 1
      
   sudo tar xvf /opt/fhem-5.7.tar.gz
   echo Fhem is extracted
   echo Fhem is extracted >>$Log   
   wait 1
   
   # correct the original dir
   sudo cp -pa /opt/fhem-5.7/* /opt/fhem/
   sudo rm -r /opt/fhem-5.7
   echo dir fhem created
   echo dir fhem created >>$Log

   # cleanup tar
   sudo rm fhem-5.7.tar.g*

   sudo touch /etc/rc.local       
   sudo chmod 777 /etc/rc.local
   sudo echo cd /opt/fhem >> /etc/rc.local
   sudo echo "perl fhem.pl fhem.cfg &" >> /etc/rc.local
   sudo echo exit 0 >> /etc/rc.local
   sudo chmod a+x /etc/rc.local
   # make log writable
   sudo chmod 777 /opt/fhem/log
   sudo chmod 777 /opt/fhem/fhem.cfg

   echo FHEM is installed
   echo FHEM is installed >>$Log
 
   cd /opt
   sudo chmod -R a+w fhem
   sudo usermod -a -G tty pi
   sudo usermod -a -G tty fhem

   sudo wget http://sourceforge.net/projects/ebus-installer/files/eBusInstaller/fhem.cfg/download -O $ebusinstallerdir/fhem.cfg
   echo download fhem.cfg finished
    
   # restart fhem with new config
   cd /etc/init.d
   sudo ./fhem stop
   sudo ./fhem start
} 

#_________________________________________________________       
# Interactive use loop
calc_wt_size
while true; do
FUN=$(whiptail --title "eBus Install and Configuration Tool $(hostname) $Version" --menu "Setup Options" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Finish --ok-button Select --defaultno \
"1  eBusd Installation" "Daemon,Start/Stop,Log,Default" \
"2  eBusd Config Package" "CSV alle,Log,Logrotate,broadcast,templates" \
"3  ECMD Basis Package" "ECMD Devices,Classdef,Zyklus,bai00.cfg" \
"4  ECMD Heizkurve" "FHEM Config, bai01.cfg" \
"5  ECMD Valves Waermebedarfst." "39_Valves.pm, FHEM Config" \
"6  ECMD Zeitprogramme" "FHEM Config, bai01.cfg" \
"7  GAEBUS" "98_GAEBUS.pm, FHEM Config" \
"8  Tablet-UI" "Install UI HTML Demo Modul" \
3>&1 1>&2 2>&3)

RET=$?
if [ $RET -eq 1 ]; then
	do_finish
elif [ $RET -eq 0 ]; then
	case "$FUN" in
		1\ *) do_install_ebusd ;; #ok
		2\ *) do_install_ebuscfg ;; #ok
		3\ *) do_install_ecmdbasis ;;
		4\ *) do_install_hcurve ;;
		5\ *) do_install_valves ;;
		6\ *) do_install_timer ;;
		7\ *) do_install_gaebus ;; #ok
		8\ *) do_install_ftui ;;
		11\ *) do_install_fhem ;; #later version 2.0
		*) whiptail --msgbox "Programmer error: unrecognized option" 20 60 1 ;;
	esac || whiptail --msgbox "There was an error running option $FUN" 20 60 1
	else
		exit 1
fi
done
