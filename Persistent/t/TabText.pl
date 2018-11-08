#!/usr/local/bin/perl -w


use NetSoup::Persistent::TabText;


my $filename = "test.db";
my $TabText = NetSoup::Persistent::TabText->new( Pathname => $filename,
                                                 Fields   => [ "Field01", "Field02", "Field03" ] );
if( -e $filename ) {
  foreach my $key ( $TabText->keylist() ) {
    my $padding = " " x ( 16 - length( $key ) );
    print( "$key$padding" . $TabText->Field01( Key => $key ) . "\n" );
  }
} else {
  print( qq(Writing "$filename"\n) );
  srand( time );
  for( my $i = 0 ; $i < 100 ; $i++ ) {
    $TabText->add( Key     => int rand( time ),
                   Field01 => int rand( time ),
                   Field02 => int rand( time ),
                   Field03 => int rand( time ) );
  }
}
exit(0);
