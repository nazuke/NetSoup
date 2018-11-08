#!/usr/local/bin/perl -w
# This is invoked by "NetSoup/configure"


use strict;
use Config;
%main::_Config = (                     # This hash is mirrored in the Config.pm module
                  LibPath      => [],  # Location of libraries directory
                  BinPath      => [],  # Location of binaries directory
                  TmpPath      => [],  # Location of tmp files directory
                  LogPath      => [],  # Location of log files directory
                  StorePath    => [],  # Location of "Store" database files
                  XMLStorePath => [],  # Location of "XMLStore" database files
                  GlotDBPath   => [],  # Location of language glossary database files
                 );
print( STDOUT "**** Configuring NetSoup for Perl 5.0 ****\n" );


##############################################################################
#### BEGIN Configure /usr/local/lib/perl/.. Pathname #########################
BinPath: {
  my $default = $Config{'installsitelib'};
  prompt( "Where would you like NetSoup to be installed? [$default]:" );
  my $value   = <STDIN>;
  chomp( $value );
  if( length( $value ) > 0 ) {
    $main::_Config{LibPath} = [ "dir", $value ];
  } else {
    $main::_Config{LibPath} = [ "dir", $default ];
  }
}
#### END   Configure /usr/local/lib/perl/.. Pathname #########################
#-----------------------------------------------------------------------------


##############################################################################
#### BEGIN Configure /usr/local/bin Pathname #################################
BinPath: {
  prompt( "Where would you like the NetSoup binaries installed? [/usr/local/bin]:" );
  my $default = "/usr/local/bin";
  my $value   = <STDIN>;
  chomp( $value );
  if( length( $value ) > 0 ) {
    $main::_Config{BinPath} = [ "dir", $value ];
  } else {
    $main::_Config{BinPath} = [ "dir", $default ];
  }
}
#### END   Configure /usr/local/bin Pathname #################################
#-----------------------------------------------------------------------------


##############################################################################
#### BEGIN Configure /tmp Pathname ###########################################
TmpPath: {
  prompt( "Please enter the pathname for the tmp directory [/tmp]:" );
  my $default = "/tmp";
  my $value   = <STDIN>;
  chomp( $value );
  if( length( $value ) > 0 ) {
    $main::_Config{TmpPath} = [ "dir", $value ];
  } else {
    $main::_Config{TmpPath} = [ "dir", $default ];
  }
}
#### END   Configure /tmp Pathname ###########################################
#-----------------------------------------------------------------------------


##############################################################################
#### BEGIN Configure Log Pathname ############################################
LOGPATH: {
  prompt( "Please enter the pathname for the log files [/var/log]:" );
  my $default = "/var/log";
  my $value   = <STDIN>;
  chomp( $value );
  if( length( $value ) > 0 ) {
    $main::_Config{LogPath} = [ "dir", $value ];
  } else {
    $main::_Config{LogPath} = [ "dir", $default ];
  }
}
#### END   Configure Log Pathname ############################################
#-----------------------------------------------------------------------------


##############################################################################
#### BEGIN Configure Store Pathname ##########################################
STOREPATH: {
  prompt( "Please enter the pathname for the Store databases [/usr/local/lib/NetSoup/Store]:" );
  my $default = "/usr/local/lib/NetSoup/Store";
  my $value   = <STDIN>;
  chomp( $value );
  if( length( $value ) > 0 ) {
    $main::_Config{StorePath} = [ "dir", $value ];
  } else {
    $main::_Config{StorePath} = [ "dir", $default ];
  }
}
#### END   Configure Store Pathname ##########################################
#-----------------------------------------------------------------------------


##############################################################################
#### BEGIN Configure XMLStore Pathname ##########################################
STOREPATH: {
  prompt( "Please enter the pathname for the XMLStore\\\ndatabases [/usr/local/lib/NetSoup/XMLStore]:" );
  my $default = "/usr/local/lib/NetSoup/XMLStore";
  my $value   = <STDIN>;
  chomp( $value );
  if( length( $value ) > 0 ) {
    $main::_Config{XMLStorePath} = [ "dir", $value ];
  } else {
    $main::_Config{XMLStorePath} = [ "dir", $default ];
  }
}
#### END   Configure Store Pathname ##########################################
#-----------------------------------------------------------------------------


##############################################################################
#### BEGIN Configure Glossary Pathname #######################################
GlotDBPath: {
  prompt( "Please enter the pathname for the glossary files [/usr/local/lib/NetSoup/Glot]:" );
  my $default = "/usr/local/lib/NetSoup/Glot";
  my $value   = <STDIN>;
  chomp( $value );
  if( length( $value ) > 0 ) {
    $main::_Config{GlotDBPath} = [ "dir", $value ];
  } else {
    $main::_Config{GlotDBPath} = [ "dir", $default ];
  }
}
#### END   Configure Glossary Pathname #######################################
#-----------------------------------------------------------------------------


if( ! cache() ) {
  print( STDOUT qq(Error: Cannot open "config.cache" file!\n) );
  exit(-1);
}
print( STDOUT qq(NetSoup Configuration Complete\n\n) );
exit(0);


sub cache {
  open( OUT, ">./config.cache" ) || return(0);
  foreach my $key ( keys %main::_Config ) {
    print( OUT "$key\t$main::_Config{$key}->[0]\t$main::_Config{$key}->[1]\n" );
  }
  close( OUT );
  return(1);
}


sub prompt { print( STDOUT (shift) . " " ) }
