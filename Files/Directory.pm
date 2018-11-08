#!/usr/local/bin/perl
#
#   NetSoup::Files::Directory.pm v00.00.01g 12042000
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
#   Description: This Perl 5.0 class provides recursive directory scanning methods.
#                This implementation is designed to work cross-platform, mostly.
#
#
#   Methods:
#       descend  -  This method descends a directory tree, executing a callback for each file found


package NetSoup::Files::Directory;
use strict;
use NetSoup::Files;
use Sort::Naturally;
@NetSoup::Files::Directory::ISA = qw( NetSoup::Files );
1;


sub descend {
  # This method descends a directory tree, executing a callback for each file found.
  # Calls:
  #    self
  # Parameters Required:
  #    object    an object of type NetSoup::Files::Directory
  #    hashref {
  #              Pathname    => $pathname
  #              Extensions  => [ "c", "h", ... ]
  #              Recursive   => 0 | 1
  #              Files       => 0 | 1
  #              Directories => 0 | 1
  #              Sort        => 0 | 1
  #              NSort       => 0 | 1
  #              Callback    => sub { my $path = shift }
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $object->descend();
  my $object       = shift;                                                  # Get object reference
  my %args         = @_;                                                     # Get remaining arguments
  my ( $pathname ) = ( $args{Pathname} =~ m:^(.+)/?$: );                     # Get pathname minus terminal slash
  my $extensions   = $args{Extensions} || undef;                             # Get extensions array reference
  my $recursive    = $args{Recursive}  || undef;                             # Get recursive switch
  my $files        = 1;                                                      # Operate on files flag
  my $callback     = $args{Callback}   || undef;                             # Get callback function to execute
  my $sep          = $object->separator();                                   # Get directory separator
  my @list         = ();                                                     # This temporary array stores the current file list
  if( exists $args{Files} ) {
    $files = $args{Files};
  }
  return(0) if( ! opendir( DIR, $pathname ) );                               # Open directory or return on error
  @list = readdir( DIR );
  if( ( exists( $args{Sort} ) ) && ( $args{Sort} == 1 ) ) {
    #@list = sort( @list );
    @list = nsort( @list );
  } elsif( ( exists( $args{NSort} ) ) && ( $args{NSort} == 1 ) ) {
    @list = nsort( @list );
  }
  if( -e $pathname . '/.reverse' ) {
    @list = reverse @list;
  }
  closedir( DIR );
 SCAN: foreach my $i ( @list ) {                                             # Iterate over pathname list
    if( -d "$pathname$sep$i" ) {
      next SCAN if( $i =~ m:^\.\.?$: );                                      # Skip if self or parent directory
      if( exists $args{Directories} ) {
        &$callback( "$pathname$sep$i" ) if( $args{Directories} == 1 );       # Execute callback on directory
      }
      $object->descend( Pathname   => "$pathname$sep$i",
                        Extensions => $args{Extensions},
                        Recursive  => $args{Recursive},
                        Files      => $files,
                        Sort       => $args{Sort} || 0,
                        NSort      => $args{NSort} || 0,
                        Callback   => $callback ) if( defined $recursive );  # Scan recursively if required
    } else {
      my $check = 0;                                                         # Flags a valid filename extension
      if( $extensions ) {                                                    # Check for extension array reference
        foreach my $ext ( @$extensions ) {                                   # Iterate over extensions
          #$check++ if( "$pathname$sep$i" =~ m/\.\Q$ext\E$/i );              # Set flag if valid extension
          $check++ if( $i =~ m/\.$ext$/i );                                  # Set flag if valid extension
        }
      } else {
        $check++;                                                            # Extensions are being ignored
      }
      if( ( -f "$pathname$sep$i" ) && $files ) {                             # Flagged to operate on files
        &$callback( "$pathname$sep$i" ) if( $check );                        # Execute callback on file
      }
    }
  }
  return(1);
}
