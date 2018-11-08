#!/usr/local/bin/perl
#
#   NetSoup::Protocol.pm v00.03.26g 12042000
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
#   Description: This Perl Class provides a simplified object oriented.
#                interface to the Standard Perl 5.0 Sockets.pm library.
#
#   Methods:
#       initialise  -  This method is the object initialiser for this class
#       client      -  This method initialises a blank socket as a client
#       server      -  This method initialises a blank socket as a server
#       loop        -  This method provides a simple main server loop
#       get         -  This method reads from a socket
#       put         -  This method writes to a socket
#       disconnect  -  This method shuts down a socket connection
#       ready       -  This method does a select(2) on a socket
#       reaper      -  This method harvests zombie processes
#       DESTROY     -  This method is the object destructor for this class
#       END         -  This method is the class destructor for this class


package NetSoup::Protocol;
use strict;
use Socket;
use NetSoup::Core;
@NetSoup::Protocol::ISA         = qw( NetSoup::Core );
@NetSoup::Protocol::Objects     = ();  # Object count
$NetSoup::Protocol::QueueLength = 10;  # Global queue count
$NetSoup::Protocol::Children    = 10;  # Global child process count
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Address => $address
  #              Port    => $port
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $Protocol = NetSoup::Protocol->new();
  my $Protocol            = shift;                            # Get Protocol object
  my %args                = @_;                               # Get parameters
  $Protocol->{Client}     = 1;                                # If true then object is a client, otherwise a server
  $Protocol->{RemoteAddr} = $args{Address} || undef;          # Store address of remote host
  $Protocol->{Port}       = $args{Port}    || undef;          # Socket Port Address
  $Protocol->{ClientHndl} = \*CLIENTHNDL;                     # Socket File Handle
  $Protocol->{ServerHndl} = \*SERVERHNDL;                     # Socket File Handle, used by loop()
  $Protocol->{QLength}    = $NetSoup::Protocol::QueueLength;  # Socket Protocol Type - Only TCP!
  $Protocol->{Processes}  = [];                               # Initialise object process list
  $Protocol->{Children}   = 0;                                # Initialise child process counter
  push( @NetSoup::Protocol::Objects, $Protocol );             # Add object to class object list
  return( $Protocol );
}


sub client {
  # This method takes a blank socket object and initialises it as a client side socket object.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              [ Address => $address ]
  #              [ Port    => $port ]
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $Protocol->client();
  my $Protocol = shift;                                                      # Get Protocol object
  my %args     = @_;                                                         # Get parameters
  my $servAddr = inet_aton( $Protocol->{RemoteAddr} || $args{Address} );     # Get server address
  if( defined $servAddr ) {
    my $port       = $Protocol->{Port} || $args{Port};                       # Get port number
    my $clientAddr = sockaddr_in( $port, $servAddr ) || return(0);           # Get client address
    my $proto      = getprotobyname( 'tcp' );                                # Get proper protocol
    if( socket( $Protocol->{ClientHndl}, PF_INET, SOCK_STREAM, $proto ) ) {  # Attempt to initialise a blank socket
      my $retry   = 10;
      my $success = 0;
      while( ( ( ! defined $success ) || ( $success != 1 ) ) &&              # Try to connect
             ( $retry > 0 ) ) {
        $success = connect( $Protocol->{ClientHndl}, $clientAddr );          # Attempt to connect socket to remote address
        $retry--;
      }
      if( ! $success ) {                                                     # Failed connection
        close( $Protocol->{ClientHndl} );                                    # Socket connect failed
        return(0);
      }
    } else {
      return(0);                                                             # Socket initialisation failed
    }
  } else {
    return(0);
  }
  return(1);                                                                 # Return successfully
}


sub server {
  # This method takes a blank socket object and initialises it as a server side socket object.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Port => $port
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $Protocol->server();
  my $Protocol = shift;                                                              # Get Protocol object
  my %args     = @_;                                                                 # Get parameters
  my $port     = $args{Port} || $Protocol->{Port};                                   # Get port number to bind to
  my $proto    = getprotobyname('tcp');
  socket( $Protocol->{ClientHndl}, PF_INET, SOCK_STREAM, $proto ) || return(0);      # Attempt to initialise socket
  setsockopt( $Protocol->{ClientHndl}, SOL_SOCKET, SO_REUSEADDR, 1 );
  if( bind( $Protocol->{ClientHndl}, Socket::sockaddr_in( $port, INADDR_ANY ) ) ) {  # Attempt to bind socket to the port
    if( ! listen( $Protocol->{ClientHndl}, $NetSoup::Protocol::QueueLength ) ) {     # Attempt to listen
      close( $Protocol->{ClientHndl} );
      return(0);
    }
  } else {
    close( $Protocol->{ClientHndl} );                                                # Socket bind failed
    return(0);
  }
  $Protocol->{Client} = 0;                                                           # Reconfigure object as a server
  return(1);                                                                         # Socket configured and listening
}


