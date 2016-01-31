#!/bin/sh
# amunra, reinhart

# you can install this installer with there commands
# sudo wget http://sourceforge.net/projects/ebus-installer/files/eBusInstaller/ebus_install_fhem.sh/download -O ebus_install_fhem.sh 
# sudo chmod 775 ebus_install_fhem.sh
# sudo ./ebus_install_fhem.sh

#######################
#   please change me  #
Duplicate=True        # False=change in orignal fhem.cfg, True=make a copy fhem-install.cfg
IPRaspi="10.0.0.6"    # IP Adresses of the eBus Raspberry
Modify_cfg=True       # Config Files where modified for a correct Function
Cleaning=True         # delete Install Files in /opt/fhem/install
#######################

Log="/opt/fhem/log/fhem-install.log"
BackupDir="/opt/fhem/backup"

INTERACTIVE=True
ASK_TO_REBOOT=0

# prepare Filename for modification
if [ "$Duplicate" = "True" ]; then
   Filename=fhem-installer.cfg  
 else
   Filename=fhem.cfg
fi

# create Logdir
if [ ! -e "/opt/fhem/log" ]; then
  sudo mkdir -p /opt/fhem/log
  sudo chmod 777 /opt/fhem/log 
  touch /opt/fhem/log/fhem-install.log
  echo Logdir created
  echo Logdir created >>$Log
fi

if [ ! -e "/opt/fhem/install" ]; then
  sudo mkdir -p /opt/fhem/install
  sudo chmod 777 /opt/fhem/install 
  echo Install dir created
  echo Install dir created >>$Log
fi

# only for backupdir
Filedate=`date "+%d%m%H%M"`
echo Filedatum=$Filedate, $Filename, $IPRaspi, $Log 
echo Filedatum=$Filedate, $Filename, $IPRaspi, $Log >>$Log

if [ ! -e $BackupDir ]; then
   mkdir -p $BackupDir
   sudo chmod 777 $BackupDir 
