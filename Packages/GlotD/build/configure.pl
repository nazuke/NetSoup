#!/usr/local/bin/perl -w
# This is invoked by "./configure"


use strict;
%main::Config = (                         # This hash is mirrored in the Config.pm module
                 GlotDInstalled => [],    # True if GlotD installed
                 GlotServPort   => [],    # Port number of the glossary database server
                 GlotServUser   => [],    # User to run glossary server as
                 GlotUseServ    => [],    # Use glossary server daemon
                 GlotServAddr   => [],    # IP address or hostname of the glossary database server
                 GlotClientPort => [],    # Port number of the glossary database server
                );
print( STDOUT "**** Configuring NetSoup GlotD for Perl 5.0 ****\n" );


##############################################################################
#### BEGIN Configure GlotD Installation ######################################
GlotDInstalled: {
  print( STDOUT "The GlotD daemon provides access to translation glossaries across the network.\n" );
  print( STDOUT "You only need to install GlotD on a single machine on your network.\n" );
  print( STDOUT "You also need to decide if you want other NetSoup programs to be able\n" );
  print( STDOUT "to connect to this daemon.\n\n" );
  prompt( "Install the GlotD daemon on this machine? [y/N]:" );
  my $default = 0;
  my $value   = <STDIN>;
  chomp( $value );
  if( length( $value ) > 0 ) {
    if( uc( $value ) =~ m/^y$/i ) {
      $main::Config{GlotDInstalled} = [ 0, 1 ];
    } else {
      $main::Config{GlotDInstalled} = [ 0, 0 ];
    }
  } else {
    $main::Config{GlotDInstalled} = [ 0, $default ];
  }
}
#### END   Configure GlotD Installation ######################################
#-----------------------------------------------------------------------------


##############################################################################
#### BEGIN Configure Glossary Server Port ####################################
GLOTSERVPORT: {
  my $default = 1701;
  if( $main::Config{GlotDInstalled}->[1] ) {
    prompt( "Please enter the port number for the glossary server [1701]:" );
    my $value = <STDIN>;
    chomp( $value );
    if( length( $value ) > 0 ) {
      $main::Config{GlotServPort} = [ 0, $value ];
    } else {
      $main::Config{GlotServPort} = [ 0, $default ];
    }
  } else {
    $main::Config{GlotServPort} = [ 0, $default ];
  }
}
#### END   Configure Glossary Server Port ####################################
#-----------------------------------------------------------------------------


##############################################################################
#### BEGIN Configure Glossary Server User ID #################################
GLOTSERVUSER: {
  my $default  = "nobody";
  my $makefile = "";
  if( $main::Config{GlotDInstalled}->[1] ) {
    prompt( "User to run Glossary Server as [nobody]:" );
    my $value = <STDIN>;
    chomp( $value );
    if( length( $value ) > 0 ) {
      $main::Config{GlotServUser} = [ 0, $value ];
    } else {
      $main::Config{GlotServUser} = [ 0, $default ];
    }
  } else {
    $main::Config{GlotServUser} = [ 0, $default ];
  }
  if( open( IN, "./Packages/GlotD/Makefile.in" ) ) {
    while( <IN> ) {
      $makefile .= $_;
    }
    close( IN );
  } else {
    print( STDOUT "Cannot open Packages/GlotD/Makefile.in\n" );
    exit(0);
  }
  $makefile =~ s/__USERNAME__/$main::Config{GlotServUser}->[1]/gs;
  if( open( OUT, ">./Packages/GlotD/Makefile" ) ) {
    print( OUT $makefile );
    close( OUT );
  } else {
    print( STDOUT "Cannot write Packages/GlotD/Makefile\n" );
    exit(0);
  }
}
#### END   Configure Glossary Server User ID #################################
#-----------------------------------------------------------------------------




##############################################################################
#### BEGIN Configure Use A Glossary Server Daemon ############################
USEGLOTSERV: {
  prompt( "Do you want NetSoup clients to use a glossary server daemon ? [Y/n]:" );
  my $default = 1;
  my $value   = <STDIN>;
  chomp( $value );
  if( length( $value ) > 0 ) {
    if( uc( $value ) =~ m/^y$/i ) {
      $main::Config{GlotUseServ} = [ 0, 1 ];
    } else {
      $main::Config{GlotUseServ} = [ 0, 0 ];
    }
  } else {
    $main::Config{GlotUseServ} = [ 0, $default ];
  }
}
#### END   Configure Use A Glossary Server Daemon ############################
#-----------------------------------------------------------------------------


##############################################################################
#### BEGIN Configure Glossary Server Address #################################
GLOTSERVADDR: {
  my $default = `hostname` || "localhost";
  chomp( $default );
  if( $main::Config{GlotUseServ} ) {
    prompt( "Please enter the IP address/hostname for the glossary server [$default]:" );
    my $value = <STDIN>;
    chomp( $value );
    if( length( $value ) > 0 ) {
      $main::Config{GlotServAddr} = [ 0, $value ];
    } else {
      $main::Config{GlotServAddr} = [ 0, $default ];
    }
  } else {
    $main::Config{GlotServAddr} = [ 0, $default ];
  }
}
#### END   Configure Glossary Server Address #################################
#-----------------------------------------------------------------------------


##############################################################################
#### BEGIN Configure Glossary Client Port ####################################
GLOTCLIENTPORT: {
  my $default = $main::Config{GlotServPort}->[1] || 1701;
  if( $main::Config{GlotUseServ} ) {
    prompt( "Please enter the port number for the glossary server [$default]:" );
    my $value = <STDIN>;
    chomp( $value );
    if( length( $value ) > 0 ) {
      $main::Config{GlotClientPort} = [ 0, $value ];
    } else {
      $main::Config{GlotClientPort} = [ 0, $default ];
    }
  } else {
    $main::Config{GlotClientPort} = [ 0, $default ];
  }
}
#### END   Configure Glossary Client Port ####################################
#-----------------------------------------------------------------------------


if( ! cache() ) {
  print( STDOUT qq(Error: Cannot open "config.cache" file!\n) );
  exit(-1);
}
print( STDOUT qq(GlotD Configuration Complete\n\n) );
exit(0);


sub cache {
  open( OUT, ">>./config.cache" ) || return(0);
  foreach my $key ( keys %main::Config ) {
    print( OUT "$key\t$main::Config{$key}->[0]\t$main::Config{$key}->[1]\n" );
  }
  close( OUT );
  return(1);
}


sub prompt { print( STDOUT (shift) . " " ) }
