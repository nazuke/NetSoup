#!/usr/local/bin/perl
#
#   NetSoup::Autonomy::DRE::Query::HTTP.pm v00.00.01a 12042000
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


package NetSoup::Autonomy::DRE::Query::HTTP;
use strict;
use LWP::Simple;
use Digest::MD5;
use NetSoup::Core;
use NetSoup::Files;
use NetSoup::Protocol::HTTP;
@NetSoup::Autonomy::DRE::Query::HTTP::ISA = qw( NetSoup::Core );
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Caching  => 0 | 1
  #              Period   => time
  #              Hostname => $hostname
  #              Port     => 0 .. 65535
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Query          = shift;                   # Get DRE Query object
  my %args           = @_;                      # Get arguments
  $Query->{Caching}  = $args{Caching} || 0;     # Caching flag
  $Query->{Period}   = $args{Period}  || 3600;  # Caching period, default one hour
  $Query->{Hostname} = $args{Hostname};         # DRE Hostname/IP Address
  $Query->{Port}     = $args{Port};             # DRE Port Number
  $Query->{Cached}   = 0;
  $Query->{NumHits}  = 0;
  $Query->{Fields}   = {};
  $Query->{Docs}     = [];
  $Query->{TResult}  = "";                      # Temporary storage for raw query result
  return( $Query );
}


sub query {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              QMethod   => $QMethod
  #              QueryText => $QueryText
  #              QNum      => $QNum
  #              Database  => $Database
  #              XOptions  => $XOptions
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Query         = shift;                           # Get DRE Query object
  my %args          = @_;                              # Get arguments
  my $HTTP          = NetSoup::Protocol::HTTP->new();  #
  my $QMethod       = $args{QMethod}  || "q";
  my $QueryText     = $HTTP->escape( URL => $args{QueryText} );
  my $XOptions      = $args{XOptions} || "";
  $Query->{TResult} = "";
  my $MD5           = Digest::MD5->new();
  $MD5->add( $Query->{Hostname} );
  $MD5->add( $Query->{Port} );
  $MD5->add( $args{QNum} );
  $MD5->add( $args{Database} || "" );
  $MD5->add( $XOptions );
  $MD5->add( $QueryText );
  my $digest = $Query->cachefile( Pathname => "/tmp/DRE_Cache", Digest => $MD5->hexdigest() );
  my $flag   = 1;
  if( $Query->{Caching} ) {
    if( -e $digest ) {
      #print( STDERR qq(Using Cachefile "$digest" for Query "$QueryText"\n) );
      my ( $dev,
           $ino,
           $mode,
           $nlink,
           $uid,
           $gid,
           $rdev,
           $size,
           $atime,
           $mtime,
           $ctime,
           $blksize,
           $blocks ) = stat( $digest );
      if( ( time - $mtime ) < $Query->{Period} ) {
        open( FILE, $digest );
        $Query->{TResult} = join( "", <FILE> );
        close( FILE );
        $flag = 0;
        $Query->{Cached} = 1;
      }
    }
  }
  if( $flag == 1 ) {
    my $QNum     = $args{QNum}     || 6;
    my $Database = $args{Database} || "*";
    $Query->{TResult} = get( "http://$Query->{Hostname}:$Query->{Port}/qmethod=$QMethod&querytext=$QueryText&qnum=$QNum&attachtoname=$Database&xoptions=$XOptions" );
  }
  $Query->parse( Result => $Query->{TResult} );
  if( ( $Query->numhits() > 0 ) && ( $Query->{Caching} ) ) {
    if( ( NetSoup::Files->new()->buildTree( Pathname => $digest,
                                            Perm     => 0666 ) ) &&
        ( open( FILE, ">$digest" ) ) ) {
      print( FILE $Query->{TResult} );
      close( FILE );
    } else {
      print( STDERR qq(Failed to open "$digest" cache file\n) );
    }
  }
  return( $Query );
}


