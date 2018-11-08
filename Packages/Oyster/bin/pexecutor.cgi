#!/usr/local/bin/perl -w -I/usr/local/apache/lib -I/usr/lib/perl5/site_perl/5.005/i386-linux

use strict;
if( ! exists $ENV{MOD_PERL} ) {
	use NetSoup::Oyster::Box;
	use NetSoup::Oyster::Executor;
}

{
	close( STDERR );
	open( STDERR, ">>/tmp/pexecutor.log" );
	my $Box    = NetSoup::Oyster::Box->new();
	my $Script = $Box->script();
	if( open( SCRIPT, $Script ) ) {
		my $XML      = join( "", <SCRIPT> );
		my $Executor = NetSoup::Oyster::Executor->new( Debug    => 1,
																									 Beautify => 0 );
		my $Document = $Executor->execute( XML => \$XML );
		my $HTML     = $Document->result();
		if( $Document->location() ) {
			if( $ENV{HTTP_USER_AGENT} =~ m/ozilla/i ) {
				my $location = $Document->location();
				print( "Content-type: " . $Document->type() . "\r\n" );
				print( "Cache-control: no-cache\r\n" );
				print( "\r\n" );
				print( qq(<html>
									<head>
									<meta http-equiv="Refresh" content="0; URL=$location">
									</head>
									<body>
									</body>
									</html>) );
			} else {
				print( "Location: " . $Document->location() . "\r\n\r\n" );
			}
		} else {
			print( "Content-type: " . $Document->type() . "\r\n" );
			print( "Cache-control: no-cache\r\n" );
			print( "\r\n" );
			print( $HTML );
		}
		close( SCRIPT );
	} else {
		print( "Content-type: text/html\r\n" );
		print( "\r\n" );
		print( qq(<h1>Error</h1><p>Could not find script "$Script"</p>) );
	}
}
