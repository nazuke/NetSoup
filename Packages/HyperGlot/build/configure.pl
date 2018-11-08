#!/usr/local/bin/perl -w
# This is invoked by "./configure"


use strict;
%main::Config = (                                  # This hash is mirrored in the Config.pm module
                 HyperGlotInstalled => [ 0, 0 ],   # True if HyperGlot installed on host
                 HyperGlotHostname  => [ 0, "" ],  # Hostname of HyperGlot machine
                 HyperGlotServPort  => [ 0, 0 ],   # Port number of HyperGlot server
                 HyperGlotCGIPath   => [ 0, "" ],  # Pathname for HyperGlot CGI scripts
                 HyperGlotHtmlPath  => [ 0, "" ],  # Pathname for HyperGlot Html documents
                 HyperGlotVirtPath  => [ 0, "" ],  # Pathname for Apache virtual web sites
                 HyperGlotProjPath  => [ 0, "" ],  # Pathname for HyperGlot projects
                );
print( STDOUT "**** Configuring NetSoup HyperGlot for Perl 5.0 ****\n" );


##############################################################################
#### BEGIN Configure Install HyperGlot #######################################
HyperGlotInstalled: {
  print( STDOUT "The HyperGlot package is a client/server system for carrying out web site\n" );
  print( STDOUT "translation and internationalisation.\n" );
  print( STDOUT "HyperGlot only needs to be installed as a server, client access is via\n" );
  print( STDOUT "Netscape Navigator compatible web browsers.\n\n" );
  prompt( "Install HyperGlot on this machine? [y/N]:" );
  my $default = 0;
  my $value   = <STDIN>;
  chomp( $value );
  if( length( $value ) > 0 ) {
    if( uc( $value ) =~ m/^y$/i ) {
      $main::Config{HyperGlotInstalled} = [ 0, 1 ];
    } else {
      $main::Config{HyperGlotInstalled} = [ 0, 0 ];
    }
  } else {
    $main::Config{HyperGlotInstalled} = [ 0, $default ];
  }
}
#### END   Configure Install HyperGlot #######################################
#-----------------------------------------------------------------------------


##############################################################################
#### BEGIN Configure HyperGlot Hostname ######################################
HyperGlotHostname: {
  last HyperGlotHostname if( ! $main::Config{HyperGlotInstalled}->[1] );
  my $default = `hostname` || "localhost";
  chomp( $default );
  prompt( "Please enter the hostname for the HyperGlot machine [$default]:" );
  my $value = <STDIN>;
  chomp( $value );
  if( length( $value ) > 0 ) {
    $main::Config{HyperGlotHostname} = [ 0, $value ];
  } else {
    $main::Config{HyperGlotHostname} = [ 0, $default ];
  }
}
#### END   Configure HyperGlot Hostname ######################################
#-----------------------------------------------------------------------------


##############################################################################
#### BEGIN Configure HyperGlot Server Port Number ############################
HyperGlotServPort: {
  last HyperGlotServPort if( ! $main::Config{HyperGlotInstalled}->[1] );
  my $default = 1702;
  chomp( $default );
  prompt( "Please enter port number for the HyperGlot server [$default]:" );
  my $value = <STDIN>;
  chomp( $value );
  if( length( $value ) > 0 ) {
    $main::Config{HyperGlotServPort} = [ 0, $value ];
  } else {
    $main::Config{HyperGlotServPort} = [ 0, $default ];
  }
}
#### END   Configure HyperGlot Server Port Number ############################
#-----------------------------------------------------------------------------


##############################################################################
#### BEGIN Configure HyperGlot CGI Pathname ##################################
HyperGlotCGIPath: {
  last HyperGlotCGIPath if( ! $main::Config{HyperGlotInstalled}->[1] );
  my $default = "/home/httpd/cgi-bin";
  prompt( "Please enter the path where the HyperGlot CGI scripts \\\nshould be installed [$default]:" );
  my $value = <STDIN>;
  chomp( $value );
  if( length( $value ) > 0 ) {
    $main::Config{HyperGlotCGIPath} = [ "dir", $value ];
  } else {
    $main::Config{HyperGlotCGIPath} = [ "dir", $default ];
  }
}
#### END   Configure HyperGlot CGI Pathname ##################################
#-----------------------------------------------------------------------------


##############################################################################
#### BEGIN Configure HyperGlot Html Pathname #################################
HyperGlotHTMLPath: {
  last HyperGlotHTMLPath if( ! $main::Config{HyperGlotInstalled}->[1] );
  my $default = "/home/httpd/htdocs";
  prompt( "Please enter the path where the HyperGlot Html documents \\\nshould be installed [$default]:" );
  my $value = <STDIN>;
  chomp( $value );
  if( length( $value ) > 0 ) {
    $main::Config{HyperGlotHtmlPath} = [ "dir", $value ];
  } else {
    $main::Config{HyperGlotHtmlPath} = [ "dir", $default ];
  }
}
#### END   Configure HyperGlot Html Pathname #################################
#-----------------------------------------------------------------------------


##############################################################################
#### BEGIN Configure Apache Virtual Hosts Pathname ###########################
HyperGlotVirtPath: {
  last HyperGlotVirtPath if( ! $main::Config{HyperGlotInstalled}->[1] );
  print( STDOUT "\nEach HyperGlot web site project is stored as a separate virtual host in the\n" );
  print( STDOUT "Apache hypertext documents hierarchy. The NetSoup installer will install the\n" );
  print( STDOUT "necessary directory structure, but your Webmaster will need to configure the\n" );
  print( STDOUT "virtual hosts manually.\n" );
  print( STDOUT "Consult the HyperGlot and Apache documentation for further information.\n\n" );
  my $default = $main::Config{HyperGlotHtmlPath}->[1] . "/virtual";
  prompt( "Please enter the path where the Apache Virtual Hosts \\\nwill be installed [$default]:" );
  my $value = <STDIN>;
  chomp( $value );
  if( length( $value ) > 0 ) {
    $main::Config{HyperGlotVirtPath} = [ "dir", $value ];
  } else {
    $main::Config{HyperGlotVirtPath} = [ "dir", $default ];
  }
}
#### END   Configure Apache Virtual Hosts Pathname ###########################
#-----------------------------------------------------------------------------


##############################################################################
#### BEGIN Configure HyperGlot Projects Pathname #############################
HyperGlotProjPath: {
  last HyperGlotProjPath if( ! $main::Config{HyperGlotInstalled}->[1] );
  print( STDOUT "\nHyperGlot requires a directory to store project information and\n" );
  print( STDOUT "site trees. This directory will also need to be accessible to personnel\n" );
  print( STDOUT "working on HyperGlot projects.\n\n" );
  my $default = "/usr/local/HyperGlot";
  prompt( "Please enter the path to install the HyperGlot projects directory [$default]:" );
  my $value = <STDIN>;
  chomp( $value );
  if( length( $value ) > 0 ) {
    $main::Config{HyperGlotProjPath} = [ "dir", $value ];
  } else {
    $main::Config{HyperGlotProjPath} = [ "dir", $default ];
  }
}
#### END   Configure HyperGlot Projects Pathname #############################
#-----------------------------------------------------------------------------


if( ! cache() ) {
  print( STDOUT qq(Error: Cannot open "config.cache" file!\n) );
  exit(-1);
}
print( STDOUT qq(HyperGlot Configuration Complete\n\n) );
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
