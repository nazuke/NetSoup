#!/usr/local/bin/perl
#
#   NetSoup::Text::CodePage::html2win.pm v00.00.01a 12042000
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
#       win2html    -  This method converts Win-encoded characters to their equivalent Html Entity Tags
#       html2win    -  This method converts Html Entity Tags to their equivalent Win encodings


package NetSoup::Text::CodePage::html2win;
use NetSoup::Core;
@NetSoup::Text::CodePage::html2win::ISA = qw( NetSoup::Core );
my %BIDIRECT = ();
my %HTML2WIN = ();
my %WIN2HTML = ();
while ( <NetSoup::Text::CodePage::html2win::DATA> ) {  # Read table form DATA segment
  my ( $hDir,
       $cDir,
       $html,
       $char ) = ( m/^                                 # Load up conversion tables
                   ([^\t ]+)\t+                        # Entity tag direction flag
                   ([^\t ]+)\t+                        # Mac character direction flag
                   ([^\t ]+)\t+                        # Entity tag value
                   ([^\t ]+)\t+                        # Win character value
                   /x );
  $char            = chr($char);                       # Get Win character from Ascii value
  $BIDIRECT{$html} = $hDir;
  $BIDIRECT{$char} = $cDir;
  $HTML2WIN{$html} = $char;                            # Store entity tag direction
  $WIN2HTML{$char} = $html;                            # Store character direction
}
1;


