#!/usr/local/bin/perl -w


use NetSoup::Maths::Entropy;
use NetSoup::Maths::Suffix;

my $Entropy = NetSoup::Maths::Entropy->new();
my $Suffix  = NetSoup::Maths::Suffix->new();
my @structs = ();
my %repeats = ();
my @cust    = ();


open( FILE, "List.txt" );
while( my $line = <FILE> ) {
  chomp( $line );
  my ( $name, $count ) = split( m/\t/, $line );
  $count = 0 if( ! defined $count );
  $repeats{$name} = $count if( $count );
  push( @structs, [ $name, $count ] );
}
close( FILE );


foreach my $ref ( @structs ) {
  my $name = $ref->[0];
  push( @cust, $name );
}


foreach my $name ( keys %repeats ) {
  my $count = $repeats{$name} - 1;
  for( my $i = 1 ; $i <= $count ; $i++ ) {
    my $flag = 1;
    my $idx  = 0;
    do {
      $idx  = $Entropy->random( Max => @cust - 1 );
      $flag = 0 if( ( $cust[$idx-1] || $cust[$idx+1] ) ne $name );
      $flag = 1 if( $idx <= 10 );
    } while( $flag );
    splice( @cust, $idx, 0, $name );
  }
}


foreach my $name ( keys %repeats ) {
  my $count = $repeats{$name} - 1;
  for( my $i = ( @cust - 1 ) ; $i > 0 ; $i-- ) {
    if( $cust[$i] eq $name ) {
      if( $count > 0 ) {
        my $purchase = $Suffix->append( $count + 1 );
        $cust[$i] = "$name ( $purchase purchase )";
        $count--;
      }
    }
  }
}


for( my $i = 0 ; $i < @cust ; $i++ ) {
  $cust[$i] = qq("$cust[$i]");
}


open( SRC, "JOurCustomersSrc.java" );
my $java = join( "", <SRC> );
close( SRC );
$java =~ s/\"STRINGS\"/join(",\n",@cust)/egs;
$java =~ s/\r//gs;
open( JAVA, ">JOurCustomers.java" );
print( JAVA $java );
close( JAVA );


exit(0);