sub parse {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Result => $result
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Query   = shift;                           # Get DRE Query object
  my %args    = @_;                              # Get arguments
  my $Result  = $args{Result};
  my $length  = length( $Result );
  my %State   = ( Key => 1 );
  my $Cursor  = 0;
  my $Initial = "";
  my $Key     = "";
  my $ptr     = 0;
  my $stash   = $ptr;
 NUMHITS: for( $ptr = 0 ; $ptr < $length ; $ptr++ ) {
    my $char = substr( $Result, $ptr, 1 );
    if( $char eq "=" ) {
      for( $ptr = ++$ptr ; $ptr < $length ; $ptr++ ) {
        my $int = substr( $Result, $ptr, 1 );
        last NUMHITS if( $int =~ m/[\n]/s );
        $Query->{NumHits} .= $int;
      }
      last NUMHITS;
    }
  }
  $stash = $ptr;                                                      # Store pointer value
 INITIAL: for( $ptr = ++$ptr ; $ptr < $length ; $ptr++ ) {  #
    my $char = substr( $Result, $ptr, 1 );
    if( $char eq "=" ) {
      last INITIAL;
    } else {
      $Initial .= $char;
    }
  }
  $ptr                      = $stash;                                 # Restore pointer value
  $Query->{Docs}->[$Cursor] = {};
 PARSE: for( $ptr = ++$ptr ; $ptr < $length ; $ptr++ ) {
  SWITCH: for( substr( $Result, $ptr, 1 ) ) {
      m/^=$/is && do {
        if( $State{Key} == 1 ) {
          $Query->{Docs}->[$Cursor]->{$Key} = "";
          $Query->{Fields}->{$Key}          = 1;
          $State{Key}                       = 0;
          if( substr( $Result, $ptr + 1, 1 ) eq "\n" ) {
            $Key        = "";
            $State{Key} = 1;
          }
        } else {
          $Query->{Docs}->[$Cursor]->{$Key} .= $_;
        }
        last SWITCH;
      };
      m/^\n$/is && do {
        $State{Key} = 1;
        $Key        = "";
        last SWITCH;
      };
      m/^\*$/is && ( $State{Key} == 1 ) && last PARSE;
      m/^.$/is && do {
        if( $State{Key} == 1 ) {
          $Key .= lc( $_ );
          $Cursor++ if( ( substr( $Result, $ptr + 1, 1 ) eq "=" ) &&
                        ( $Key eq lc( $Initial ) ) );
        } else {
          $Query->{Docs}->[$Cursor]->{$Key} .= $_;
        }
        last SWITCH;
      };
    }
  }
  return(1);
}


sub cached {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Key => Value
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Query = shift;           # Get DRE Query object
  my %args  = @_;              # Get arguments
  return( $Query->{Cached} );  # Return the cached flag
}


sub numhits {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Key => Value
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Query = shift;            # Get DRE Query object
  my %args  = @_;               # Get arguments
  return( $Query->{NumHits} );  # Return the number of hits
}


sub fieldnames {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Key => Value
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Query = shift;                        # Get DRE Query object
  my %args  = @_;                           # Get arguments
  return( sort keys %{$Query->{Fields}} );  # Return sorted field name list
}


sub field {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Index => $index
  #              Field => $field
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Query = shift;                             # Get DRE Query object
  my %args  = @_;                                # Get arguments
  my $Index = $args{Index};
  my $Field = lc( $args{Field} );
  return( $Query->{Docs}->[$Index]->{$Field} );  #
}


sub cachefile {
  my $Query    = shift;                                    # Get object
  my %args     = @_;                                       # Get arguments
  my $pathname = $args{Pathname};
  my @chars    = split( //, $args{Digest} );
  while( @chars ) {
    $pathname .= "/" . shift( @chars ) . shift( @chars );
  }
  return( $pathname . "/cache" );
}


sub tresult {
  my $Query = shift;            # Get object
  my %args  = @_;               # Get arguments
  return( $Query->{TResult} );  #
}