sub win2html {
  # This method converts Win-encoded characters to their equivalent Html Entity Tags.
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
  #    $object->win2html( Data => \$data );
  my $object = shift;                   # Get object
  my %args   = @_;                      # Get arguments
  my $data   = $args{Data};             # Get unencoded data
  my @chars  = split( //, $$data );
  $$data     = "";
  foreach my $i ( @chars ) {
    if( exists $BIDIRECT{$i} ) {
      if( $BIDIRECT{$i} =~ m/^\+$/ ) {  # Flagged for conversion ?
        $$data .= $WIN2HTML{$i};        # Convert to entity tag
      } else {
        $$data .= $i;                   # No conversion
      }
    } else {
      $$data .= $i;                     # No conversion
    }
  }
  return(1);
}


sub html2win {
  # This method converts Html Entity Tags to their equivalent Win encodings.
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
  #    $object->html2win( Data => \$data );
  my $object = shift;                     # Get object
  my %args   = @_;                        # Get arguments
  my $data   = $args{Data};               # Get unencoded data
  foreach my $i ( keys %HTML2WIN ) {      # Find code in hash
    $$data =~ s/\Q$i\E/$HTML2WIN{$i}/gs;  # Perform global substitution
  }
  return(1);
}


__DATA__
+  -  &#009;    9      Horizontal Tab
+  -  &#010;    10    Line Feed
+  -  &#013;    13    Carriage Return
+  +  &#032;    32    Space
+  -  &#033;    33    Exclamation Point
+  -  &quot;    34    Quotation Mark
+  -  &#035;    35    Hash Mark
+  -  &#036;    36    Dollar Sign
+  -  &#037;    37    Percent Sign
+  +  &amp;      38    Ampersand
+  -  &#039;    39    Apostrophe
+  -  &#040;    40    Left Parenthesis
+  -  &#041;    41    Right Parenthesis
+  -  &#042;    42    Asterisk
+  -  &#043;    43    Plus Sign
+  -  &#044;    44    Comma
+  -  &#045;    45    Hyphen
+  -  &#046;    46    Period
+  -  &#047;    47    Slash
+  -  &#058;    58    Colon
+  -  &#059;    59    Semicolon
+  +  &lt;      60    Less Than
+  -  &#061;    61    Equals Sign
+  +  &gt;      62    Greater Than
+  -  &#063;    63    Question Mark
+  -  &#064;    64    Commercial At Sign
+  -  &#091;    91    Left Square Bracket
+  -  &#092;    92    Backslash
+  -  &#093;    93    Right Square Bracket
+  -  &#094;    94    Caret
+  -  &#095;    95    Underscore
+  -  &#096;    96    Grave Accent
+  -  &#123;    123    Left Curly Brace
+  -  &#124;    124    Vertical Bar
+  -  &#125;    125    Right Curly Brace
+  -  &#126;    126    Tilde
+  -  &#130;    130    UNDEFINED
+  +  &#131;    196    Florin
+  +  &#132;    211    Right Double Quote
+  +  &#133;    201    Ellipsis
+  +  &#134;    160    Dagger
+  +  &#135;    224    Double Dagger
+  +  &#136;    246    Circumflex
+  +  &#137;    228    Permil
+  +  &#139;    60    Less Than Sign
+  +  &#140;    206    Capital OE Ligature
+  +  &#145;    212    Left Single Quote
+  +  &#146;    213    Right Single Quote
+  +  &#147;    210    Left Double Quote
+  +  &#148;    211    Right Double Quote
+  +  &#149;    165    Bullet
+  +  &#150;    209    Em Dash
+  +  &#151;    208    En Dash
+  -  &#152;    126    Tilde
+  +  &#153;    170    Trademark
+  +  &#155;    62    Greater Than Sign
+  +  &#156;    207    Small oe Ligature
+  +  &#159;    217    Capital Y Umlaut
+  -  &nbsp;    32    Nonbreaking Space
+  +  &iexcl;    193    Inverted Exclamation Point
+  +  &cent;    162    Cent Sign
+  +  &pound;    163    Pound Sign
+  +  &current;  219    General Currency Sign
+  +  &yen;      180    Yen
+  +  &brvbar;  124    Broken Vertical Bar
+  +  &sect;    164    Section Sign
+  +  &uml;      172    Umlaut
+  +  &copy;    169    Copyright
+  +  &ordf;    187    Feminine Ordinal
+  +  &laquo;    199    Left Angle Quote
+  +  &not;      194    Not Sign
+  +  &shy;      30    Soft Hyphen
+  +  &reg;      168    Registered Trademark
+  +  &macr;    248    Macron Accent
+  +  &deg;      251    Degree Sign
+  +  &plusmn;  177    Plus or Minus
+  -  &sup2;    50    Superscript 2
+  -  &sup3;    51    Superscript 3
+  +  &acute;    171    Acute Accent
+  +  &micro;    181    Micro Sign (Greek mu)
+  +  &para;    166    Paragraph Sign
+  +  &middot;  225    Middle Dot
+  +  &ccedil;  254    Cedilla
+  -  &sup1;    49    Superscript 1
+  +  &ordm;    188    Masculine Ordinal
+  +  &raquo;    200    Right Angle Quote
+  +  &iquest;  192    Inverted Question Mark
+  +  &Agrave;  203    Capital A, grave accent
+  +  &Aacute;  231    Capital A, acute accent
+  +  &Acirc;    229    Capital A, circumflex accent
+  +  &Atilde;  204    Capital A, tilde
+  +  &Auml;    128    Capital A, umlaut
+  +  &Aring;    129    Capital A, ring
+  +  &AElig;    174    Capital AE, ligature
+  +  &Ccedil;  130    Capital C, cedilla
+  +  &Egrave;  233    Capital E, grave accent
+  +  &Eacute;  131    Capital E, acute accent
+  +  &Ecirc;    230    Capital E, cirumflex accent
+  +  &Euml;    232    Capital E, umlaut
+  +  &Igrave;  237    Capital I, grave accent
+  +  &Iacute;  234    Capital I, acute accent
+  +  &Icirc;    235    Capital I, cirumflex accent
+  +  &Iuml;    236    Capital I, umlaut
+  +  &ETH;      220    Capital eth, Icelandic
+  +  &Ntilde;  132    Capital N, tilde
+  +  &Ograve;  241    Capital O, grave accent
+  +  &Oacute;  238    Capital O, acute accent
+  +  &Ocirc;    239    Capital O, cirumflex accent
+  +  &Ntilde;  205    Capital O, tilde
+  +  &Ouml;    133    Capital O, umlaut
+  +  &times;    42    Multiply Sign
+  +  &Oslash;  175    Capital O, slash
+  +  &Ugrave;  244    Capital U, grave accent
+  +  &Uacute;  242    Capital U, acute accent
+  +  &Ucirc;    243    Capital U, cirumflex accent
+  +  &Uuml;    134    Capital U, umlaut
+  +  &szlig;    167    Small sz ligature, German
+  +  &agrave;  136    Small a, grave accent
+  +  &aacute;  135    Small a, acute accent
+  +  &acirc;    137    Small a, circumflex accent
+  +  &atilde;  139    Small a, tilde
+  +  &auml;    138    Small a, umlaut
+  +  &aring;    140    Small a, ring
+  +  &aelig;    190    Small a ligature
+  +  &ccedil;  141    Small c, cedilla
+  +  &egrave;  143    Small e, grave accent
+  +  &eacute;  142    Small e, acute accent
+  +  &ecirc;    144    Small e, circumflex accent
+  +  &euml;    145    Small e, umlaut
+  +  &igrave;  147    Small i, grave accent
+  +  &iacute;  146    Small i, acute accent
+  +  &icirc;    148    Small i, circumflex accent
+  +  &iuml;    149    Small i, umlaut
+  +  &ntilde;  150    Small n, tilde
+  +  &ograve;  152    Small o, grave accent
+  +  &oacute;  151    Small o, acute accent
+  +  &ocirc;    153    Small o, circumflex accent
+  +  &otilde;  155    Small o, tilde
+  +  &ouml;    154    Small o, umlaut
+  +  &divide;  214    Division Sign
+  +  &oslash;  191    Small o, slash
+  +  &ugrave;  157    Small u, grave accent
+  +  &uacute;  156    Small u, acute accent
+  +  &ucirc;    158    Small u, circumflex accent
+  +  &uuml;    159    Small u, umlaut
+  +  &yuml;    216    Small y, umlaut
