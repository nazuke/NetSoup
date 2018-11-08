#!/usr/local/bin/perl
#
#   NetSoup::Packages::HyperGlot::lib::MkMap.pm v00.00.01z 12042000
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
#   Description: This Perl 5.0 library is part of the Online Html Editor.
#                This library provides site mapping database functions.
#
#
#   Methods:
#       mkmap  -  This function builds the site map Html database.
#
#
#   Database Structure
#
#       Record {
#                Domain   => Project Site Name
#                Title    => This Document Title
#                Pathname => This Document Path
#                Username => Username of logged user
#                Status   => Current Document Status
#       }


package NetSoup::Packages::HyperGlot::lib::MkMap;
use strict;
use NetSoup::Files::Directory;
@NetSoup::Packages::HyperGlot::lib::MkMap::ISA = qw( NetSoup::Files::Directory );
1;


sub mkmap {
  # This method builds the site map.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              DB       => \%db
  #              Pathname => $pathname
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $success = $map->mkmap( DB => \%db, Pathname => $pathname );
  my $MkMap     = shift;                                          # Get object
  my %args      = @_;                                             # Get arguments
  my $DB        = $args{DB};                                      # Get reference to database hash
  my $pathname  = $args{Pathname};                                # Get site name to map
  my $Directory = NetSoup::Files::Directory->new();               # Get new Directory object
  my $domain    = $Directory->filename( Pathname => $pathname );  # Get domain name from path
  my %filelist  = ();
  return(1) if( exists( $DB->{$domain} ) );
  my $callback = sub {
    my $path         = shift;                                     # Get pathname from method
    $filelist{$path} = { Domain   => $domain,                     # Name of entire site project
                         Title    => "Title",                     # Set Title field
                         Pathname => $path,                       # Set pathname field
                         Username => "Nobody",                    # Set Username field
                         Status   => "Not Done" };                # Initialise Status field
  };
  $Directory->descend( Pathname  => $pathname,                    # Descend directory tree
                       Recursive => 1,
                       Callback  => $callback );
  $DB->{$domain} = \%filelist;
  return(1);
}