fi 

   
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
#_________________________________________________________
do_parser(){
   DevName=${1}
   echo running parser: $DevName
   # save existing fhem.cfg 
   cp /opt/fhem/fhem.cfg /opt/fhem/fhem-installer.cfg
   if [ ! -e $BackupDir/$Filedate ]; then
      sudo mkdir -p $BackupDir/$Filedate/
      sudo chmod 777 $BackupDir/$Filedate 
   fi
   cp /opt/fhem/fhem.cfg $BackupDir/$Filedate/fhem.cfg

   # check existing entry and blocking
   sed -e 's/define '"$DevName"'/# define '"$DevName"'/g' -i /opt/fhem/fhem-installer.cfg 
   sed -e 's/attr '"$DevName"'/# attr '"$DevName"'/g' -i /opt/fhem/fhem-installer.cfg 
   sed -e 's/set '"$DevName"'/# set '"$DevName"'/g' -i /opt/fhem/fhem-installer.cfg    

   if [ $DevName = "EBUS" ]; then
      for Name in Aussentemp Vorlauf Ruecklauf PumpeWatt Fanspeed HKurve HeizkurveSchreiben
         do
         echo search and replace.. $Name
         echo search and replace.. $Name >>$Log
         sed -e 's/define '"$Name"'/# define '"$Name"'/g' -i /opt/fhem/fhem-installer.cfg 
         sed -e 's/attr '"$Name"'/# attr '"$Name"'/g' -i /opt/fhem/fhem-installer.cfg 
         sed -e 's/set '"$Name"'/# set '"$Name"'/g' -i /opt/fhem/fhem-installer.cfg  
      done 
   fi
   
   # add the new extensions ebus1, EBUS, Heizkurve
   echo add extensions in $DevName.cfg
   echo add extensions in $DevName.cfg >>$Log
   if [ -e "/opt/fhem/install/$DevName.cfg" ]; then
     cat /opt/fhem/install/$DevName.cfg >> /opt/fhem/fhem-installer.cfg
   fi
   
   # add the new extensions in 99_myutils.pm
   if [ -e "/opt/fhem/install/99_myUtils.pm" ]; then
     sudo cp /opt/fhem/FHEM/99_myUtils.pm $BackupDir/$Filedate/99_myUtils.pm
     sudo cat /opt/fhem/install/99_myUtils.pm >> /opt/fhem/FHEM/99_myUtils.pm
     rm /opt/fhem/install/99_myUtils.pm
   fi

   if [ "$Duplicate" = "False" ]; then
     cp /opt/fhem/fhem-installer.cfg /opt/fhem/$Filename 
   fi 
    
   # cleaning installpath 
   if [ "$Cleaning" = "True" ]; then
     sudo rm /opt/fhem/install/*
   fi  
}   

#_________________________________________________________
do_install_gaebus(){
  echo installation GAEBUS is startet
  echo installation GAEBUS is startet >>$Log
	sudo wget http://sourceforge.net/p/fhem/code/HEAD/tree/trunk/fhem/contrib/98_GAEBUS.pm?format=raw -O /opt/fhem/install/98_GAEBUS.pm
  echo download 98_GAEBUS is finished
  echo download 98_GAEBUS is finished >>$Log
  sudo chmod 755 /opt/fhem/install/98_GAEBUS.pm

  # download and extract ebus1.cfg
  sudo wget http://sourceforge.net/projects/ebus-installer/files/eBusInstaller/ebus1.cfg/download -O /opt/fhem/install/ebus1.cfg
  # change IP for Raspi
  sed -e 's/localhost:8888/'"$IPRaspi"':8888/g' -i /opt/fhem/install/ebus1.cfg 
   
  if [ -e "/opt/fhem/install/98_GAEBUS.pm" ]; then
     sudo cp /opt/fhem/install/98_GAEBUS.pm /opt/fhem/FHEM/98_GAEBUS.pm
     echo 98_GAEBUS.pm is copied
     echo 98_GAEBUS.pm is copied >>$Log
  fi
  do_parser ebus1
}

#_________________________________________________________
do_install_ecmdbasis(){
  # download and extract ebus1.cfg
  sudo wget http://sourceforge.net/projects/ebus-installer/files/eBusInstaller/bai01.cfg/download -O /opt/fhem/install/bai01.cfg
  sudo wget http://sourceforge.net/projects/ebus-installer/files/eBusInstaller/EBUS.cfg/download -O /opt/fhem/install/EBUS.cfg


  # change IP for Raspi
  sed -e 's/localhost:8888/'"$IPRaspi"':8888/g' -i /opt/fhem/install/EBUS.cfg

  if [ -e "/opt/fhem/install/bai01.cfg" ]; then
     if [ -e "/opt/fhem/FHEM/bai01.cfg" ]; then  
        if [ ! -e $BackupDir/$Filedate ]; then
           sudo mkdir -p $BackupDir/$Filedate/
           sudo chmod 777 $BackupDir/$Filedate 
        fi
        sudo cp /opt/fhem/FHEM/bai01.cfg $BackupDir/$Filedate/bai01.cfg  
     fi
     sudo cp /opt/fhem/install/bai01.cfg /opt/fhem/FHEM/bai01.cfg
     echo bai01.cfg ecmdbasis is copied
     echo bai01.cfg ecmdbasis is copied >>$Log
  fi 
  do_parser EBUS
}

#_________________________________________________________
do_install_hcurve430(){
  sudo wget http://sourceforge.net/projects/ebus-installer/files/eBusInstaller/hkurve.cfg/download -O /opt/fhem/install/Heizkurve.cfg
  sudo wget http://sourceforge.net/projects/ebus-installer/files/eBusInstaller/bai01.cfg/download -O /opt/fhem/install/bai01.cfg

  if [ ! -e $BackupDir/$Filedate ]; then
      sudo mkdir -p $BackupDir/$Filedate/
      sudo chmod 777 $BackupDir/$Filedate 
  fi
   
  if [ -e "/opt/fhem/install/bai01.cfg" ]; then 
     if [ -e "/opt/fhem/FHEM/bai01.cfg" ]; then
        sudo cp /opt/fhem/FHEM/bai01.cfg $BackupDir/$Filedate/bai01.cfg  
     fi
     sudo cp /opt/fhem/install/bai01.cfg /opt/fhem/FHEM/bai01.cfg
     # change to 430
     sed -e 's/-c 470 Hc1HeatCurve/-c 430 Hc1HeatCurve/g' -i /opt/fhem/FHEM/bai01.cfg
     echo bai01.cfg 430 is copied
     echo bai01.cfg 430 is copied >>$Log
  fi 
  do_parser Heizkurve
}
#_________________________________________________________
do_install_hcurve470(){
  sudo wget http://sourceforge.net/projects/ebus-installer/files/eBusInstaller/hkurve.cfg/download -O /opt/fhem/install/Heizkurve.cfg
  sudo wget http://sourceforge.net/projects/ebus-installer/files/eBusInstaller/bai01.cfg/download -O /opt/fhem/install/bai01.cfg

  if [ ! -e $BackupDir/$Filedate ]; then
      sudo mkdir -p $BackupDir/$Filedate/
      sudo chmod 777 $BackupDir/$Filedate 
  fi
  
  if [ -e "/opt/fhem/install/bai01.cfg" ]; then 
     if [ -e "/opt/fhem/FHEM/bai01.cfg" ]; then
        sudo cp /opt/fhem/FHEM/bai01.cfg $BackupDir/$Filedate/bai01.cfg  
     fi
     sudo cp /opt/fhem/install/bai01.cfg /opt/fhem/FHEM/bai01.cfg
     # change to 470
     sed -e 's/-c 430 Hc1HeatCurve/-c 470 Hc1HeatCurve/g' -i /opt/fhem/FHEM/bai01.cfg  
     echo bai01.cfg 470 is copied
     echo bai01.cfg 470 is copied >>$Log
  fi 
  do_parser Heizkurve
} 
#_________________________________________________________
do_install_valves(){
   cp /opt/fhem/fhem.cfg /opt/fhem/fhem-installer.cfg
   if [ ! -e $BackupDir/$Filedate ]; then
      sudo mkdir -p $BackupDir/$Filedate/
      sudo chmod 777 $BackupDir/$Filedate 
   fi
   cp /opt/fhem/fhem.cfg $BackupDir/$Filedate/fhem.cfg

  sudo wget http://sourceforge.net/projects/ebus-installer/files/eBusInstaller/valves.cfg/download -O /opt/fhem/install/valves.cfg
  echo valves.cfg downloaded
  echo valves.cfg downloaded >>$Log 
     
  # check if existing
  for Name in ValWichtung FileLog_ValWichtung weblink_ValWichtung ValSchwelle ValAutoHeizkurve ValWinter Heizkurve_Check
         do
         echo search and replace.. $Name
         echo search and replace.. $Name >>$Log
         sed -e 's/define '"$Name"'/# define '"$Name"'/g' -i /opt/fhem/fhem-installer.cfg 
         sed -e 's/attr '"$Name"'/# attr '"$Name"'/g' -i /opt/fhem/fhem-installer.cfg 
         sed -e 's/set '"$Name"'/# set '"$Name"'/g' -i /opt/fhem/fhem-installer.cfg  
  done 

  if [ ! -e /opt/fhem/FHEM/39_VALVES.pm ]; then
     sudo wget http://sourceforge.net/projects/ebus-installer/files/eBusInstaller/39_VALVES.pm/download -O /opt/fhem/install/39_VALVES.pm
     sudo chmod 644 /opt/fhem/install/39_VALVES.pm
     sudo cp /opt/fhem/install/39_VALVES.pm /opt/fhem/FHEM/39_VALVES.pm
     echo 39_VALVES installed
     echo 39_VALVES installed >>$Log  
  fi
  
  if [ -e "/opt/fhem/install/valves.cfg" ]; then 
     sudo cat /opt/fhem/install/valves.cfg >> /opt/fhem/fhem-installer.cfg
     echo valves.cfg is modified
     echo valves.cfg is modified >>$Log
  fi 
  
  if [ "$Duplicate" = "False" ]; then
     cp /opt/fhem/fhem-installer.cfg /opt/fhem/$Filename
     echo fhem.cfg is modified
     echo fhem.cfg is modified >>$Log      
  fi 
  
  # cleaning installpath  
   if [ "$Cleaning" = "True" ]; then
     sudo rm /opt/fhem/install/*
   fi  
  echo ****************************************************************
  echo ****** Plese define Heizkoerper1-Heizkoerper3 in fhem.cfg ******
  echo ****************************************************************
  echo **************************************************************** >>$Log
  echo ****** Plese define Heizkoerper1-Heizkoerper3 in fhem.cfg ****** >>$Log
  echo **************************************************************** >>$Log
} 

#_________________________________________________________
do_install_timer(){
   echo VRC-Typ = $1
   
   cp /opt/fhem/fhem.cfg /opt/fhem/fhem-installer.cfg
   if [ ! -e $BackupDir/$Filedate ]; then
      sudo mkdir -p $BackupDir/$Filedate/
      sudo chmod 777 $BackupDir/$Filedate 
   fi
   cp /opt/fhem/fhem.cfg $BackupDir/$Filedate/fhem.cfg

  sudo wget http://sourceforge.net/projects/ebus-installer/files/eBusInstaller/timer.cfg/download -O /opt/fhem/install/timer.cfg
  echo timer.cfg downloaded
  echo timer.cfg downloaded >>$Log 

  sudo wget http://sourceforge.net/projects/ebus-installer/files/eBusInstaller/bai02.cfg/download -O /opt/fhem/install/bai02.cfg
  echo bai02.cfg downloaded
  echo bai02.cfg downloaded >>$Log 

  sudo wget http://sourceforge.net/projects/ebus-installer/files/eBusInstaller/99_MyUtils.pm/download -O /opt/fhem/install/99_MyUtils.pm
  echo 99_MyUtils.pm downloaded
  echo 99_MyUtils.pm downloaded >>$Log 

  sudo wget http://sourceforge.net/projects/ebus-installer/files/eBusInstaller/99_MyUtils_Header.pm/download -O /opt/fhem/install/99_MyUtils_Header.pm
  echo 99_MyUtils_Header.pm downloaded
  echo 99_MyUtils_Header.pm downloaded >>$Log 

     
  # check if existing
  for Name in  ZProg ZeitfensterSchreiben
         do
         echo search and replace.. $Name
         echo search and replace.. $Name >>$Log
         sed -e 's/define '"$Name"'/# define '"$Name"'/g' -i /opt/fhem/fhem-installer.cfg 
         sed -e 's/attr '"$Name"'/# attr '"$Name"'/g' -i /opt/fhem/fhem-installer.cfg 
         sed -e 's/set '"$Name"'/# set '"$Name"'/g' -i /opt/fhem/fhem-installer.cfg  
  done 
 
  if [ -e "/opt/fhem/install/timer.cfg" ]; then 
     sudo cat /opt/fhem/install/timer.cfg >> /opt/fhem/fhem-installer.cfg
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
  cat /opt/fhem/install/bai02.cfg >> /opt/fhem/FHEM/bai01.cfg
  
  # check if existing 99_MyUtils.pm
  if [ ! -e "/opt/fhem/FHEM/99_MyUtils.pm" ]; then 
     # install Header for 99_MyUtils.pm, non exist
     if [ -e "/opt/fhem/install/99_MyUtils_Header.pm" ]; then
        cat /opt/fhem/install/99_MyUtils_Header.pm >> /opt/fhem/FHEM/99_MyUtils.pm
        echo install 99_MyUtils_Header.pm
        echo install 99_MyUtils_Header.pm >>$Log
     fi   
  fi
  
  # install Vaillant Definition in 99_MyUtils.pm 
  if [ -e "/opt/fhem/install/99_MyUtils.pm" ]; then
     cat /opt/fhem/install/99_MyUtils.pm >> /opt/fhem/FHEM/99_MyUtils.pm
     echo install 99_MyUtils.pm
     echo install 99_MyUtils.pm >>$Log
     sudo chmod 666 /opt/fhem/FHEM/99_MyUtils.pm 
  fi   
 
  if [ "$Duplicate" = "False" ]; then
     cp /opt/fhem/fhem-installer.cfg /opt/fhem/$Filename 
     echo fhem.cfg is modified
     echo fhem.cfg is modified >>$Log
  fi 
  
  # cleaning installpath  
   if [ "$Cleaning" = "True" ]; then
     sudo rm /opt/fhem/install/*
   fi  

   if [ "$1" = "470" ]; then
     sed -e 's/write -c 430/write -c 470/g' -i /opt/fhem/FHEM/bai01.cfg 
     echo VRC470 is modified
     echo VRC470 is modified >>$Log  
   fi
} 

#_________________________________________________________ 
do_install_ebusd(){
  echo installation eBuscfg is startet
  echo installation eBuscfg is startet >>$Log
  sudo wget https://github.com/john30/ebusd/releases/download/v2.0/ebusd-2.0_armhf.deb
  echo download eBusd finished
  echo download eBusd is finished >>$Log
  sudo sudo dpkg -i --force-overwrite ebusd-2.0_armhf.deb
  echo install eBusd finished
  echo install eBusd is finished >>$Log
  do_install_ebuscfg
}

#_________________________________________________________
do_install_ebuscfg(){
  echo installation eBuscfg is startet
  echo installation eBuscfg is startet >>$Log
  sudo wget https://github.com/john30/ebusd-configuration/releases/download/v2.0.1/ebusd-configuration-2.0.5aa482c-de_all.deb
  echo download eBuscfg finished
  echo download eBuscfg is finished >>$Log
  sudo sudo dpkg -i --force-overwrite ebusd-configuration-2.0.*.deb
  echo install eBuscfg finished
  echo install eBuscfg is finished >>$Log
  do_reload_cfg    
}
#_________________________________________________________ 
do_reload_cfg(){
  # reload broadcast, logrotate and default for a correct configurtion
  if [ $Modify_cfg = True ]; then
    sudo wget http://sourceforge.net/projects/ebus-installer/files/eBusInstaller/broadcast.csv/download -O /opt/fhem/install/broadcast.csv
    echo download broadcast finished
    echo download broadcast is finished >>$Log
    sudo wget http://sourceforge.net/projects/ebus-installer/files/eBusInstaller/_templates.csv/download -O /opt/fhem/install/_templates.csv
    echo download _template.csv finished
    echo download _template.csv is finished >>$Log
    sudo wget http://sourceforge.net/projects/ebus-installer/files/eBusInstaller/ebusd.logrotate/download -O /opt/fhem/install/ebusd.logrotate
    echo download logrotate finished
    echo download logrotate is finished >>$Log
    sudo wget http://sourceforge.net/projects/ebus-installer/files/eBusInstaller/ebusd.default/download -O /opt/fhem/install/ebusd.default
    echo download default config finished
    echo download default config is finished >>$Log

    # check broadcast
    if [ -e "/opt/fhem/install/broadcast.csv" ]; then
      if [ -e "/etc/ebusd/vaillant/broadcast.csv" ]; then
        sudo cp -pa /opt/fhem/install/broadcast.csv /etc/ebusd/vaillant/broadcast.csv
      else
        echo broadcast.csv is misssing, please check the congfigs in /etc/ebusd/
        echo broadcast.csv is misssing, please check the congfigs in /etc/ebusd/ >>$Log 
      fi
    fi

    # check template
    if [ -e "/opt/fhem/install/_templates.csv" ]; then
      if [ -e "/etc/ebusd/vaillant/_templates.csv" ]; then
        sudo cp -pa /opt/fhem/install/_templates.csv /etc/ebusd/vaillant/_templates.csv
      else
        echo _template.csv is misssing, please check the congfigs in /etc/ebusd/
        echo _template.csv is misssing, please check the congfigs in /etc/ebusd/ >>$Log 
      fi
    fi
    
    # check logrotate
    if [ -e "/opt/fhem/install/ebusd.logrotate" ]; then
      sudo cp -pa /opt/fhem/install/ebusd.logrotate /etc/logrotate.d/ebusd
    fi

    if [ -e "/opt/fhem/install/ebusd.default" ]; then
      sudo cp -pa /opt/fhem/install/ebusd.default /etc/default/ebusd
    fi

    # check 470 for write
    if [ -e "/etc/ebusd/vaillant/15.470.csv" ]; then
      sed -e 's/r;wi,,Hc1HeatCurve/r;w,,Hc1HeatCurve/g' -i /etc/ebusd/vaillant/15.470.csv
      echo Hc1HeatCurve 470 is mofified
      echo Hc1HeatCurve 470 is mofified >>$Log
    fi
  fi
  
  # cleaning installpath  
   if [ "$Cleaning" = "True" ]; then
     sudo rm /opt/fhem/install/*
   fi  

  sudo service ebusd restart
} 
#_________________________________________________________ 
do_install_ftui(){
   # save existing fhem.cfg 
   cp /opt/fhem/fhem.cfg /opt/fhem/fhem-installer.cfg
   if [ ! -e $BackupDir/$Filedate ]; then
      sudo mkdir -p $BackupDir/$Filedate/
      sudo chmod 777 $BackupDir/$Filedate 
   fi
   cp /opt/fhem/fhem.cfg $BackupDir/$Filedate/fhem.cfg

   # check existing entry and blocking
   sed -e 's/define tablet_ui/# define tablet_ui/g' -i /opt/fhem/fhem-installer.cfg 

   # reload broadcast, logrotate and default for a correct configurtion
   sudo wget http://sourceforge.net/projects/ebus-installer/files/eBusInstaller/ftui.tar.gz/download -O /opt/fhem/install/ftui.tar.gz
   echo ftui installed
   echo ftui installed >>$Log
  
   if [ ! -e /opt/fhem/www/tablet]; then
      sudo mkdir -p $BackupDir/$Filedate/
      sudo chmod 777 $BackupDir/$Filedate
      sudo cp -r /opt/fhem/www/tablet $BackupDir/$Filedate/tablet 
      echo backup ftui is completed
      echo backup ftui is completed >>$Log
   fi

   cd /opt/fhem/install; sudo tar -xzf ftui.tar.gz -C /
   # make menu entry
   echo define tablet_ui HTTPSRV ftui/ ./www/tablet Tablet-UI >>/opt/fhem/fhem-installer.cfg
   echo ftui menu is activated
   echo ftui menu is activated >>$Log
  
   if [ "$Duplicate" = "False" ]; then
     cp /opt/fhem/fhem-installer.cfg /opt/fhem/fhem.cfg 
   fi  

   # cleaning installpath  
   if [ "$Cleaning" = "True" ]; then
     sudo rm /opt/fhem/install/*
   fi   
}  
#_________________________________________________________ 
do_install_fhem(){  
   # save existing fhem.cfg 
   if [ -e /opt/fhem/fhem.cfg]; then
     if [ ! -e $BackupDir/$Filedate ]; then
       sudo mkdir -p $BackupDir/$Filedate/
       sudo chmod 777 $BackupDir/$Filedate 
       echo Backupdir created
       echo Backupdir created >>$Log
     fi
     cp /opt/fhem/fhem.cfg $BackupDir/$Filedate/fhem.cfg     
   fi

   if [ -e /etc/rc.local]; then
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

   sudo wget http://sourceforge.net/projects/ebus-installer/files/eBusInstaller/fhem.cfg/download -O /opt/fhem/install/fhem.cfg
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
FUN=$(whiptail --title "eBus Install and Configuration Tool $(hostname) V0.4 Beta" --menu "Setup Options" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Finish --ok-button Select \
"1  EBUSD 2.x Package" "Daemon,Start/Stop,Log,Default" \
"2  EBUSD Config 2.x Package" "CSV alle,Log,Logrotate,broadcast,templates" \
"3  ECMD Basis Package" "ECMD Devices,Classdef,Zyklus,bai00.cfg" \
"4  ECMD Heizkurve 430" "FHEM Config, bai01.cfg" \
"5  ECMD Heizkurve 470" "FHEM Config, bai01.cfg" \
"6  ECMD Valves Waermebedarfst." "39_Valves.pm, FHEM Config" \
"7  ECMD Zeitprogramme 430" "FHEM Config, bai01.cfg" \
"8  ECMD Zeitprogramme 470" "FHEM Config, bai01.cfg" \
"9 GAEBUS" "98_GAEBUS.pm, FHEM Config" \
"10 Tablet-UI" "Install UI HTML Demo Modul" \
3>&1 1>&2 2>&3)
RET=$?
if [ $RET -eq 1 ]; then
	do_finish
elif [ $RET -eq 0 ]; then
	case "$FUN" in
		1\ *) do_install_ebusd ;;
		2\ *) do_install_ebuscfg ;;
		3\ *) do_install_ecmdbasis ;;
		4\ *) do_install_hcurve430 ;;
		5\ *) do_install_hcurve470 ;;
		6\ *) do_install_valves ;;
		7\ *) do_install_timer 430 ;;
		8\ *) do_install_timer 470 ;;
		9\ *) do_install_gaebus ;;
		10\ *) do_install_ftui ;;
		11\ *) do_install_fhem ;;
		*) whiptail --msgbox "Programmer error: unrecognized option" 20 60 1 ;;
	esac || whiptail --msgbox "There was an error running option $FUN" 20 60 1
	else
		exit 1
fi
done
