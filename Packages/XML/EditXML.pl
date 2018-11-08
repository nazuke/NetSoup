#!/usr/local/bin/perl -w
#
#   NetSoup::Packages::XML::EditXML.pl v00.00.01a 12042000
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
#   Description: This Perl 5.0 script exercises the XML DOM class.


use strict;
use Tk;
use Tk::FileSelect;
use NetSoup::XML::Parser;
use NetSoup::XML::GUI::ViewEdit;


my $VIEWEDIT = "NetSoup::XML::GUI::ViewEdit";
my $win      = MainWindow->new( -title  => "HyperEdit",
                                -width  => 640,
                                -height => 480 );
my $load     = $win->Button( -text    => "Open",
                             -command => sub { loader($win) } );
my $quit     = $win->Button( -text    => "Quit",
                             -command => sub { exit(0) } );
$load->pack( -anchor => "nw",
             -expand => 1,
             -fill   => "both",
             -side   => "left" );
$quit->pack( -anchor => "ne",
             -expand => 1,
             -fill   => "both",
             -side   => "right" );
foreach my $pathname ( @ARGV ) {
  my $ViewEdit = $VIEWEDIT->new( Window   => $win,
                                 Pathname => $pathname ) if( $pathname );
}
MainLoop();
exit(0);


sub loader {
  my $win     = shift;
  my $Chooser = $win->FileSelect( -directory => "." );
  my $pathname = $Chooser->Show();
  my $ViewEdit = $VIEWEDIT->new( Window   => $win,
                                 Pathname => $pathname ) if( $pathname );
  return( $ViewEdit );
}
