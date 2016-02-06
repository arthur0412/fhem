# $Id: 39_VALVES.pm 1015 2014-10-22 04:35:00Z Florian Duesterwald $
####################################################################################################
#
#	39_VALVES.pm
#
#	heating valves average, with some adjust and ignore options
#	http://forum.fhem.de/index.php/topic,24658.0.html
#	refer to mail a.T. duesterwald do T info if necessary
#
#	thanks to cwagner for testing and a great documentation of the module:
#	http://www.fhemwiki.de/wiki/Raumbedarfsabh%C3%A4ngige_Heizungssteuerung
#	http://www.fhemwiki.de/wiki/VALVES
#
#	This file is free contribution and not part of fhem.
#
#	Fhem is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 2 of the License, or
#	(at your option) any later version.
#
#	Fhem is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with fhem.  If not, see <http://www.gnu.org/licenses/>.
#
####################################################################################################
package main;
use strict;
use warnings;

#test values:
#Heizg_Bad,Heizg_Buero,Heizg_Flur,Heizg_Kammer,Heizg_Kueche,Heizg_Lena,Heizg_Lisa,Heizg_Schlafzimmer,Heizg_WC_oben,Heizg_WC_unten,Heizg_Wohnzimmer1,Heizg_Wohnzimmer2
#}

sub VALVES_Initialize($){
	my ($hash) = @_;
	$hash->{DefFn}		= "VALVES_Define";
	$hash->{UndefFn}	= "VALVES_Undefine";
	$hash->{SetFn}		= "VALVES_Set";
	$hash->{GetFn}		= "VALVES_Get";
	$hash->{NotifyFn}	= "VALVES_Notify";
	$hash->{AttrFn}		= "VALVES_Attr";
	my($attrList)=" valvesPollInterval:1,2,3,4,5,6,7,8,9,10,11,15,20,25,30,45,60,90,120,240,480,900".
		" valvesDeviceList valvesDeviceReading valvesIgnoreLowest valvesIgnoreHighest valvesIgnoreDeviceList".
		" valvesPriorityDeviceList valvesInitialDelay";
	my($i)=0;
	$hash->{AttrList}	= "disable:0,1 ".$readingFnAttributes.$attrList;
	}
sub VALVES_Define($$){
	my ($hash, $def) = @_;
	my @args = split("[ \t][ \t]*", $def);
	return "Wrong syntax: use define <name> VALVES" if(int(@args) != 2);
	my $name = $args[0];
	Log3($name, 4, "VALVES $name has been defined");
	readingsSingleUpdate($hash, "state", "initialized",1);
	#first run after 61 seconds, wait for other devices
	readingsSingleUpdate($hash, "busy", 0+gettimeofday(),1); #waiting for attr check
	InternalTimer(gettimeofday() + 61, "VALVES_GetUpdate", $hash, 0);
	return undef;
	}
sub VALVES_Undefine($$){
  my($hash, $name) = @_;
  RemoveInternalTimer($hash);
  return;
}
sub VALVES_Get($@){
	my ($hash, @a) = @_;
	my $name = $hash->{NAME};
	my $get = $a[1];
	my @stmgets = (keys(%{$hash->{READINGS}}));
	$get="?" if(!_in_array($get,(@stmgets,"attrHelp","state","html")));
	my $usage = "Unknown argument $get, choose one of";
	foreach(@stmgets){
		$usage.=" ".$_.":noArg";
		}
	$usage.=" attrHelp:";
	my($first)=0;
	foreach(_valvesAttribs("keys","")){
		if($first){
			$usage.=$_;
			$first=0;
		}else{
			$usage.=",".$_;
			}
		}
	return $usage if $get eq "?";
	if($get eq "attrHelp"){return _valvesAttribs("help",$a[2]);}
	my $ret = $get.": ".ReadingsVal($name,$get, "Unknown at line ".__LINE__);
	return $ret;
	}
sub VALVES_Set($@){
	my ($hash, @a) = @_;
	my $name = shift @a;
	return "no set value specified" if(int(@a) < 1);
	my $setList = "reset:noArg ";
	if($a[0] eq "?"){
		return "Unknown argument ?, choose one of $setList";
	}elsif($a[0] eq "reset"){
		Log3($name,4,"VALVES set $name ".join(" ", @a));
		foreach(keys(%{$hash->{READINGS}})){
			CommandDeleteReading(undef,"$name $_");
			}
		return undef;
#	}elsif($a[0] eq "setAttr"){
#		Log3($name,4,"VALVES set $name ".join(" ", @a));
#		CommandAttr(undef,"$name ".join(" ",@a));
#		return undef;
		}
	}
