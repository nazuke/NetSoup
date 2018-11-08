#!/usr/local/bin/perl -w

use strict;
use FindBin;
use LWP::UserAgent;
use NetSoup::Files::Load;
use NetSoup::Files::Save;

my $cfg      = "$FindBin::Bin/RoundRobinMonitor.cfg";
my @hosts    = split( m/\n/s, NetSoup::Files::Load->new()->immediate( Pathname => $cfg ) );
my $good     = "$FindBin::Bin/RoundRobinMonitor.good";
my $goodlist = "";
my $ua       = LWP::UserAgent->new();
$ua->agent( "RoundRobinMonitor" );
foreach my $ip ( @hosts ) {
  if( $ip ) {
    chomp( $ip );
    my $code = system( "ping -c 1 -n -w 1 $ip 1>/dev/null" );
  SWITCH: for ( $code ) {
      $code == 0 && do {
        my $req      = HTTP::Request->new( GET => "http://$ip/loadavg" );
        my $res      = $ua->request( $req );
        if( $res->is_success() ) {
          my @averages = split( m/[ \t]+/, $res->content() );
          $goodlist   .= "$averages[1]\t$ip\n"; # Use 5 minute loadavg
        }
        last SWITCH;
      };
      do {
        last SWITCH;
      };
    }
  }
}
NetSoup::Files::Save->new()->save( Pathname => $good,
                                   Data     => \$goodlist );
exit(0);
