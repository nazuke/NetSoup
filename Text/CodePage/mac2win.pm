#!/usr/local/bin/perl
#
#   NetSoup::Text::CodePage::mac2win.pm v00.00.01a 12042000
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
#       initialise  -  This method is the object initialiser
#       mac2win     -  This method Windows-encoded strings to Mac encoding


package NetSoup::Text::CodePage::mac2win;
use NetSoup::Text::CodePage;
@NetSoup::Text::CodePage::mac2win::ISA = qw( NetSoup::Text::CodePage );
my %MAC2WIN = ();
while ( <NetSoup::Text::CodePage::mac2win::DATA> ) {
  my ( $from, $to ) = ( m/^([^\t ]+)\s+([^\t ]+)\s/ );
  $from             = chr( $from );
  $MAC2WIN{$from}   = chr( $to );
}
1;


sub mac2win {
  # This method Windows-encoded strings to Mac encoding.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Data => \$data
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $object->mac2win( Data => \$data );
  my $object  = shift;                       # Get object
  my %args    = @_;                          # Get arguments
  my $data    = $args{Data};                 # Get unencoded data
  my $newData = "";
  my $length  = length( $$data );
  for( my $i = 0 ; $i <= $length ; $i++ ) {  #
    my $char  = substr( $$data, $i, 1 );
    $newData .= $MAC2WIN{$char} || $char;    #
  }
  $$data = $newData;
  return(1);
}


__DATA__
128  196
129  197
130  199
131  201
132  209
133  214
134  220
135  225
136  224
137  226
138  228
139  227
140  229
141  231
142  233
143  232
144  234
145  235
146  237
147  236
148  238
149  239
150  241
151  243
152  242
153  244
154  246
155  245
156  250
157  249
158  251
159  252
160  134
161  176
162  162
163  163
164  167
165  183
166  182
167  223
168  174
169  169
170  153
171  146
172  168
174  198
175  216
177  177
180  165
181  181
187  170
188  176
190  156
191  248
192  191
193  161
194  172
196  131
199  171
200  187
201  133
203  192
204  195
205  213
206  140
207  156
208  150
209  151
210  147
211  148
212  145
213  146
214  247
216  255
217  159
220  139
221  155
224  135
225  183
226  130
227  132
228  137
229  194
230  202
231  193
232  203
233  200
234  205
235  206
236  207
237  204
238  211
239  212
241  210
242  218
243  219
244  217
246  136
247  152
248  175
252  184
253  168
