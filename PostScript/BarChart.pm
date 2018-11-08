#!/usr/local/bin/perl
#
#   NetSoup::class.pm v00.00.01a 12042000
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
#   Description: This Perl 5.0 class provides object methods for.
#
#
#   Methods:
#       method  -  description


package NetSoup::PostScript::BarChart;
use strict;
use NetSoup::PostScript;
use NetSoup::Files::Save;
@NetSoup::PostScript::BarChart::ISA = qw( NetSoup::PostScript );
my $POSTSCRIPT = join( "", <NetSoup::PostScript::BarChart::DATA> );
1;


sub barchart {
  my $BarChart   = shift;
  my %args       = @_;
  my %values     = %{$args{Values}};
  my $PostScript = NetSoup::PostScript->new();
  my $program    = $POSTSCRIPT;
  my $xorigin    = 20;
  my $yorigin    = 20;
  my $colwidth   = 60;
  my $width      = 40;
  my $height     = 0;
  my $numcols    = ( keys %values );
  foreach my $value ( values %values ) {
    $width += $colwidth;
    if( $height == 0 ) {
      $height = $value;
    } else {
      if( $value > $height ) {
        $height = $value;
      }
    }
  }
  $height  += 40;
  $program .= <<End_PostScript;
    /x $xorigin def
    /y $yorigin def
    /w $width $numcols mul def
    /h $height def
    x y w h barchartscale
End_PostScript
  foreach my $key ( keys %values ) {
    $program .= "$xorigin $yorigin $colwidth $values{$key} ($key) barchart\n";
    $xorigin += $colwidth;
  }
  $program .= <<End_PostScript;
    showpage
End_PostScript
  NetSoup::Files::Save->new()->save( Pathname => "/tmp/netsoup.ps", Data => \$program );
  $PostScript->program( Program => $program );
  my $rendered = $PostScript->render( Type   => "png16m",
                                      Width  => $width,
                                      Height => $height,
                                      XRes   => 72,
                                      YRes   => 72 );
  return( $rendered );
}


__DATA__


/barchart {
  newpath
  /barchartdict 5 dict def
  barchartdict begin
    /message exch def
    /height  exch def
    /width   exch def
    /yorigin exch def
    /xorigin exch def
    xorigin yorigin moveto
    0 height rlineto
    width 0 rlineto
    0 0 height sub rlineto
    0 width sub 0 rlineto
    closepath
    gsave
      1 0 0 setrgbcolor
      fill
    grestore
    0 setgray
    2 setlinewidth
    stroke
    /barchartdict 1 dict def
    barchartdict begin
      /Helvetica-Bold findfont
      10 scalefont
      setfont
      xorigin yorigin moveto
      /offset width message stringwidth pop sub 2 div def
      offset 8 rmoveto
      1 setgray
      message show
    end
  end
} def


/barchartscale {
  newpath
  /barchartscaledict 10 dict def
  barchartscaledict begin
    /height  exch def
    /width   exch def
    /yorigin exch def
    /xorigin exch def
    xorigin xorigin moveto
    0 height rlineto
    0 setgray
    2 setlinewidth
    stroke
    10 10 height {
      newpath
      xorigin exch yorigin add moveto
      -5 0 rlineto
      2 setlinewidth
      0 0 0 setrgbcolor
      gsave
        /Helvetica-Bold findfont
        8 scalefont
        setfont
        -8 -2 rmoveto
      grestore
      stroke
    } for
  end
} def
