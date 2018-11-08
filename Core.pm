#!/usr/local/bin/perl
#
#   NetSoup::Core.pm v01.00.01g 12042000
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
#   Description: This Perl 5.0 class provides object methods for the NetSoup modules.
#                This class does not do much by itself, it is intended that most of
#                the other classes inherit from this class.
#
#
# Methods:
#    new             -  This method is the object constructor for this class
#    initialise      -  This method is the object initialiser stub for this class
#    debug           -  This method sends a debug message to STDERR
#    debugLevel      -  This method sets the object debug level
#    startLog        -  This method starts the log file recording
#    startLogGlobal  -  This method starts the global NetSoup log file recording
#    stopLog         -  This method stops the log file recording
#    stopLogGlobal   -  This method stops the global NetSoup log file recording
#    flushLog        -  This method flushes the log file contents
#    logPathname     -  This method returns the log file pathname
#    removeLog       -  This method deletes the log file
#    dumpArgs        -  This method dumps out the method arguments
#    dumper          -  This method dumps out a nicely formatted data structure
#    dumparray       -  This method dumps the contents of an array to STDERR
#    dumphash        -  This method dumps the contents of a hash to STDERR


package NetSoup::Core;
require 5.004;
use strict qw( vars subs );
use integer;
use UNIVERSAL;
use vars qw( $AUTOLOAD );
SYSTEM: for( $^O ) {
  m/^mac/i && do {
    @NetSoup::Core::ISA = qw( UNIVERSAL );
    last SYSTEM;
  };
  m//i && do {
    eval "use NetSoup::Config;";
    if( $@ ) {
      @NetSoup::Core::ISA = qw( UNIVERSAL );
    } else {
      @NetSoup::Core::ISA = qw( UNIVERSAL NetSoup::Config );
    }
    last SYSTEM;
  };
}
%NetSoup::Core::States  = ( Logging => 0 );
$NetSoup::Core::LogFile = NetSoup::Core->logPathname();
1;


sub new {
  # This method is the object constructor for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    class | object
  #    hash    {
  #             Key => Value
  #             ..
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $object = NetSoup::Core->new();
  my $package = shift;                        # Get package name
  my $class   = ref( $package ) || $package;  # Dereference package into class if necessary
  my $object  = {};                           # Create empty object as hash reference
  my %args    = @_;                           # Get arguments
  bless( $object, $class );                   # Bless object into the $class
  if( ref( $package ) ) {                     # No initialisation is performed on clone
    my $clone = $object->_clone();            # Clone current object
    bless( $clone, $class );                  # Bless object into the $class
    return( $clone );                         # Return cloned object
  }
  $object->{Debug} = $args{Debug} || 0;       # Debug flag
  $object->initialise( @_ );                  # Initialise using possibly overridden method
  return( $object );                          # Return blessed object
}


sub _clone {
  # This private method is the copy constructor for this class.
  # This method is called when the new() method is called on
  # an existing object.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Key => Value
  #              ..
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $object = $object->_clone();
  my $object = shift;    # Get original object
  my $clone  = {};
  
 SWITCH: for( ref( $object ) ) {
    $object->debug( $_ );
    
    ;
    
  }
  
  return( $clone );
}


sub initialise {
  # This method is the object initialiser stub for this class.
  # This method _should_ be overridden by sub-classes.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Key => Value
  #              ..
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $object->initialise();
  my $object = shift;  # Get object
  return( $object );
}


sub fatal {
  # This method generates a fatal error message and exits.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Key => Value
  #              ..
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $object->initialise();
  my $object  = shift;         # Get object
  my $message = shift;         # Get debug message
  $object->debug( $message );  # Generate debug message
  exit(-1);
}


