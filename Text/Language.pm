#!/usr/local/bin/perl
#
#   NetSoup::Text::Language.pm v00.00.01g 12042000
#
#   Copyright (C) 2000  Jason Holland <jason.holland@dial.pipex.com>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#
#   Description: This Perl 5.0 class provides object methods for spoken/written language analysis.
#
#
#   Methods:
#       initialise  -  This method is the object initialiser for this class
#       identify    -  This method attempts to determine the written language sample data


package NetSoup::Text::Language;
use strict;
use NetSoup::Core;
@NetSoup::Text::Language::ISA = qw( NetSoup::Core );
my @LANGUAGES = ();
while( <NetSoup::Text::Language::DATA> ) {
  chomp;
  push( @LANGUAGES, $_ ) if( $_ );
}
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    Language
  # Result Returned:
  #    object
  # Example:
  #    $Language->initialise();
  my $Language           = shift;        # Get Language object
  $Language->{Languages} = \@LANGUAGES;  # Link object to class global array
  return(1);
}


sub identify {
  # This method attempts to determine the written language sample data.
  # Calls:
  #    none
  # Parameters Required:
  #    Language
  #    hash {
  #           Text => \$Text
  #         }
  # Result Returned:
  #    array
  #        Array Contains:
  #            boolean result, language name
  # Example:
  #    my $lang = $Language->identify( $Text => \$Text );
  my $Language = shift;                               # Get Language object
  my %args     = @_;                                  # Get remaining parameters
  my $Text     = $args{Text};                         # Get data reference
  my %score    = ();                                  # Hash holds word scores for each language
  my $lang     = "";
  my $max      = 0;
  foreach ( @{$Language->{Languages}} ) {             # Iterate through language database
    next if( ! $_ );
    s/(\13\10|\13|\10)$//;                            # Strip linefeeds
    my @line         = split( /\t+/ );                # Split  language name from words
    my @words        = split( /,/, $line[1] );        # Split into component words
    $score{$line[0]} = 0;                             # Zero language score counter
    foreach my $i ( @words ) {
      $score{$line[0]}++ if( $$Text =~ m/\s$i\s/i );  # Look for string match within plain text data
    }
  }
  foreach ( sort keys %score ) {                      # Search for highest scoring language
    if( $score{$_} > $max ) {                         # Compare current max score
      $lang = $_;                                     # Select this language if higher score
      $max  = $score{$_};                             # Keep score
    }
  }
  return( $lang || undef );                           # Return language string or undef
}


__DATA__
Danish    en,alle,ogs&aring;,er,ved,klik,afslut,hvordan,hvis,den,det,nej,ikke,af,fra,ud,s&aring;,dem,da,til,vi,var,som,der,idet,hvorfor,med
Dutch    een,alles,ook,zijn,door,klikken,afsluiten,hoe,als,in,is,het,nee,niet,van,uit,dus,de,zij,dan,naar,wij,waren,wat,wanneer,waar,waarom,met
English    all,also,are,by,click,exit,how,if,is,it,no,not,of,off,out,so,the,them,then,to,we,were,what,when,where,why,with
Finnish    ja,kyll&auml;,ei,napsauta,on,mit&auml;,miksi,k&auml;ytt&auml;j&auml;,niin,sitten,tietokone,j&auml;rjestelm&auml;,my&ouml;s,jos,sin&auml;,kansio,tiedosto,hakemisto,nappi,n&auml;pp&auml;in
French    le,la,les,de,du,des,tout,tous,toute,toutes,est,sont,par,cliquez,cliquer,quittez,quitter,comment,si,dans,il,elle,ils,elles,ne,pas,aussi,mais,clic,puis,sur,avec,qui,que,o&ugrave;,quand,lorsque,comment,vous,&ecirc;tes,pour,sans,avoir,avez,alors,en
German    der,die,das,sind,ist,ein,eine,einer,klicken,beenden,wenn,in,an,auf,wo,wer,was,wann,welche,warum,mit,durch,es,und,so,als,er,sie,wir,aus,wie
Italian    un,uno,una,il,lo,la,gli,le,sono,&egrave;,essere,tutto,tutti,tutte,per,perch&eacute;,come,fare clic,uscire,esci,anche,ma,cosa,quando,con,e,di,chi,che,dove,avere,ha,hanno,in,per&ograve;,oppure,questo,questa,questi,queste,quello,quella,quelli,quelle,senza,mai,sempre,se
Norwegian  en,ei,et,alt,alle,ogs&aring;,og,er,ved,klikk,klikke,avslutt,avslutte,hvordan,dersom,hvis,om,den,det,nei,ikke,av,ut,s&aring;,slik,de,dem,da,s&aring;,deretter,til,&aring;,vi,var,hva,n&aring;r,hvor,hvorfor,med
Portugeuse  um,uma,tudo,todos,todas,por,pelo,pela,clique,clicar,sair,como,se,no,na,nos,nas,n&atilde;o,ele,&eacute;,de,sem,assim,o,os,as,elas,eles,ent&atilde;o,em seguida,depois,para,n&oacute;s,estavam,eram,foram,que,qual,o que,quando,onde,porque,porqu&ecirc;,por que,com,mas
Spanish    un,una,tambi&eacute;n,son,es,por,clic,salir,como,si,en,de,no,est&aacute;,desde,fuera,dentro,para,el,la,lo,los,las,eso,esa,esos,esas,estaba,era,fue,cuando,donde,que,con,&eacute;l,ella,ellos,ellas,son,somos,tiene,abrir,cerrar,buscar,sin,porque,siempre,nunca
Swedish    en,ett,alla,allt,ocks&aring;,&auml;r,av,klick,klicka,avsluta,hur,om,&auml;r,det,nej,inte,av,fr&aring;n,ut,s&aring;,den,det,dem,d&aring;,till,vi,var,vad,n&auml;r,var,varf&ouml;r,med
