#!/usr/local/bin/perl -w

my $count  = 0;
my %agents = ( MSIE      => 0,
               Gecko     => 0,
               Opera     => 0,
               Netscape4 => 0,
               Other     => 0 );
my %others = ();
while ( <STDIN> ) {
  chomp;
  $count++;
 SWITCH: for( $_ ) {
    m/MSIE/ && do {
      $agents{MSIE}++;
      last SWITCH;
    };
    m/Gecko/i && do {
      $agents{Gecko}++;
      last SWITCH;
    };
    m/Mozilla\/4/ && do {
      $agents{Netscape4}++;
      last SWITCH;
    };
    m/Opera/ && do {
      $agents{Opera}++;
      last SWITCH;
    };
    m/./ && do {
      my $agent       = $_;
      $agent          =~ s/^[^ \t]+[ \t]//;
      if ( exists $others{$agent} ) {
        $others{$agent}++;
      } else {
        $others{$agent} = 1;
      }
      $agents{Other}++;
      last SWITCH;
    };
  }
}
foreach my $key ( sort keys %agents ) {
  print( "$key:" . &{ sub { return( " " x ( 12 - length($key) ) ) } } . $agents{$key} . &{ sub { return( " " x ( 12 - length( $agents{$key} ) ) ) } } . calc($agents{$key}) . "\%\n" );
}
print( "\n\n" );
print( "Note: Gecko browsers include Mozilla, Netscape 6/7 and derivatives.\n" );
print( "\n\n" );
foreach my $key ( keys %others ) {
  print( "$others{$key}\t$key\n" );
}
exit(0);

sub calc {
  my $value = shift;
  my $calc  = ( 100 / $count ) * $value;
  ( $calc ) = ( $calc =~ m/^(\d+\.\d{2})/ );
  if ( $calc <= 9 ) {
    $calc = "0" . $calc;
  }
  return( $calc );
}