sub debug {
  # This method sends a debug message to STDERR.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    scalar
  # Result Returned:
  #    boolean
  # Example:
  #    $object->debug( $message );
  my $package  = shift;                                              # Get package or object reference
  my $class    = $package || ref( $package );                        # Dereference if necessary
  my $message  = shift;                                              # Get debug message
  my $level    = shift || undef;                                     # Get optional debug level
  my $pathname = $NetSoup::Core::LogFile;                            # Get log file pathname
  my $output   = 0;                                                  # Initialise output flag
  if( defined $level ) {                                             # If defined then use level
    $output++ if( $class->{__DDebugLevel__} >= $level );             # Test debugging level
  } else {
    $output++;
  }
  return(1) if( ! $output );                                         # Test output flag
  chomp( $message );                                                 # Trim extra lines
  if( $^O =~ m/^mac/ ) {                                             # if running on a Macintosh
    $message =~ s/\t/    /gs;                                        # Expand tabs
    $message =~ s/\x0A/\n/gs;                                        # Convert all \n to newline
  }
  print( STDERR ref($class) . "\t\%$$\t$message\n" );                # Output debug message
  if( $class->{__DLogging__} || $NetSoup::Core::States{Logging} ) {  # Return if no logging
    if( open( LOGFILE, ">>$pathname" ) ) {                           # Attempt ot open log file for appending
      print( LOGFILE "$class:$$\t$message\n" );                      # Output debug message to log file
      close( LOGFILE );
    }
  }
  return(1);
}


sub debugLevel {
  # This method sets the object debug level.
  my $object                 = shift;                # Get object
  my $level                  = shift || undef;       # Get debug level
  $object->{__DDebugLevel__} = $level if( $level );  # Set debug level
  return( $object->{__DDebugLevel__} || undef );     # Return debugging level
}


sub startLog {
  # This method starts the log file recording.
  my $object              = shift;              # Get object
  my %args                = @_;                 # Get arguments
  my $flush               = $args{Flush} || 0;  # Get flush argument
  $object->{__DLogging__} = 1;                  # Raise logging flag
  $object->flushLog() if( $flush );             # Flush the log file if true
  return( $object->{__DLogging__} || undef );   # Return debugging level
}


sub startLogGlobal {
  # This method starts the global NetSoup log file recording.
  my $object                      = shift;              # Get object
  my %args                        = @_;                 # Get arguments
  my $flush                       = $args{Flush} || 0;  # Get flush argument
  $NetSoup::Core::States{Logging} = 1;                  # Raise global logging flag
  $object->flushLog() if( $flush );                     # Flush the log file if true
  return( $NetSoup::Core::States{Logging} || undef );   # Return debugging level
}


sub stopLog {
  # This method stops the log file recording.
  my $object              = shift;             # Get object
  $object->{__DLogging__} = 0;                 # Lower logging flag
  return( $object->{__DLogging__} || undef );  # Return debugging level
}


sub stopLogGlobal {
  # This method stops the global NetSoup log file recording.
  my $object                      = shift;             # Get object
  $NetSoup::Core::States{Logging} = 0;                 # Lower global logging flag
  return( $NetSoup::Core::States{Logging} || undef );  # Return debugging level
}


sub flushLog {
  # This method flushes the log file contents.
  my $object   = shift;                    # Get object
  my $pathname = $NetSoup::Core::LogFile;  # Get log file pathname
  if ( open( LOGFILE, ">$pathname" ) ) {   # Attempt ot open log file for writing
    close( LOGFILE );
  } else {
    return(0);
  }
  return(1);
}


sub logPathname {
  # This method sets or gets the log file pathname.
  my $object   = shift;                            # Get object
  my $pathname = shift || undef;                   # Get optional pathname
  if ( $pathname ) {
    my $sep      = "/";                            # Set default delimiter
  SWITCH: for( $^O ) {                             # Switch on OS type
      m/mac/i && do {                              # Get MacOS separator
        $sep = ":";
        last SWITCH;
      };
      m/win/i && do {                              # Get Windoze separator
        $sep = "\\";
        last SWITCH;
      };
    }
    my @pieces  = split( /\Q$sep\E/, $pathname );  # Split on directory separator
    my $logname = "$pieces[-1].log";               # Generate log filename
    $pathname   =~ s/\Q$sep\E$//;                  # Strip trailing separator
    $pathname   = "$pathname$sep$logname";         # Generate log file pathname
  } else {
    my $appname = $0;                              # Get executable pathname
    $appname    =~ s/(\.[^\.]+)?$//;               # Lop off extension
    $pathname   = "$appname.log";                  # Generate log file pathname
  }
  return( $pathname );                             # Return log file pathname
}