sub loop {
  # This method puts the server into a loop until an incoming client request
  # is accepted, the callback is then executed to process the request.
  # The calling program should install a signal handler to raise the 'quit'
  # scalar to a true value to make the loop exit.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Callback => sub {}
  #              Args     => \$scalar | \@array | \%hash
  #              Fork     => 0 | 1
  #              Quit     => \$scalar
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $Protocol->loop();
  my $Protocol = shift;                                            # Get Protocol object
  my %args     = @_;                                               # Get parameters
  my $callback = $args{Callback};                                  # Get callback reference
  my $params   = $args{Args} || undef;                             # Get reference to callback parameters
  my $quit     = $args{Quit} || 0;                                 # Reference to 'quit' scalar
 WAIT: while( $$quit == 0 ) {                                      # Infinite loop
    accept( $Protocol->{ServerHndl}, $Protocol->{ClientHndl} );    # Wait for connection from client
    if( $args{Fork} ) {                                            # Want a forking server ?
      my $pid = fork();                                            # Spawn child process
      if( $pid != 0 ) {                                            # I'm the parent
        push( @{$Protocol->{Processes}}, $pid );                   # Add id to process list
        $Protocol->{Children}++;                                   # Increment child process counter
      } else {                                                     # I'm the child
        &$callback( $params );                                     # Execute callback
        close( $Protocol->{ServerHndl} );
        exit(0);                                                   # And exit
      }
    } else {
      &$callback( $params );                                       # Execute callback
      close( $Protocol->{ServerHndl} );
    }
    if( $Protocol->{Children} >= $NetSoup::Protocol::Children ) {  # Harvest zombie processes
      $Protocol->reaper();
    }
  }
  return(1);
}


sub get {
  # This method reads an arbitrary number of bytes from a socket.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #                Data     => \$scalar
  #              [ Length   => $length ]
  #              [ Boundary => $boundary ]
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $Protocol->get();
  my $Protocol    = shift;                                      # Get Protocol object
  my %args        = @_;                                         # Get parameters
  my $data        = $args{Data};                                # Reference to scalar
  my $bytes       = $args{Length} || undef;                     # Number of bytes to read
  my $bytesReq    = $bytes;                                     # Store bytes required
  my $handle      = undef;
  my $READ_LENGTH = 1;                                          # Constant holds number of bytes to read
  my $minibuf     = "";                                         # Minibuffer temporarily holds incoming data
  if( $Protocol->{Client} ) {
    $handle = $Protocol->{ClientHndl};
  } else {
    $handle = $Protocol->{ServerHndl};
  }
  if( $bytes ) {                                                # Read number of bytes from socket
    my $success = 0;
    while( $bytes > 0 ) {                                       # Loop until remainder depleted
      $success = sysread( $handle, $minibuf, $bytes );          # Attempt socket read
      $bytes   = $bytes - $success;
      $$data  .= $minibuf;                                      # Store data
    }
    if( length( $$data ) != $bytesReq ) {                       # Check required data received
      $$data .= undef;                                          # Undefine data scalar
      return(0);                                                # Return on socket read error
    }
  } else {                                                      # Read socket until no more data
    my $success = sysread( $handle, $minibuf, $READ_LENGTH );   # Attempt socket read
    if( $success == $READ_LENGTH ) {                            # Attempt socket read
      $$data .= $minibuf;
    BUFFER: while() {
        $success = sysread( $handle, $minibuf, $READ_LENGTH );  # Read while bytes available
        if( ( ! defined $success ) || ( $success == 0 ) ) {
          last BUFFER;
        }
        if( $success == $READ_LENGTH ) {                        # Attempt socket read
          $$data .= $minibuf;
        } else {
          $$data = undef;                                       # Undefine data scalar
          return(0);                                            # Return on socket read error
        }
      }
    } else {
      $$data = undef;                                           # Clear data buffer reference
      return(0);
    }
  }
  return( length( $$data ) );                                   # Return number of bytes read
}


