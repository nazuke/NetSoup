#!/usr/local/bin/perl -w
use strict;
my $data = "";
while ( <DATA> ) { $data .= $_ if( $_ ) }
my @sigs = split( /\n\.{2}\n/s, $data );
my $max  = @sigs - 1;
close( STDIN );
close( STDOUT );
close( STDERR );
while(1) {
  my $pick = int rand( $max );
  open( SIG, ">$ENV{HOME}/.sig" );
  print( SIG "$sigs[$pick]\n" );
  close( SIG );
  sleep(5);
}
exit(0);


__DATA__
"Why must I be surrounded by frickin' idiots?"

                                      Dr Evil
..
"I've got a bad feeling about this..."

                        Princess Leia
..
"A Jedi craves not these things."

                            Yoda
..
"It's not my fault!"

           Han Solo
..
"Throw me a bone people!"

                 Dr Evil
..
"An _evil_ pet care centre?"

                    Dr Evil
..
"Silence! I will not tolerate this insolence!"

                                      Dr Evil
..
"Cisk for the Cisk God!"

                   Anon
..
"Drink Cisk and prosper."

                Mr Spock
..
"Bleep bloop deep blatt doop!"

                         R2D2
..
"Crom"

   Conan
..
"I'd hock my brains..."

            Rattlehead
