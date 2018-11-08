#!/usr/local/bin/perl -w


use Inline C => "Config", MYEXTLIB => '/home/web/Projects/Perl/NetSoup/C/mylib.so';


use Inline C => <<END_C;

SV* get_p_getpid() {
  return( p_getpid() );
}

AV* get_create_array() {
  return( create_array() );
}

END_C
;


print( get_p_getpid() . "\n" );


foreach my $line ( @{get_create_array()} ) {
  print( "$line\n" );
}
