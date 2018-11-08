#!/usr/local/bin/perl
#
#   NetSoup::Scripts::Tools::Web::tkwebget.pl v00.00.01a 12042000
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
#   Description: This Perl 5.0 script fetches a document from the world wide web.


use NetSoup::Protocol::HTTP_1;
use Tk;


my $Url      = "";                                                                  # Scalar for url text field
my $Progress = "";                                                                  # Scalar for progress field
my $mw       = MainWindow->new();                                                   # Get new main window object
my $url      = $mw->Entry( -textvariable => \$Url )->pack( -side => left );         #
my $progress = $mw->Entry( -textvariable => \$Progress )->pack( -side => left );    #
my $fetch    = $mw->Button( -text    => "Fetch",
                            -command => sub { fetch( $Url ) } )->pack();
my $exit     = $mw->Button( -text    => "Exit",
                            -command => sub { exit(0) } )->pack();
MainLoop;
exit(0);


sub fetch {
  # This function fetches the documents from the server.
  my $url    = shift;
  my $object = NetSoup::Protocol::HTTP_1->new();
  my $data   = "";
  $object->debug( "URL\t$url" );
  $object->get( Url      => $url,
                Data     => \$data,
                Callback => sub { my $data = shift;
                                  print STDOUT $$data; }
              );
  return(1);
}
