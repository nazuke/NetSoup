#!/usr/local/bin/perl -w -I/usr/local/apache_1.3.20/lib -I/usr/lib/perl5/site_perl/5.005/i386-linux

use strict;
use NetSoup::CGI;
use NetSoup::Oyster::Component::Calendar;

my $year     = NetSoup::CGI->new()->field( Name => "year" ) || time;
my $Calendar = NetSoup::Oyster::Component::Calendar->new();
my $Year     = $Calendar->year( Time => $year );
print( STDOUT "Content-Type: text/html\r\n\r\n" );
print( STDOUT $Year->XML() );
exit(0);
