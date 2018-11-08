#!/usr/local/bin/perl
#
#   NetSoup::Text::CodePage::win2mac.pm v00.00.01a 12042000
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
#       win2mac     -  This method converts Mac-encoded strings to Windows encoding


package NetSoup::Text::CodePage::win2mac;
use NetSoup::Text::CodePage;
@NetSoup::Text::CodePage::win2mac::ISA = qw( NetSoup::Text::CodePage );
my %WIN2MAC = ();
while ( <NetSoup::Text::CodePage::win2mac::DATA> ) {
  my ( $from, $to ) = ( m/^([^\t ]+)\s+([^\t ]+)\s/ );
  $from             = chr( $from );
  $WIN2MAC{$from}   = chr( $to );
}
1;


sub win2mac {
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
  #    $object->win2mac( Data => \$data );
  my $object  = shift;                       # Get object
  my %args    = @_;                          # Get arguments
  my $data    = $args{Data};                 # Get unencoded data
  my $newData = "";
  my $length  = length( $$data );
  for( my $i = 0 ; $i <= $length ; $i++ ) {  #
    my $char  = substr( $$data, $i, 1 );
    $newData .= $WIN2MAC{$char} || $char;    #
  }
  $$data = $newData;
  return(1);
}


__DATA__
130  226
131  196
132  227
133  201
134  160
135  224
136  246
137  228
139  220
140  206
145  212
146  171
146  213
147  210
148  211
150  208
151  209
152  247
153  170
155  221
156  190
156  207
159  217
161  193
162  162
163  163
165  180
167  164
168  172
168  253
169  169
170  187
171  199
172  194
174  168
175  248
176  161
176  188
177  177
181  181
182  166
183  165
183  225
184  252
187  200
191  192
192  203
193  231
194  229
195  204
196  128
197  129
198  174
199  130
200  233
201  131
202  230
203  232
204  237
205  234
206  235
207  236
209  132
210  241
211  238
212  239
213  205
214  133
216  175
217  244
218  242
219  243
220  134
223  167
224  136
225  135
226  137
227  139
228  138
229  140
231  141
232  143
233  142
234  144
235  145
236  147
237  146
238  148
239  149
241  150
242  152
243  151
244  153
245  155
246  154
247  214
248  191
249  157
250  156
251  158
252  159
255  216
