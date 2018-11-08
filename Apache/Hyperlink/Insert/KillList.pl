#!/usr/local/bin/perl -w

use strict;

my %list = ();
open( FILE, "KillList.txt" );
while( <FILE> ) {
  chomp;
  $list{$_} = 1 if( $_ );
}
close( FILE );
my $module = "";
open( FILE, "KillList.src" );
$module = join( "", <FILE> );
close( FILE );
open( FILE, ">KillList.pm" );
open( REWRITE, ">KillList.txt" );
print( FILE $module );
foreach my $key ( sort keys %list ) {
  print( FILE "$key\n" );
  print( REWRITE "$key\n" );
}
close( REWRITE );
close( FILE );
chmod( "KillList.pm", 0777 );
exit(0);
