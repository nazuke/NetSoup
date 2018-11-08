# Set Up Globals

# To prevent Perl warnings, global variables must be
# defined inside a package to be able to share them
# across multiple script elements.

package RoundRobin;
use NetSoup::Protocol;

my $pathname      = $Box->directory();
my $countfile     = "$pathname/counter.txt";
my $listfile      = "$pathname/list.txt";
my $tally         = 0;
my @list          = ();
$RoundRobin::Host = "";
if( $Box->lockfile( Pathname => $countfile ) ) {
  if ( -e $countfile ) {
    open( COUNTER, $countfile );
    $tally = <COUNTER>;
    close( COUNTER );
  }
  if( -e $listfile ) {
    open( LIST, $listfile );
    @list = map { m/^(.+)$/ } <LIST>;
    close( LIST );
    my $flag = 1;
    do {
      $tally++;
      $tally                = 0 if( $tally > ( @list - 1 ) );
      ( $RoundRobin::Host ) = ( $list[$tally] =~ m/^([^,]+),/ );
      my @ping = split( /,/, $list[$tally] );
      for ( my $i = 1 ; $i < @ping ; $i++ ) {
        my $Protocol = NetSoup::Protocol->new( Address => $RoundRobin::Host,
                                               Port    => $ping[$i] );
        if ( $Protocol->client() ) {
          $Document->out( qq(<p>Port Pinged $ping[$i]</p>) );
        } else {
          $Document->out( qq(<p>Could not Ping Port $ping[$i]</p>) );
          $flag = 0;
        }
      }
    } while ( $flag == 0 );
    open( COUNTER, ">$countfile" );
    print( COUNTER $tally );
    close( COUNTER );
  } else {
    $Document->out( qq(<p>Error: "$listfile" not found</p>\n) );
  }
} else {
  $Document->out( qq(<p>Error: "$countfile" could not be locked</p>\n) );
}
