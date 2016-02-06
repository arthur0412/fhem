
sub Vaillant_Timer($)
{
  my @values=split(/[; ]/,$_);
  #-- suppress leading zero ?
  for(my $i=0;$i<7;$i++){ 
    $values[$i]=~s/^0//;
  }
  my $sval=sprintf("%s-%s",$values[0],$values[1]);
  $sval  .=sprintf(", %s-%s",$values[2],$values[3])
    if($values[2] ne $values[3]);
  $sval  .=sprintf(", %s-%s",$values[4],$values[5])
    if($values[4] ne $values[5]);
  return $sval;
}

sub s_ebus($){
 my $text = shift; 
 my $ret = "</td></tr><tr><td>";
 $ret .= ($text);
 $ret =~ s,\;,  ,g;
 $ret =~ s,\n,</td></tr><tr><td>,g;
return $ret;
}