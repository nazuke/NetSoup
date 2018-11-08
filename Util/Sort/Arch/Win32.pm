#!/usr/local/bin/perl
#
#   NetSoup::Util::Sort::Arch::Win32.pm v00.00.01z 12042000
#
#   Copyright (C) 2000  Jason Holland <jason.holland@dial.pipex.com>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#
#   Description: This Perl 5.0 class provides object methods for.
#
#
#   Methods:
#       initialise  -  This method is the object initialiser for this class


package NetSoup::Util::Sort::Arch::Win32;
use strict;
use NetSoup::Util::Sort::Arch;
@NetSoup::Util::Sort::Arch::Win32::ISA = qw( NetSoup::Util::Sort::Arch );
my %ORDER = ();
my $count = 0;
while( <NetSoup::Util::Sort::Arch::Win32::DATA> ) {  # Build character sort order table
  chomp;
  next if( ! $_ );
  my( $hex, $dec ) = split( /\t/, $_ );
  my $char         = pack( "H2", $hex );
  $ORDER{$dec}     = $count;                         # Add sort order value for character
  $count++;
}
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    boolean
  # Example:
  #    $Win32->initialise();
  my $Win32       = shift;    # Get object
  $Win32->{Order} = \%ORDER;  # Link object to class sort order
  return(1);
}


__DATA__
41  65
61  97
C0  192
C1  193
C2  194
C3  195
C4  196
C5  197
C6  198
E0  224
E1  225
E2  226
E3  227
E4  228
E5  229
E6  230
42  66
62  98
43  67
63  99
C7  199
E7  231
44  68
64  100
45  69
65  101
C8  200
C9  201
CA  202
CB  203
E8  232
E9  233
EA  234
EB  235
46  70
66  102
47  71
67  103
48  72
68  104
49  73
69  105
CC  204
CD  205
CE  206
CF  207
EC  236
ED  237
EE  238
EF  239
4A  74
6A  106
4B  75
6B  107
4C  76
6C  108
4D  77
6D  109
4E  78
6E  110
D1  209
F1  241
4F  79
6F  111
D2  210
D3  211
D4  212
D5  213
D6  214
D8  216
F2  242
F3  243
F4  244
F5  245
F6  246
50  80
70  112
51  81
71  113
52  82
72  114
53  83
73  115
DF  223
54  84
74  116
55  85
75  117
D9  217
DA  218
DB  219
DC  220
F9  249
FA  250
FB  251
FC  252
56  86
76  118
57  87
77  119
58  88
78  120
59  89
79  121
DD  221
FD  253
FF  255
5A  90
7A  122