sub VALVES_Attr($@){
	my ($cmd, $name, $attrName, $attrVal) = @_;
	my $hash = $defs{$name};
	#special attr valvesDeviceList #valvesDeviceList: addToAttrList
	if ($attrName eq "valvesDeviceList") {
		if(length($attrVal)>2){
			Log3($name, 4, "VALVES $name attribute-value [$attrName] = $attrVal changed");
			foreach(split(/,/,$attrVal)){
				addToAttrList("valves".$_."Gewichtung");
				}
			VALVES_GetUpdate($hash);
		} else {
			Log3($name, 3, "VALVES $name attribute-value [$attrName] = $attrVal wrong, string min length 2");
			}
	#validate special attr valvesPollInterval
	}elsif ($attrName eq "valvesPollInterval") {
		if(($attrVal>=1) and ($attrVal<=900)){
			Log3($name, 4, "VALVES $name attribute-value [$attrName] = $attrVal changed");
			VALVES_GetUpdate($hash);
		} else {
			Log3($name, 3, "VALVES $name attribute-value [$attrName] = $attrVal wrong, use seconds >1 as float (max 900)");
			}
	#other attribs
	}elsif($attrName =~/^valves\d+/){
		if(!defined $attrVal){
			if(defined $attrVal){
				Log3($name, 4, "VALVES $name: attribute-value [$attrName] = $attrVal changed");
			}else{
				CommandDeleteAttr(undef, "$name attrName");
				Log3($name, 4, "VALVES $name: attribute [$attrName] deleted");
				}
			}
	}else{
		Log3($name, 4, "VALVES $name: attribute-value [$attrName] = $attrVal changed");
		}
	return;
	}
sub VALVES_Notify(@){
	my ($hash, $dev) = @_;
	my $name = $hash->{NAME}; 
	if ($dev->{NAME} eq "global" && grep (m/^INITIALIZED$/,@{$dev->{CHANGED}})){
		Log3($name, 3, "VALVES $name initialized");
		VALVES_GetUpdate($hash);    
		}
	return;
	}