sub removeLog {
  # This method deletes the log file.
  my $object   = shift;
  my $pathname = $NetSoup::Core::LogFile;
  if( -e $pathname ) {
    unlink( $pathname ) || return(0);
  }
  return(1);
}


sub dumpArgs {
  # This method dumps out the method arguments.
  my $object  = shift;
  my $hashref = shift;
  print( STDERR "\n\n" );
  foreach ( keys( %$hashref ) ) {
    print( STDERR ref( $object ) . "\t$_\t$$hashref{$_}\n" );
  }
  print( STDERR "\n\n" );
  return(1);
}


sub dumper {
  # This method dumps out a nicely formatted data structure.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Ref => \$scalar | \@array | \%hash
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $object->dumper( Ref => $ref );
  my $object   = shift;                                                      # Get object
  my %args     = @_;                                                         # Get method arguments
  my $circular = $args{Circular} || {};                                      # Get circular references hash reference
  my $ref      = $args{Ref}      || $object;                                 # Get reference to something, or self
  my $recurse  = $args{Recurse}  || 0;                                       # Recursing?
  my $depth    = $args{Depth}    || 0;                                       # Get current depth integer
  my $escape   = sub {                                                       # Escape non-printables
    my $string = shift;
    my @bytes  = split( //, $$string );
    $$string   = "";
    foreach my $i ( @bytes ) {
      if( $i =~ m/(
                   [\x00-\x08]|
                   [\x0A-\x1F]|
                   [\x7F-\xFF]
                  )/gsx ) {
        $i = "\\x" . uc( unpack( "H2", $i ) );                               # Unpack into Perl's hex format
      }
      $$string .= $i;
    }
    return;
  };
  if( $recurse == 0 ) {                                                      # Not recursing, so output initial reference type
    print( STDERR "$ref\n" );                                                # Output formatted line
    $depth += 4;                                                             # Indent more
  }
  $circular->{$ref} = 1 if ref( $ref );                                      # Set entry in circular references hash
 SWITCH: for( $ref ) {                                                       # What kind of reference is this?
    m/ARRAY\([^\)]+\)$/i && do {                                             # Is it an array?
      my $size = @$ref - 1;                                                  # Get number of elements in array
      if( $size < 0 ) {                                                      # Check for empty array reference
        my $line = " " x $depth . qq([No Elements $size]\n);                 # Format nicely
        print( STDERR $line );                                               # Output formatted line
      } else {
        my $longest = length( @$ref );                                       # Holds length of longest index
        my $count   = 0;
      DEEP: foreach my $deep ( @$ref ) {                                     # Iterate over references
          next DEEP if( ! defined $deep );
          my $padding = " " x ( $longest - length( $count ) );               # Calculate indentation depth
          my $copy    = $deep;                                               # Make local copy
          &$escape( \$copy ) if( ! ref $deep );                              # Mask non-printable
          my $line    = " " x $depth . qq($count $padding=> $copy\n);        # Format nicely
          print( STDERR $line );                                             # Output formatted line
          if( exists $circular->{$deep} ) {                                  # Check for circular reference
            my $line = " " x $depth . qq([Circular Reference "$deep"]\n);    # Format nicely
            print( STDERR $line );                                           # Output formatted line
          } else {
            $object->dumper( Circular => $circular,                          # Recurse with nested reference
                             Ref      => $deep,
                             Recurse  => 1,
                             Depth    => $depth + 10 );
          }
          $count++;
        }
      }
      last SWITCH;
    };
    m/HASH\([^\)]+\)$/i && do {                                              # Is it a hash?
      my $size = -1;
      foreach ( keys( %$ref ) ) { $size++ };                                 # Get number of keys in hash
      if( $size == -1 ) {                                                    # Check for empty hash reference
        my $line = " " x $depth . qq([No Keys $size]\n);                     # Format nicely
        print( STDERR $line );                                               # Output formatted line
      } else {
        my $longest = 0;                                                     # Holds length of longest key
      LONGEST: foreach my $i ( sort( keys( %$ref ) ) ) {                     # Calculate the longest key
          next LONGEST if( ! $ref->{$i} );                                   # Skip if key has empty value
          $longest = length( $i ) + 1 if( length( $i ) >= $longest );        # New longest key
        }
      COPY: foreach my $deep ( sort( keys( %$ref ) ) ) {
          my $padding = " " x ( $longest - length( $deep ) );                # Calculate indentation depth
          my $copy    = $$ref{$deep} || next COPY;                           # Make local copy
          &$escape( \$copy ) if( ! ref $deep );                              # Mask non-printable
          my $line    = " " x $depth . qq($deep$padding=> $copy\n);          # Format nicely
          print( STDERR $line );                                             # Output formatted line
          if( exists $circular->{$$ref{$deep}} ) {                           # Check for circular reference
            $padding .= " " x length( $deep ) . " " x $depth . "      ";
            my $line  = qq($padding [Circular Reference "$$ref{$deep}"]\n);  # Format nicely
            print( STDERR $line );                                           # Output formatted line
          } else {
            $object->dumper( Circular => $circular,                          # Recurse with nested reference
                             Ref      => $$ref{$deep},
                             Recurse  => 1,
                             Depth    => $depth + 7 + $longest );            # Nested line will be heavily indented
          }
        }
      }
      last SWITCH;
    };
    m/SCALAR\([^\)]+\)$/i && do {                                            # Is it a scalar?
      my $scalar = $$ref;                                                    # Make local copy of scalar data
      &$escape( \$scalar );                                                  # Mask non-printable
      print( STDERR "    " x $depth . qq($scalar\n) );                       # Format nicely
      last SWITCH;
    };
    m//i && do {                                                             # Unsupported type
      print( STDERR "    " x $depth . qq($ref\n) );                          # Format nicely
      last SWITCH;
    };
  }
  return(1);
}


