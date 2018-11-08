#!/usr/local/bin/perl
#
#   NetSoup::Files.pm v00.00.01g 12042000
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
#   Description: This Perl 5.0 class provides core object methods for the Files classes.
#
#
#   Methods:
#       separator  -  This method returns the directory separator for the host system
#       pathname   -  This method returns the pathname component of the pathname
#       filename   -  This method returns the filename component of the pathname
#       buildTree  -  This method builds a new path tree given a pathname
#       move       -  This method moves a file from the old location to the new location
#       copy       -  This method copies a file from the old location to the new location


package NetSoup::Files;
use strict;
use NetSoup::Core;
@NetSoup::Files::ISA = qw( NetSoup::Core );
1;


sub separator {
  # This method returns the directory separator for the host system.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    scalar
  # Example:
  my $Files = shift;   # Get object
  my $sep   = "/";     # Set default delimiter
 SWITCH: for( $^O ) {  # Switch on OS type
    m/mac/i && do {    # Set MacOS separator
      $sep = ":";
      last SWITCH
    };
  }
  return( $sep );
}


sub pathname {
  # This method returns the pathname component of the pathname.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Pathname => $pathname
  #            }
  # Result Returned:
  #    scalar
  # Example:
  #    my $filename = $Files->filename( Pathname => $pathname );
  my $Files    = shift;                   # Get object
  my %args     = @_;                      # Get arguments
  my $pathname = $args{Pathname};         # Get pathname
  my $filename = $Files->filename( @_ );  # Get filename component
  my $sep      = $Files->separator();
  $pathname    =~ s/\Q$filename\E$//;     # Chop off filename
  $pathname    =~ s/\Q$sep\E$//;          # Chop off seperator
  return( $pathname );                    # Return pathname component
}


sub filename {
  # This method returns the filename component of the pathname.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Pathname => $pathname
  #            }
  # Result Returned:
  #    scalar
  # Example:
  #    my $filename = $Files->filename( Pathname => $pathname );
  my $Files    = shift;                          # Get object
  my %args     = @_;                             # Get arguments
  my $pathname = $args{Pathname};                # Get pathname
  my $sep      =  $Files->separator();           # Get system directory separator
  my @pieces   = split( /\Q$sep\E/, $pathname ); # Split on directory separator
  return( $pieces[-1] );                         # Return filename component
}


sub buildTree {
  # This method builds a new path tree given a pathname.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #                Pathname => $pathname
  #                Perms    => $permissions
  #              [ Bare     => 0 | 1 ]
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $Files->buildTree( Pathname => $pathname );
  my $Files     = shift;                                             # Get object
  my %args      = @_;                                                # Get remaining arguments
  my $perms     = $args{Perms} || 0755;                              # Get permissions
  my $bare      = $args{Bare}  || 0;                                 # Pathname does not include filename
  my $sep       = $Files->separator();                               # Get directory separator
  my $root      = $sep if( $args{Pathname} =~ m/^\Q$sep\E/ ) || "";  # Check for root separator
  my @tree      = split( /\Q$sep\E/, $args{Pathname} );              # Get component directories
  my $buildTree = "";                                                # Initialise build path
  my $filename  = "";
  $filename     = pop @tree if( ! $bare );                           # Pop filename off of pathname if not bare pathname
  return(1) if( ! @tree );                                           # Return if no directories left
  $tree[0] .= $sep if( $root );                                      # Prepend root separator to first directory
  foreach my $dir ( @tree ) {                                        # Iterate over directories
    next if( ! $dir );
    $buildTree .= $dir . $sep;                                       # Prefix slash
    $buildTree  =~ s/\Q$sep\E+/$sep/g;                               # Tidy up separators
    if( ! -e $buildTree ) {                                          # Create new directory with rwxrwxrwx permissions
      mkdir( $buildTree, $perms ) || return undef;                   # Attempt to create new directory with rwxrwxrwx permissions
    }
  }
  return( "$buildTree$filename" );
}


sub move {
  # This method moves a file from the old location to the new location.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              From  => $sourcePathname
  #              To    => $destinationPathname
  #              Build => 0 | 1
  #            }
  # Result Returned:
  #    boolean
  my $Files = shift;                                              # Get object
  my %args  = @_;                                                 # Get remaining arguments
  $Files->buildTree( Pathname => $args{To} ) if( $args{Build} );  # Build path to file
  if( $Files->copy( %args ) ) {                                   # Copy the file to the new location
    unlink( $args{From} );                                        # Delete the old file
  } else {
    return(0);
  }
  return(1);
}


sub copy {
  # This method copies a file from the old location to the new location.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              From  => $sourcePathname
  #              To    => $destinationPathname
  #              Build => 0 | 1
  #            }
  # Result Returned:
  #    boolean
  my $Files = shift;                                              # Get object
  my %args  = @_;                                                 # Get remaining arguments
  $Files->buildTree( Pathname => $args{To} ) if( $args{Build} );  # Build path to file
  open( FROM, $args{From} ) || return undef;
  open( TO, ">$args{To}" )  || return undef;
  print( TO $_ ) while( <FROM> );                                 # Copy lines from old to new
  close( TO );
  close( FROM );
  return(1);
}