sub put {
  # This method writes an arbitrary number of bytes to a socket.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Data => \$scalar
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $Protocol->put( Data => \$scalar );
  my $Protocol = shift;                                         # Get Protocol object
  my %args     = @_;                                            # Get parameters
  my $data     = $args{Data};
  my $handle   = undef;
  if( $Protocol->{Client} ) {
    $handle = $Protocol->{ClientHndl};
  } else {
    $handle = $Protocol->{ServerHndl};
  }
  my $success = syswrite( $handle, $$data, length( $$data ) );  # Attempt to write data
  if( $success == length( $$data ) ) {                          # Test for success
    return( $success );                                         # Return number of bytes written
  } else {                                                      # Failed write on socket
    return(0);                                                  # Return on error
  }
}


sub disconnect {
  # This method closes a socket on a socket object.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Address => $address
  #              Port    => $port
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $Protocol->disconnect();
  my $Protocol = shift;                        # Get Protocol object
  return( close( $Protocol->{ClientHndl} ) );  # Return code from function
}


sub ready {
  # This method does a select(2) on a socket with a specified timeout.
  # Parameters Required:
  #    object
  #    hash    {
  #                 Try => $tries
  #            }
  # Returned:
  #    boolean
  # Example
  #    $Protocol->ready();
  my $Protocol = shift;                                     # Get Protocol object
  my %args     = @_;                                        # Get arguments
  my $handle   = undef;
  if( $Protocol->{Client} ) {
    $handle = $Protocol->{ClientHndl};
  } else {
    $handle = $Protocol->{ServerHndl};
  }
  my $oldHndl = select();                                   # Save default file handle
  select( $handle );                                        # Select socket as default file handle
  my $count   = 0;
  my $success = 0;                                          # Positive value indicates that socket is ready
  while( $count < $args{Try} ) {                            # Try to read from socket
    my $checkSocket = select( undef, undef, undef, 0.01 );  # Check if socket is ready
    if( $checkSocket == 0 ) {
      $count = $args{Try} + 10;
      $success++;
    }
    $count++;
  }
  select( $oldHndl );                                       # Restore previous default file handle
  return( $success );                                       # Return success code
}


sub ready2 {
  # This method does a select(2) on a socket with a specified timeout.
  # Parameters Required:
  #    object
  # Returned:
  #    boolean
  # Example
  #    $Protocol->ready();
  my $Protocol = shift;                            # Get Protocol object
  my %args     = @_;                               # Get arguments
  my $handle   = undef;
  if( $Protocol->{Client} ) {
    $handle = $Protocol->{ClientHndl};
  } else {
    $handle = $Protocol->{ServerHndl};
  }
  my $oldHndl = select();                          # Save default file handle
  select( $handle );                               # Select socket as default file handle
  my $flag = select( undef, undef, undef, 0.01 );
  select( $oldHndl );                              # Restore previous default file handle
  return( $flag );
}



sub _address {
  # This method interprets the hostname-style address into a packed format.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    boolean
  # Example:
  #    $Protocol->reaper();
  my $Protocol = shift;                               # Get Protocol object
  my %args     = @_;                                  # Get argments
  my $packed   = undef;
 SWITCH: for( $args{Address} ) {                    # Determine address format
  m/^\d+\.\d+\.\d+\.\d+$/ && do {                   # Dotted quad
    my @quad = split( /\./, $args{Address} );
    $packed  = pack( "c4", @quad );
    last SWITCH;
  };
  m// && do {                                       # Hostname-style
    my ( undef,
       undef,
       undef,
       $length,
       @addrs ) = gethostbyname( $args{Address} );  #
    $packed = $addrs[0];
    last SWITCH;
  };
  }
  return( $packed );
}



sub reaper {
  # This method harvests zombie processes.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    boolean
  # Example:
  #    $Protocol->reaper();
  my $Protocol = shift;                                # Get Protocol object
  foreach my $process ( @{$Protocol->{Processes}} ) {  # Iterate over process list
    waitpid( $process, 0 );
  }
  return(1);
}


sub DESTROY {
  # This method is the object destructor for this class.
  # The object destructor ensures that all zombie processes
  # created by this class are cleaned up properly.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Protocol = shift;  # Get Protocol object
  my %args     = @_;     # Get arguments
  $Protocol->reaper();   # Harvest zombie processes
  return(1);
}


sub END {
  # This method is the class destructor for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Protocol = shift;                              # Get Protocol object
  my %args     = @_;                                 # Get arguments
  foreach my $ref ( @NetSoup::Protocol::Objects ) {  # Iterate over class objects
    $ref->reaper();                                  # Harvest zombie processes
  }
  return(1);
}
