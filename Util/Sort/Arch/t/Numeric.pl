#!/usr/local/bin/perl

use NetSoup::Util::Sort::Arch::Numeric;
use NetSoup::Util::Arrays;
my $Numeric = NetSoup::Util::Sort::Arch::Numeric->new();
my $shuffle = NetSoup::Util::Arrays->new();
my @array   = ();
while ( <DATA> ) {
  chop;
  push( @array, $_ ) if( $_ );
}
#$shuffle->shuffle( Array => \@array );
foreach ( @array ) { print "$_\n" }
print "\n" x 4;
$Numeric->archsort( Array    => \@array,
                    Callback => sub { my $string = shift;
                                      print( STDERR "$string\n" ); } );
print "\n" x 4;
foreach ( @array ) { print "$_\n" }
exit(0);


=pod
The quick brown fox
jumps over the lazy dog
The quick brown fox
jumps over the lazy dog
The quick brown fox
jumps over the lazy dog
The quick brown fox
jumps over the lazy dog
a
b
c
d
e
f
g
h
i
j
k
l
m
n
o
p
q
r
s
t
u
v
w
x
y
z
=cut

__DATA__
1 Company 2001 Q2 Financial Results.pdf - 61 KB 
2 Company 2001 Q3 Financial Results.pdf - 153 KB 
3 Company 2001 Q4 Financial Results.pdf - 921 KB 
4 Company 2002 Q1 Financial Results.pdf - 808 KB 
5 Company 2002 Q2 Financial Results.pdf - 133 KB 
6 Company 2002 Q3 Financial Results.pdf - 399 KB 
7 Company 2002 Q4 Financial Results.pdf - 430 KB 
8 Company 1998 Q2 Financial Results.pdf - 20 KB 
9 Company 1998 Q3 Financial Results.pdf - 20 KB 
