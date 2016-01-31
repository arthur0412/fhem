<map version="1.0.1">
<!-- To view this file, download free mind mapping software FreeMind from http://freemind.sourceforge.net -->
<node CREATED="1453156530303" ID="ID_1892071152" MODIFIED="1453240046341">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      EBUS WIKI
    </p>
    <p>
      Version 0.2
    </p>
  </body>
</html>
</richcontent>
<node CREATED="1453207008050" ID="ID_289336327" MODIFIED="1453234839598" POSITION="right" TEXT="Einleitung">
<node CREATED="1453207021410" ID="ID_1448119700" MODIFIED="1453234839598" TEXT="Kurze Beschreibung (Bisherige Text)"/>
<node CREATED="1453207041807" ID="ID_414214898" MODIFIED="1453234839598" TEXT="Inhaltsverzeichnis"/>
</node>
<node CREATED="1453156555089" ID="ID_1664853715" MODIFIED="1453234839598" POSITION="right" TEXT="1 Interface">
<node CREATED="1453225648526" ID="ID_66993160" MODIFIED="1453234839598" TEXT="1.1 Schaltung"/>
<node CREATED="1453156562446" ID="ID_958093299" MODIFIED="1453234839598" TEXT="1.1 Eigenbau (Lochrasterplatine)"/>
<node CREATED="1453157211746" ID="ID_1225973968" MODIFIED="1453235295609" TEXT="1.2 Platine">
<node CREATED="1453157397559" ID="ID_274650727" MODIFIED="1453234839598" TEXT="Inhalt:http://forum.fhem.de/index.php/topic,46098.msg378796.html#msg378796">
<node CREATED="1453207088057" ID="ID_490628578" MODIFIED="1453234839598" TEXT="EBUSD Adapter zentis666"/>
</node>
<node CREATED="1453158505049" ID="ID_1729992382" MODIFIED="1453234839598" TEXT="Zusammenbau">
<node CREATED="1453158521078" ID="ID_1134221353" MODIFIED="1453234839598" TEXT="Tipps">
<node CREATED="1453158526027" ID="ID_1877394206" MODIFIED="1453234839598" TEXT="Wiederst&#xe4;nde messen"/>
</node>
</node>
<node CREATED="1453225287770" ID="ID_694261618" MODIFIED="1453234839598" TEXT="Platine best&#xfc;cken"/>
<node CREATED="1453225322678" ID="ID_676424519" MODIFIED="1453234839598" TEXT="Platine Messpunkte"/>
<node CREATED="1453225336509" ID="ID_294451359" MODIFIED="1453234839598" TEXT="Poti abgleichen">
<node CREATED="1453158820998" FOLDED="true" ID="ID_193948651" MODIFIED="1453234898217" TEXT="Per eBusd (einfach)">
<node CREATED="1453158838863" ID="ID_1651043906" MODIFIED="1453234839598" TEXT="http://forum.fhem.de/index.php/topic,46098.msg379253.html#msg379253"/>
</node>
<node CREATED="1453225385280" ID="ID_170911967" MODIFIED="1453234887829" TEXT="Per Messung">
<node CREATED="1453225414173" ID="ID_1682883350" MODIFIED="1453234839598" STYLE="fork" TEXT="Nach Reinharts Beschreibung">
<node CREATED="1453225466348" ID="ID_257526928" MODIFIED="1453234839598" TEXT="Multimeter"/>
</node>
</node>
</node>
<node CREATED="1453157502713" FOLDED="true" ID="ID_56150455" MODIFIED="1453236761654" TEXT="Bekannte Fehler:">
<node CREATED="1453157522096" ID="ID_878624140" MODIFIED="1453157523705" TEXT="Inhalt:http://forum.fhem.de/index.php/topic,46098.msg378796.html#msg378796"/>
</node>
</node>
<node CREATED="1453156568390" ID="ID_1764260596" MODIFIED="1453235300208" TEXT="1.3 Kommerzielles Interface"/>
</node>
<node CREATED="1453156575377" ID="ID_1066500325" MODIFIED="1453234839598" POSITION="right" TEXT="2 Software">
<node CREATED="1453157693777" ID="ID_1797108149" MODIFIED="1453234839598" TEXT="Einleitung">
<node CREATED="1453157710045" ID="ID_1795135931" MODIFIED="1453234839598" TEXT="Als Software kommt auf dem Raspberry Pi der ebusd = EBUS-D&#xe4;mon zum Einsatz (aktuell im Januar 2016 die Version 2.0). usw."/>
</node>
<node CREATED="1453157760392" ID="ID_536377058" MODIFIED="1453235001315" TEXT="2.1 Ebusd Installation (Packages)">
<node CREATED="1453158281637" ID="ID_1513165189" MODIFIED="1453234839598" TEXT="2.1.1 Voraussetzungen"/>
<node CREATED="1453158138997" ID="ID_413782762" MODIFIED="1453234839598" TEXT="2.1.2 eBusd">
<node CREATED="1453157866957" ID="ID_58406254" MODIFIED="1453234839598" TEXT="https://github.com/john30/ebusd/releases"/>
</node>
<node CREATED="1453158150923" ID="ID_1482570391" MODIFIED="1453234839598" TEXT="2.1.2 Konfigurationsdateien (CSV-Files)">
<node CREATED="1453235218023" ID="ID_1408446986" MODIFIED="1453235219929" TEXT="https://github.com/john30/ebusd-configuration/releases"/>
</node>
</node>
<node CREATED="1453157763235" ID="ID_1573956233" MODIFIED="1453234839598" TEXT="2.2 Ebusd Installation (Build Prozess)">
<node CREATED="1453158281637" FOLDED="true" ID="ID_32718897" MODIFIED="1453235079174" TEXT="2.2.1 Voraussetzungen">
<node CREATED="1453158293626" ID="ID_1534016456" MODIFIED="1453158294954" TEXT="apt-get install git autoconf automake g++ make"/>
</node>
<node CREATED="1453158106667" ID="ID_1921728433" MODIFIED="1453235087325" TEXT="2.2.2 eBusd"/>
<node CREATED="1453158113654" FOLDED="true" ID="ID_1558991454" MODIFIED="1453235095627" TEXT="2.2.3 Konfigurationsdateien (CSV-Files)">
<richcontent TYPE="NOTE"><html>
  <head>
    
  </head>
  <body>
    <div class="post">
      <div class="inner" id="msg_379534">
        <div class="quoteheader">
          
        </div>
        <pre style="margin-top: 0; margin-right: 0; margin-bottom: 0; margin-left: 0; padding-top: 0; padding-right: 0; padding-bottom: 0; padding-left: 0"><code class="bbc_code">svn export --force https://github.com/john30/ebusd-configuration/trunk/ebusd-2.x.x/de /etc/ebusd</code></pre>
      </div>
    </div>
  </body>
