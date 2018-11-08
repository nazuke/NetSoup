#!/usr/local/bin/perl -w


use NetSoup::Text::CodePage::ascii2hex;


@raw = <DATA>;
foreach ( @raw ) {
  my $char = $_;
  chomp( $char );
  my $dec = ord( $char );
  my $a2h = NetSoup::Text::CodePage::ascii2hex->new();
  $a2h->ascii2hex( Data => \$char );
  print( "$char\t$dec\n" );
}


__DATA__
A
a
�
�
�
�
�
�
�
�
�
�
�
�
�
�
B
b
C
c
�
�
D
d
E
e
�
�
�
�
�
�
�
�
F
f
G
g
H
h
I
i
�
�
�
�
�
�
�
�
J
j
K
k
L
l
M
m
N
n
�
�
O
o
�
�
�
�
�
�
�
�
�
�
�
P
p
Q
q
R
r
S
s
�
T
t
U
u
�
�
�
�
�
�
�
�
V
v
W
w
X
x
Y
y
�
�
�
Z
z
