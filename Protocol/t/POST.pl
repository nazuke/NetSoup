#!/usr/local/bin/perl -w
use NetSoup::Protocol::HTTP;
my $HTTP     = NetSoup::Protocol::HTTP->new( Debug => 1 );
my $Document = $HTTP->post( URL         => "http://localhost/cgi-bin/CGI.cgi",
                            ContentType => "application/x-www-form-urlencoded",
                            Content     => 'name=roger' );
print( $Document->body() );
exit(0);
