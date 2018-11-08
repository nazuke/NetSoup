#!/usr/local/bin/perl -w
#
#   NetSoup::Packages::HyperGlot::bin::HyperGlotD.pl v00.00.01a 12042000
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
#   Description: This Perl 5.0 application is a forking Internet server
#                implementing the NetSoup GTP (Glossary Translation Protocol)
#                network protocol.


use strict;
use POSIX;
use NetSoup::Files::Directory;
use NetSoup::Packages::HyperGlot::lib::MkMap;
use NetSoup::Persistent::Store;
use NetSoup::Protocol;


my $SIZE    = -s $0;                        # Stores size of this script
my $QUIT    = 0;                            # Set to true to quit by signal handler
my $RESTART = 0;                            # Set to true to force a server restart
my $eCode   = 0;                            # Holds exit code of server
if( fork ) {                                # Spawn new process...
   exit();                                   # ...and exit parent
} else {
   chdir( "/" );
  #close( STDIN );
  #close( STDOUT );
  #close( STDERR );
  POSIX::setsid();
  %SIG = ( TERM => sub { $QUIT = 1 },       # Install signal handlers
           HUP  => sub { $QUIT    = 1;
                         $RESTART = 1 } );
  mkmap();                                  # Begin MkMap loop
  server() || exit(-1);                     # Begin server loop
  $eCode = quit();
  $eCode = reload() if( $RESTART );
}
exit( $eCode );


sub mkmap {
  # This function manages the project databases.
  # Calls:
  #    none
  # Parameters Required:
  #    socket
  # Result Returned:
  #    boolean
  if( ! fork ) {
    while() {
      my $MkMap     = NetSoup::Packages::HyperGlot::lib::MkMap->new();
      my $DBPath    = $MkMap->getConfig( Key => "HyperGlotProjPath" ) . "/Catalog";  # Build HyperGlot DB pathname
      my $Sites     = $MkMap->getConfig( Key => "HyperGlotProjPath" ) . "/Sites";
      my $Directory = NetSoup::Files::Directory->new();
      my %DB        = ();                                                            # Hash holds HyperGlot site map database
      tie %DB, "NetSoup::Persistent::Store", Pathname => $DBPath;                    # Bind hash to database file
      $Directory->descend( Pathname    => $Sites,
                           Recursive   => 0,
                           Directories => 1,
                           Callback    => sub {
                             my $pathname = shift;
                             $MkMap->mkmap( DB       => \%DB,
                                            Pathname => $pathname );
                           } );
      sleep(60);
    }
    exit(0);
  }
  return(1);
}


sub server {
  # This function is the main server loop.
  # Calls:
  #    none
  # Parameters Required:
  #    socket
  # Result Returned:
  #    boolean
  my $server = NetSoup::Protocol->new();                          # Get new socket protocol object
  my $port   = $server->getConfig( Key => "HyperGlotServPort" );  # Obtain port number configuration
  if( $server->server( Port => $port ) ) {                        # Configure socket as server
    $server->loop( Callback => sub { service( $server ) },        # Enter main server loop
                   Args     => {},
                   Fork     => 1,
                   Quit     => \$QUIT );
  } else {
    return(0);
  }
  return(1);
}


=pod

  Get Service Type:

  ....List Projects
  ........Return List of Active Projects


  ....List Project Files
  ........Return List of Selected Project Files


  ....Fetch File Translation Table
  ........Fetch Document Data
  ........Perform GTP Lookup on Document Data
  ........Return Translation Table


  ....Store File Translation Table
  ........Perform GTP Store with Translated Document Data
  ........Update Document Data with Translation

=cut


sub service {
  # This function services an incoming client request.
  # Calls:
  #    none
  # Parameters Required:
  #    socket
  # Result Returned:
  #    boolean
  my $Socket  = shift;                # Get server object
  my $service = "";                   # Holds service-type string
  $Socket->get( Data   => \$service,  # Fetch service type header
                Length => 8 );
  $Socket->debug( $service );         # DEBUG
 SERVICE: for( $service ) {
    m/NUMBPROJ/i && do {
      numbproj( $Socket );
      last SERVICE;
    };
    m/LISTPROJ/i && do {
      listproj( $Socket );
      last SERVICE;
    };
    m/LISTDOCS/ && do {
      listdocs( $Socket );
      last SERVICE;
    };
    m/FTCHTABL/ && do {
      ftchtabl( $Socket );
      last SERVICE;
    };
    m/STORTABL/ && do {
      stortabl( $Socket );
      last SERVICE;
    };
  }
  $Socket->disconnect();              # End transaction
  exit(0);
}


sub numbproj {
  # This function returns the number of HyperGlot projects available to this server.
  # Returns:
  #   int
  my $Socket    = shift;
  my $MkMap     = NetSoup::Packages::HyperGlot::lib::MkMap->new();
  my $DBPath    = $MkMap->getConfig( Key => "HyperGlotProjPath" ) . "/Catalog";  # Build HyperGlot DB pathname
  my $Sites     = $MkMap->getConfig( Key => "HyperGlotProjPath" ) . "/Sites";
  my $number    = -1;
  my %DB        = ();                                                            # Hash holds HyperGlot site map database
  tie %DB, "NetSoup::Persistent::Store", Pathname => $DBPath;                    # Bind hash to database file
  foreach my $key ( keys %DB ) {
    $number++;
    print( STDERR "$key\t$number\n" );
  }
  $number = chr( $number );
  $Socket->put( Data => \$number );
  return(1);
}


sub listproj {
  # This function lists the HyperGlot projects available to this server.
  # Returns:
  #   project_name\n
  #   ..
  my $Socket    = shift;
  my $Directory = NetSoup::Files::Directory->new();
  my $projpath  = $Socket->getConfig( Key => "HyperGlotProjPath" );  # Get HyperGlot project directory
  my @list      = ();
  $Directory->descend( Pathname    => "$projpath/Sites",
                       Recursive   => 0,
                       Files       => 0,
                       Directories => 1,
                       Callback => sub {
                         my $project = shift;
                         $project    = $Directory->filename( Pathname => $project );
                         push( @list, "$project\n" );
                       } );
  foreach my $project ( @list ) {
    $Socket->put( Data => \$project );
  }
  return(1);
}


sub listdocs {
  # This function lists the documents in an available HyperGlot project.
  my $Socket = shift;
  return(1);
}


sub ftchtabl {
  # This function fetches a document from a project
  # and executes a GTP query on the source strings.
  my $Socket = shift;
  return(1);
}


sub stortabl {
  # This function stores a translated document into a project
  # and executes a GTP query on the newly translated strings.
  my $Socket = shift;
  return(1);
}




sub quit {
  # This function is invoked at server shutdown time.
  return(1);
}


sub reload {
  # This function forces a re-exec of the program.
  if( $SIZE != -s $0 ) {  # Check size of script file
  } else {
    exec( $0 );           # Exec into a new process
  }
  return(-1);
}
