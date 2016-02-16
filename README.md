eBus Installer
--------------
![](http://up.picr.de/24608250im.png)

Features
--------

The main features of the installer are:

 * FHEM Installation => Install FHEM Server
 * eBusd Installation => Daemon,Start/Stop,Log,Default
 * eBusd Config Package => "CSV alle,Log,Logrotate,broadcast,templates
 * ECMD Basis Package => ECMD Devices,Classdef,Zyklus,bai00.cfg
 * ECMD Heizkurve => FHEM Config, bai01.cfg
 * ECMD Valves Waermebedarfst => "39_Valves.pm, FHEM Config
 * ECMD Zeitprogramme => FHEM Config, bai01.cfg
 * GAEBUS => 98_GAEBUS.pm, FHEM Config
 * Tablet-UI => Install UI HTML Demo Modul
 * Markierungen loeschen => loeschen von doppelten Installationen
 
Installation
------------
```sh
sudo wget https://raw.githubusercontent.com/arthur0412/fhem/master/ebus/ebus_install_fhem.sh -O ebus_install_fhem.sh
sudo chmod 775 ebus_install_fhem.sh
sudo ./ebus_install_fhem.sh
```


Contact
-------
For bugs and missing features use github issue system.

Usage instructions and further information can be found here:
> http://forum.fhem.de/index.php/topic,46098.msg405704.html#msg405704

> http://www.fhemwiki.de/wiki/EBUS