</html>
</richcontent>
<node CREATED="1453159653900" ID="ID_942838674" MODIFIED="1453234839598" TEXT="http://forum.fhem.de/index.php/topic,46098.msg379544.html#msg379544"/>
</node>
<node CREATED="1453235114252" ID="ID_865839105" MODIFIED="1453235133083" TEXT="2.2.4 Dienstkonfiguraiton"/>
<node CREATED="1453158569738" FOLDED="true" ID="ID_1476027985" MODIFIED="1453235168324" TEXT="2.2.5 Logdatei (Logrotate)">
<node CREATED="1453158611164" ID="ID_1707486713" MODIFIED="1453158618088" TEXT="/var/log/ebusd.log { &#x9;rotate 7 &#x9;copytruncate &#x9;compress &#x9;missingok &#x9;notifempty &#x9;daily }"/>
<node CREATED="1453158638291" ID="ID_510484793" MODIFIED="1453158648403" TEXT="Beschreibung:">
<node CREATED="1453158651037" ID="ID_855057680" MODIFIED="1453158652646" TEXT="alle 7 Tage wird &#xfc;berschrieben, die Files werden dann komprimiert (au&#xdf;er dem aktuellen File) und das Ganze wird t&#xe4;glich ausgef&#xfc;hrt. "/>
</node>
</node>
</node>
<node CREATED="1453207426949" ID="ID_963839616" MODIFIED="1453235427740" TEXT="2.3 Einbindung in FHEM mittels ECMD">
<node CREATED="1453236017031" ID="ID_1070338234" MODIFIED="1453236377022" TEXT="2.3.1 Definition in FHEM">
<node CREATED="1453209941915" ID="ID_444574947" MODIFIED="1453234839598" TEXT="http://forum.fhem.de/index.php/topic,46098.msg381563.html#msg381563"/>
</node>
<node CREATED="1453236232730" ID="ID_1197733960" MODIFIED="1453236273143" TEXT="2.3.2 Definition der ECMD Devices"/>
<node CREATED="1453156609456" ID="ID_430448579" MODIFIED="1453236282883" TEXT="2.3.3 Definition Heizkreis"/>
<node CREATED="1453156615640" ID="ID_1516651339" MODIFIED="1453236288529" TEXT="2.2.4 Definition Warmwasserkreis"/>
<node CREATED="1453156621516" ID="ID_977459886" MODIFIED="1453236292926" TEXT="2.2.5 Definition Solarkreis"/>
</node>
<node CREATED="1453207453297" ID="ID_451211643" MODIFIED="1453235437519" TEXT="2.4 Einbindung in FHEM mittels GAEBUS">
<node CREATED="1453210059790" ID="ID_1029887233" MODIFIED="1453234839598" TEXT="http://forum.fhem.de/index.php/topic,46098.msg381580.html#msg381580"/>
<node CREATED="1453236333660" ID="ID_924278445" MODIFIED="1453236483196" TEXT="2.4.1 Definition in FHEM"/>
<node CREATED="1453236438705" ID="ID_1485628851" MODIFIED="1453236490267" TEXT="2.4.2 Einrichtung"/>
</node>
</node>
<node CREATED="1453156628658" ID="ID_1768741485" MODIFIED="1453234839598" POSITION="right" TEXT="3 System&#xfc;berwachung">
<node CREATED="1453156635252" ID="ID_617025096" MODIFIED="1453235646679" TEXT="3.1 Mithilfe von FHEM">
<node CREATED="1453239357156" ID="ID_388945461" MODIFIED="1453239391720" TEXT="Bisherige Wiki Beitrag +"/>
<node CREATED="1453209988620" ID="ID_887374222" MODIFIED="1453234839598" TEXT="siehe auch hier: http://forum.fhem.de/index.php/topic,46098.msg381563.html#msg381563"/>
</node>
<node CREATED="1453156643750" ID="ID_113426417" MODIFIED="1453235673957" TEXT="3.2 Mithilfe von Watchdog">
<node CREATED="1453239396962" ID="ID_1365017163" MODIFIED="1453239402105" TEXT="Bisherige Wiki Beitrag +"/>
<node CREATED="1453209988620" ID="ID_1352841180" MODIFIED="1453234839598" TEXT="siehe auch hier: http://forum.fhem.de/index.php/topic,46098.msg381563.html#msg381563"/>
</node>
</node>
<node CREATED="1453234342365" ID="ID_1395660395" MODIFIED="1453234839598" POSITION="right" TEXT="4 Beispiele">
<node CREATED="1453209266993" ID="ID_1259409243" MODIFIED="1453235719527" TEXT="4.1 Heizkurve">
<node CREATED="1453210024345" ID="ID_1648431688" MODIFIED="1453234839598" TEXT="http://forum.fhem.de/index.php/topic,46098.msg381563.html#msg381563"/>
</node>
<node CREATED="1453209259917" ID="ID_333088097" MODIFIED="1453235733044" TEXT="4.2 Wochenprogramme">
<node CREATED="1453237500622" ID="ID_790846871" MODIFIED="1453237502138" TEXT="http://forum.fhem.de/index.php/topic,46098.msg383269.html#msg383269"/>
</node>
<node CREATED="1453158212983" ID="ID_1097269053" MODIFIED="1453235766048" TEXT="4.3 Visualisierung und Steuerung mittels FTUI"/>
</node>
<node CREATED="1453235907990" ID="ID_1428659424" MODIFIED="1453236597089" POSITION="right" TEXT="5 Tipps &amp; Tricks [optional]">
<node CREATED="1453236676613" ID="ID_1586865331" MODIFIED="1453236697039" TEXT="TBD"/>
<node CREATED="1453236910441" ID="ID_1757447052" MODIFIED="1453236980984" TEXT="USB Device unter Linux ermitteln "/>
<node CREATED="1453236947257" ID="ID_1261532668" MODIFIED="1453236953195" TEXT="EBUSD Checkconfig">
<node CREATED="1453237548269" ID="ID_1951536069" MODIFIED="1453237549394" TEXT="ebusd --checkconfig --scanconfig"/>
</node>
<node CREATED="1453236956259" ID="ID_1121354986" MODIFIED="1453237239408" TEXT="Bedeutung von &quot;unknow MS&quot; in eBusd Logdatei"/>
<node CREATED="1453237244589" ID="ID_333094061" MODIFIED="1453237267556" TEXT="Bedeutung von &quot;lost signal&quot;"/>
<node CREATED="1453237346496" ID="ID_1540893672" MODIFIED="1453237348527" TEXT="ERR: duplicate entry">
<node CREATED="1453237370833" ID="ID_510900885" MODIFIED="1453237373474" TEXT="http://forum.fhem.de/index.php/topic,46098.msg383041.html#msg383041"/>
</node>
<node CREATED="1453156591684" ID="ID_109672352" MODIFIED="1453234839598" TEXT="2.1.1 Vorgehensweise bei einem neuen Heizungssystem"/>
<node CREATED="1453237587844" ID="ID_505629146" MODIFIED="1453237589347" TEXT="ERR: end of input reached Erroneous item is here:">
<node CREATED="1453237606664" ID="ID_533037932" MODIFIED="1453237607852" TEXT="http://forum.fhem.de/index.php/topic,46098.msg383450.html#msg383450"/>
<node CREATED="1453237617856" ID="ID_1845316455" MODIFIED="1453237618356" TEXT="http://forum.fhem.de/index.php/topic,46098.msg383510.html#msg383510"/>
</node>
<node CREATED="1453237966903" ID="ID_1721942972" MODIFIED="1453237968762" TEXT="[bus error] send to 15: ERR: read timeout, retry"/>
</node>
<node CREATED="1453236573504" ID="ID_1341137537" MODIFIED="1453236592713" POSITION="right" TEXT="6 Weiterf&#xfc;hrende Links">
<node CREATED="1453236603154" ID="ID_574012028" MODIFIED="1453236611222" TEXT="eBus Schaltung in Betrieb nehmen!"/>
<node CREATED="1453236617845" ID="ID_1572974986" MODIFIED="1453236618533" TEXT="L&#xe4;uft: Heizung mit eBus-Schnittstelle"/>
<node CREATED="1453236626213" ID="ID_431142148" MODIFIED="1453236647733" TEXT="Forum GAEBUS Modul"/>
</node>
</node>
</map>