sub dumparray {
  # This method dumps the contents of an array to STDERR.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Array => \@array
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $object->dumparray( Array => \@array );
  my $object = shift;                 # Get object
  my %args   = @_;                    # Get arguments
  foreach ( sort @{$args{Array}} ) {  # Iterate over array
    my $value = $_ || "undefined";    # Handle undefined values
    print( STDERR "$value\n" );       # Format nicely
  }
  return(1);
}


sub dumphash {
  # This method dumps the contents of a hash to STDERR.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Hash => \%hash
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $object->dumphash( Hash => \%hash );
  my $object = shift;                                # Get object
  my %args   = @_;                                   # Get arguments
  foreach my $key ( sort keys %{$args{Hash}} ) {     # Iterate over hash pairs
    my $value = $args{Hash}->{$key} || "undefined";  # Handle undefined values
    print( STDERR qq($key => $value\n) );            # Format nicely
  }
  return(1);
}


sub boolean {
  # This method takes a boolean scalar reference and inverts it.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Bool => \$scalar
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $object->boolean( Bool => \$scalar );
  my $object = shift;        # Get object
  my %args   = @_;           # Get arguments
  my $bool   = $args{Bool};  # Get reference to scalar
 SWITCH: for( $$bool ) {     # Flip state
    m/0/ && do {
      $$bool = 1;
      last SWITCH;
    };
    m/1/ && do {
      $$bool = 0;
      last SWITCH;
    };
  }
  return( $$bool );          # Return new state
}


sub AUTOLOAD {
  # This method catches undefined method calls.
  # Intended for use if Config.pm is missing or could not be loaded.
  my $object = shift;
  my $method = $AUTOLOAD;
  print( STDERR qq(UNCAUGHT "$method" from ) . caller() . qq(\n) );
  return( undef );
}


sub DESTROY {
  # This method prevents AUTOLOAD being called during object destruction.
  my $object = shift;
  return(1);
}
