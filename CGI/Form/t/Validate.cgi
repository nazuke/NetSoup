#!/usr/local/bin/perl -w

use NetSoup::CGI::Form::Validate;

my $Validate = NetSoup::CGI::Form::Validate->new();
print( "Content-type: text/html\r\n\r\n" );
print( "<p>" . $Validate->validate( Pathname => "example.xml" ) . "</p>" );
exit(0);
