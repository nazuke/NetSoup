#!/usr/local/bin/perl -w

package NetSoup::Apache::MySQL::Pool;
use strict;
use Apache;
use Apache::Constants qw( :http :response );
use DBI;
use NetSoup::Apache;
use NetSoup::Util::Time;
@NetSoup::Apache::MySQL::Pool::ISA     = qw( NetSoup::Apache NetSoup::Util::Time );
%NetSoup::Apache::MySQL::Pool::GLOBALS = ( EXIT_FLAG => 0 );
%NetSoup::Apache::MySQL::Pool::Handles = ();
1;


sub child_exit_handler {
  my $r = shift;
  if( ! $NetSoup::Apache::MySQL::Pool::GLOBALS{EXIT_FLAG} ) {
    $NetSoup::Apache::MySQL::Pool::GLOBALS{EXIT_FLAG} = 1;
    if( $r->dir_config( "MYSQL_HOST" ) && $NetSoup::Apache::MySQL::Pool::GLOBALS{DBH} ) {
      if( $NetSoup::Apache::MySQL::Pool::GLOBALS{DBH}->disconnect() ) {
        $r->warn( "Database Disconnection Successful" );
      } else {
        $r->warn( "Database Disconnection Failed" );
        return( SERVER_ERROR );
      }
    }
  }
  return( OK );
}


sub dbh {
  # Return open MySQL database handle.
  my $Framework = shift;
  my $r         = shift;
  my $host = $r->dir_config( "MYSQL_HOST" );
  if( ! defined $NetSoup::Apache::MySQL::Pool::GLOBALS{$host} ) {
    $NetSoup::Apache::MySQL::Pool::GLOBALS{$host} = DBI->connect( "DBI:mysql:database=;host=$host",
                                                                  $r->dir_config( "MYSQL_USER" ),
                                                                  $r->dir_config( "MYSQL_PASS" ) );
  }
  return( $NetSoup::Apache::MySQL::Pool::GLOBALS{DBH} );
}
