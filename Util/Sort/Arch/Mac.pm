#!/usr/local/bin/perl
#
#   NetSoup::Util::Sort::Arch::Mac.pm v00.00.01z 12042000
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


package NetSoup::Util::Sort::Arch::Mac;
use strict;
use NetSoup::Util::Sort;
@NetSoup::Util::Sort::Arch::Mac::ISA = qw( NetSoup::Util::Sort );
my %ORDER = ();
my $count = 0;
while( <NetSoup::Util::Sort::Arch::Mac::DATA> ) {  # Build character sort order table
  chomp;
  next if( ! $_ );
  my( $hex, $dec ) = split( /\t/, $_ );
  my $char         = pack( "H2", $hex );
  $ORDER{$dec}     = $count;                       # Add sort order value for character
  $count++;
}
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Key => Value
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $Mac->initialise();
  my $Mac       = shift;    # Get object
  $Mac->{Order} = \%ORDER;  # Link object to class sort order
  return(1);
}


__DATA__
DB  219
F0  240
2D  45
2D  45
7F  127
27  39
2D  45
D0  208
D1  209
21  33
22  34
23  35
24  36
25  37
26  38
28  40
29  41
2A  42
2C  44
2E  46
2F  47
3A  58
3B  59
3F  63
40  64
5B  91
5C  92
5D  93
5E  94
F6  246
5F  95
60  96
7B  123
7C  124
7D  125
7E  126
C1  193
AC  172
F8  248
AB  171
FC  252
C0  192
FF  255
F9  249
FA  250
FB  251
FE  254
F7  247
FD  253
D4  212
D5  213
E2  226
22  34
22  34
E3  227
DC  220
DD  221
2B  43
DA  218
3C  60
3D  61
3E  62
B1  177
C7  199
C8  200
D6  214
B6  182
C6  198
B8  184
B7  183
C3  195
BA  186
C5  197
AD  173
B2  178
B3  179
D7  215
A2  162
A3  163
B4  180
A4  164
A9  169
C2  194
A8  168
A1  161
B5  181
A6  166
E1  225
A0  160
E0  224
6F  111
C9  201
E4  228
30  48
31  49
32  50
33  51
34  52
35  53
36  54
37  55
38  56
39  57
B0  176
41  65
61  97
BB  187
87  135
E7  231
88  136
CB  203
89  137
0D  13
80  128
8A  138
8B  139
CC  204
81  129
8C  140
AE  174
BE  190
42  66
62  98
43  67
63  99
82  130
8D  141
44  68
64  100
45  69
65  101
83  131
8E  142
8F  143
E9  233
90  144
E6  230
91  145
E8  232
46  70
66  102
C4  196
DE  222
DF  223
47  71
67  103
48  72
68  104
49  73
69  105
F5  245
92  146
EA  234
93  147
ED  237
94  148
EB  235
95  149
EC  236
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
84  132
96  150
4F  79
6F  111
BC  188
97  151
EE  238
98  152
F1  241
99  153
EF  239
85  133
9A  154
9B  155
CD  205
AF  175
BF  191
CE  206
CF  207
50  80
70  112
51  81
71  113
52  82
72  114
53  83
73  115
A7  167
54  84
74  116
AA  170
55  85
75  117
9C  156
F2  242
9D  157
F4  244
9E  158
F3  243
86  134
9F  159
56  86
76  118
57  87
77  119
58  88
78  120
59  89
79  121
D8  216
D9  217
5A  90
7A  122
B9  185
BD  189
