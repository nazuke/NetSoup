#!/usr/local/bin/perl -w -I/usr/local/apache/lib -I/usr/lib/perl5/site_perl/5.005/i386-linux

use strict;
use Autonomy::DRE::Query::HTTP;
use NetSoup::Protocol::HTTP;
use constant MODE => "single";

my $HTML = join( "", <DATA> );
my $HTTP = Autonomy::DRE::Query::HTTP->new( Hostname => "193.115.251.53",
																						Port     => 60000,
																						Caching  => 0,
																						Period   => 60 * 60 * 24 );
print( "Content-type: text/html\r\n\r\n" );
my $URI = $ENV{REQUEST_URI};
$URI    =~ s+^/autonomy/+/autonomy_v2/+i;
$HTTP->query( QMethod   => "s",
							#QueryText => NetSoup::Protocol::HTTP->new()->escape( URL => "http://$ENV{HTTP_HOST}$URI" ),
							QueryText => "http://$ENV{HTTP_HOST}$URI",
							QNum      => 6,
							Database  => "General+PressReleases",
							XOptions  => "useurl" );				
SWITCH: for( MODE ) {
	m/single/ && do {
		my $URL = $HTTP->field( Index => 1, Field => "doc_name" ) || "http://www.autonomy.com/";
		$HTML   =~ s/__URL__/$URL/gs;
		print( $HTML );
		last SWITCH;
	};
	m/multiple/ && do {
		for( my $i = 1 ; $i <= $HTTP->numhits() ; $i++ ) {
			my $URL = $HTTP->field( Index => 1, Field => "doc_name" );
			my $weight = $HTTP->field( Index => $i, Field => "doc_weight" );
			print( qq(<p>$weight <a href="$URL">$URL</a></p>\n) );
		}
		last SWITCH;
	};
}
exit(0);


__DATA__


<html>
	<head>
		<meta http-equiv="Refresh" content="0;URL=__URL__">
		<script language="JavaScript">
			<!--
	    window.location = "__URL__";
			//-->
		</script>
	</head>
	<body>
	</body>
</html>
