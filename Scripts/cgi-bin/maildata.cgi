#!/usr/local/bin/perl -w


use NetSoup::CGI;
use NetSoup::Protocol::Mail;


my $CGI         = NetSoup::CGI->new();
my $Recipient   = $CGI->field( Name   => "RECIPIENT",    Format => "ascii" );
my $CC          = $CGI->field( Name   => "CC",           Format => "ascii" );
my $From        = $CGI->field( Name   => "FROM",         Format => "ascii" );
my $Subject     = $CGI->field( Name   => "SUBJECT",      Format => "ascii" );
my $ContentType = $CGI->field( Name   => "CONTENT-TYPE", Format => "ascii" );
my $Data        = $CGI->field( Name   => "DATA",         Format => "ascii" );
if ( ! checkdomain() ) {
  print( "Content-type: text/html\r\n\r\n" );
  print( "<h1>Invalid Domain</h1>" );
  exit(0);
}
$CC         = "" if( ! defined $CC );
my $success = NetSoup::Protocol::Mail->mail( To          => $Recipient,
																						 CC          => $CC,
																						 From        => $From,
																						 Subject     => $Subject,
																						 ContentType => $ContentType,
																						 Message     => $Data );
if ( $success ) {
  print( "Location: " . $CGI->field( Name   => "SUCCESSURL",
																		 Format => "ascii" ) . "\r\n\r\n" );
} else {
  print( "Location: " . $CGI->field( Name   => "ERRORURL",
																		 Format => "ascii" ) . "\r\n\r\n" );
}
exit(0);


sub checkdomain {
  if ( -e "mailhtml.domains" ) {
    my $check   = 0;
    my @domains = ();
    open( DOMAINS, "mailhtml.domains" ) || return(0);
    while ( <DOMAINS> ) {
      chomp;
      push( @domains, $_ );
    }
    close( DOMAINS );
    foreach my $domain ( @domains ) {
      $check++ if( $Recipient =~ m/\@$domain$/i );
    }
    return(0) if( ! $check );
    if ( ! defined $CC ) {
      $check = 0;
      foreach my $domain ( @domains ) {
				$check++ if( $CC =~ m/\@$domain$/i );
      }
      return(0) if( ! $check );
    }
  }
  return(1);
}