sub VALVES_GetUpdate($) {
	my($hash)= @_;
	my($name)=$hash->{NAME};
	my($valvesPollInterval)=AttrVal($name, "valvesPollInterval", 10);
	if ($valvesPollInterval ne "off") {
		RemoveInternalTimer($hash);
		InternalTimer(gettimeofday() + ($valvesPollInterval), "VALVES_GetUpdate", $hash, 0);
		}
	if (IsDisabled($name)) {
		return;
		}
	if(AttrVal($name,"valvesDeviceList","none") eq "none"){
		readingsSingleUpdate($hash, "state", "missing attr valvesDeviceList", 1);
		return;
		}
	#check all attr at first loop
	if(ReadingsVal($name,"busy","done") ne "done"){		#"waiting for attr check"
		if((gettimeofday()-AttrVal($name,"valvesInitialDelay",61))>ReadingsVal($name, "busy",0)){
			foreach(split(/,/,AttrVal($name,"valvesDeviceList",""))){
				addToAttrList("valves".$_."Gewichtung");
				}
			CommandDeleteReading(undef,"$name busy")
			}
		}
	my(%valveDetail,%valveShort,@raw_average,$dev,$pos,$prio);
	my($valvesIgnoreDeviceList)=AttrVal($name,"valvesIgnoreDeviceList","0");
	foreach(split(/,/,AttrVal($name,"valvesDeviceList",""))){
		$dev=$_;
		#check ignorelist
		if($valvesIgnoreDeviceList=~/$dev/){
			next;
			}
		#get val
		$pos=ReadingsNum($dev,AttrVal($name,"valvesDeviceReading","valveposition"),"err");
		if(!defined($pos) or ($pos eq "err")){
			Log3($name, 4, "VALVES $name ".$_." [$pos] DeviceReading not present");
			next;
			}
		push(@raw_average,$pos);
		#calc prio
		$prio=1;
		if(AttrVal($name,"valves".$dev."Gewichtung","err") ne "err"){
			$prio=AttrVal($name,"valves".$dev."Gewichtung","err");
			}
		#fill hash
		$valveDetail{$dev}=[($pos,ReadingsTimestamp($dev,AttrVal($name,"valvesDeviceReading","valveposition"),undef))];
		$valveShort{$dev}=$pos*$prio;
		}
	#ignore highest/lowest N values
	my(@sorted)=sort { $valveShort{$a} <=> $valveShort{$b} } keys %valveShort;
	if($#sorted==-1){
		readingsSingleUpdate($hash, "state", "attr valvesDeviceList is empty", 1);
		return;
		}
	my($valvesIgnoreLowest)=AttrVal($name,"valvesIgnoreLowest",0);
	while($valvesIgnoreLowest>0){
		shift(@sorted);
		$valvesIgnoreLowest--;
		}
	my($valvesIgnoreHighest)=AttrVal($name,"valvesIgnoreHighest",0);
	while($valvesIgnoreHighest>0){
		pop(@sorted);
		$valvesIgnoreHighest--;
		}
	#fill readings, bypass usual way to conserve valveposition timestamps
	foreach(@sorted){
		setReadingsVal($hash,"valve_".$_,$valveShort{$_},$valveDetail{$_}[1]);
		}
	#set min and max from sorted
	if(ReadingsVal($name,"valve_min","err") ne $valveShort{$sorted[0]}){
		readingsSingleUpdate($hash, "valve_min", $valveShort{$sorted[0]}, 1);
		}
	@sorted=reverse(@sorted);
	if(ReadingsVal($name,"valve_max","err") ne $valveShort{$sorted[0]}){
		readingsSingleUpdate($hash, "valve_max", $valveShort{$sorted[0]}, 1);
		}
	my($valvesPriorityDeviceList)=AttrVal($name,"valvesPriorityDeviceList","0");
	readingsBeginUpdate($hash);
	foreach(keys(%valveDetail)){
		$dev=$_;
		if(!exists($valveShort{$dev})){
			$valveShort{$dev}="ignored";
			}
		#create double hash entry for prio dev
		if($valvesPriorityDeviceList=~/$dev/){
			$valveShort{$dev."P"}=$valveShort{$dev};
			push(@sorted,$dev."P");
			}
		readingsBulkUpdate($hash,"valveDetail_".$dev,"pos:".$valveDetail{$dev}[0]." calc:".$valveShort{$dev}.
			(($valvesPriorityDeviceList=~/$dev/)?"-priority":"").
			" time:".$valveDetail{$dev}[1]);		
		}
	readingsEndUpdate($hash, 0);
	my($state);
	foreach(@sorted){
		$state+=$valveShort{$_};
		}
	$state=($state/($#sorted+1));
	if(ReadingsVal($name,"state","err") ne $state){
		readingsSingleUpdate($hash, "valve_average", $state, 1);
		readingsSingleUpdate($hash, "state", $state, 1);
		}
	$state=0;
	foreach(@raw_average){
		$state+=$_;
		}
	$state=($state/($#raw_average+1));
	if(ReadingsVal($name,"raw_average","err") ne $state){
		readingsSingleUpdate($hash, "raw_average", $state, 1);
		}
	}

sub _in_array($@){
	my ($search_for,@arr) = @_;
	foreach(@arr){
		return 1 if $_ eq $search_for;
		}
	return 0;
	}
sub _valvesAttribs($@){
	#usage: _valvesAttribs("type","stmVarName")
	# "keys" || "default" || "type" || "help"  ,<keyname>
	my($type,$reqKey)=@_;
	my %attribs = (
"valvesInitialDelay"=>[("61","int","Zeitintervall nach FHEM-Start oder Dev.-Define bevor die Berechnung gestartet wird")],
"valvesPollInterval"=>[("10","int","Zeitintervall nach dem FHEM die daten versucht zu aktualisieren")],
"valvesDeviceList"=>[("none","string","Liste aller Heizungsthermostate mit Komma getrennt ohne Leerzeichen")],
"valvesDeviceReading"=>[("valveposition","string","Reading das die Ventilposition zeigt, default: valveposition")],
"valvesIgnoreLowest"=>[("0","int","ignoriere die niedrigsten N Thermostate")],
"valvesIgnoreHighest"=>[("0","int","ignoriere die höchsten N Thermostate")],
"valvesIgnoreDeviceList"=>[("0","string","Ignoriere diese Devicenamen")],
"valvesPriorityDeviceList"=>[("0","string","Thermostate in dieser Liste werden doppelt gezählt")],
"valves<Devicename>Gewichtung"=>[("1","float","Für jedes Thermostat kann ein individueller Gewichtungsfaktor multipliziert werden. So kann zB ein schlechter hydraulischer Abgleich berücksichtigt werden")],
"disable"=>[("0","int","Berechnung anhalten und einfrieren")],
	);
	if($type eq "keys"){
		return keys(%attribs);
	}elsif($type eq "default"){
		return $attribs{$reqKey}[0];
	}elsif($type eq "type"){
		return $attribs{$reqKey}[1];
	}elsif($type eq "description"){
		return $attribs{$reqKey}[2];
	}elsif($type eq "help"){
		return "attrHelp for ".$reqKey.":\n default:".$attribs{$reqKey}[0]." type:".$attribs{$reqKey}[1].
			" \ndescription:".$attribs{$reqKey}[2];
	}else{
		return "_ attribs?";
		}
	}



1;