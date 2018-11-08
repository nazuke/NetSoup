#!/usr/local/bin/perl
#
#   NetSoup::Text::CodePage::hex2html.pm v00.00.01a 12042000
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
#       hex2html    -  This method hex-encoded strings to their ascii equivalent
#       html2hex    -  This method encodes ascii strings with hex-encoded characters


package NetSoup::Text::CodePage::hex2html;
use NetSoup::Text::CodePage;
@NetSoup::Text::CodePage::hex2html::ISA = qw( NetSoup::Text::CodePage );
my %HEX2HTML = ();
foreach ( <NetSoup::Text::CodePage::hex2html::DATA> ) {
  my ( $hex, $html ) = ( m/^([^\t ]+)\s+([^\t ]+)\s/ );
  $HEX2HTML{$hex}    = $html;
}
1;


sub hex2html {
  # This method hex-encoded strings to their ascii equivalent.
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
  #    $object->hex2html( Data => \$data );
  my $object = shift;                 # Get object
  my %args   = @_;                    # Get arguments
  my $data   = $args{Data};           # Get unencoded data
  foreach ( keys %HEX2HTML ) {        # Iterate over translation table
    $$data =~ s/$_/$HEX2HTML{$_}/gi;  # Perform string substitution
  }
  return(1);
}


sub html2hex {
  # This method encodes ascii strings with hex-encoded characters.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #          Data => \$data
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $object->html2hex( Data => \$data );
  my $object  = shift;                    # Get object
  my %args    = @_;                       # Get arguments
  my $data    = $args{Data};              # Get unencoded data
  my @chars   = split( "", $$data );      # Split into characters
  my $encoded = "";
  foreach my $i ( @chars ) {              # Iterate over raw characters
    my $c = "";
    foreach my $j ( keys %HEX2HTML ) {    # Find code in hash
      $c = $j if( $HEX2HTML{$j} eq $i );  # Obtain encoded character from hash
    }
    if( $c ) {                            # Only encode if neccessary
      $encoded .= $c;                     # Add raw character to encoded string
    } else {                              # No encoding necessary
      $encoded .= $i;                     # Add raw character to encoded string
    }
  }
  $$data = $encoded;
  return(1);
}


__DATA__
%09    &#009    Horizontal Tab
%0A    &#010    Line Feed
%0D    &#013    Carriage Return
%20    &#032    Space
%21    &#033    Exclamation Point
%22    &quot    Quotation Mark
%23    &#035    Hash Mark
%24    &#036    Dollar Sign
%25    &#037    Percent Sign
%26    &amp    Ampersand
%27    &#039    Apostrophe
%28    &#040    Left Parenthesis
%29    &#041    Right Parenthesis
%2A    &#042    Asterisk
%2B    &#043    Plus Sign
%2C    &#044    Comma
%2D    &#045    Hyphen
%2E    &#046    Period
%2F    &#047    Slash
%30    &#048    0
%31    &#049    1
%32    &#050    2
%33    &#051    3
%34    &#052    4
%35    &#053    5
%36    &#054    6
%37    &#055    7
%38    &#056    8
%39    &#057    9
%3A    &#058    Colon
%3B    &#059    Semicolon
%3C    &lt      Less Than
%3D    &#061    Equals Sign
%3E    &gt      Greater Than
%3F    &#063    Question Mark
%40    &#064    Commercial At Sign
%41    &#065    A
%42    &#066    B
%43    &#067    C
%44    &#068    D
%45    &#069    E
%46    &#070    F
%47    &#071    G
%48    &#072    H
%49    &#073    I
%4A    &#074    J
%4B    &#075    K
%4C    &#076    L
%4D    &#077    M
%4E    &#078    N
%4F    &#079    O
%50    &#080    P
%51    &#081    Q
%52    &#082    R
%53    &#083    S
%54    &#084    T
%55    &#085    U
%56    &#086    V
%57    &#087    W
%58    &#088    X
%59    &#089    Y
%5A    &#090    Z
%5B    &#091    Left Square Bracket
%5C    &#092    Backslash
%5D    &#093    Right Square Bracket
%5E    &#094    Caret
%5F    &#095    Underscore
%60    &#096    Grave Accent
%61    &#097    a
%62    &#098    b
%63    &#099    c
%64    &#100    d
%65    &#101    e
%66    &#102    f
%67    &#103    g
%68    &#104    h
%69    &#105    i
%6A    &#106    j
%6B    &#107    k
%6C    &#108    l
%6D    &#109    m
%6E    &#110    n
%6F    &#111    o
%70    &#112    p
%71    &#113    q
%72    &#114    r
%73    &#115    s
%74    &#116    t
%75    &#117    u
%76    &#118    v
%77    &#119    w
%78    &#120    x
%79    &#121    y
%7A    &#122    z
%7B    &#123    Left Curly Brace
%7C    &#124    Vertical Bar
%7D    &#125    Right Curly Brace
%7E    &#126    Tilde
%82    &#130    UNDEFINED
%83    &#131    Florin
%84    &#132    Right Double Quote
%85    &#133    Ellipsis
%86    &#134    Dagger
%87    &#135    Double Dagger
%88    &#136    Circumflex
%89    &#137    Permil
%8A    &#138    UNDEFINED
%8B    &#139    Less Than Sign
%8C    &#140    Capital OE Ligature
%91    &#145    Left Single Quote
%92    &#146    Right Single Quote
%93    &#147    Left Double Quote
%94    &#148    Right Double Quote
%95    &#149    Bullet
%96    &#150    Em Dash
%97    &#151    En Dash
%98    &#152    Tilde
%99    &#153    Trademark
%9A    &#154    UNDEFINED
%9B    &#155    Greater Than Sign
%9C    &#156    Small oe Ligature
%9F    &#159    Capital Y Umlaut
%A0    &nbsp    Nonbreaking Space
%A1    &iexcl  Inverted Exclamation Point
%A2    &cent    Cent Sign
%A3    &pound  Pound Sign
%A4    &curren  General Currency Sign
%A5    &yen    Yen
%A6    &brvbar  Broken Vertical Bar
%A7    &sect    Section Sign
%A8    &uml    Umlaut
%A9    &copy    Copyright
%AA    &ordf    Feminine Ordinal
%AB    &laquo  Left Angle Quote
%AC    &not    Not Sign
%AD    &shy    Soft Hyphen
%AE    &reg    Registered Trademark
%AF    &macr    Macron Accent
%B0    &deg    Degree Sign
%B1    &plusmn  Plus or Minus
%B2    &sup2    Superscript 2
%B3    &sup3    Superscript 3
%B4    &acute  Acute Accent
%B5    &micro  Micro Sign (Greek mu)
%B6    &para    Paragraph Sign
%B7    &middot  Middle Dot
%B8    &ccedil  Cedilla
%B9    &sup1    Superscript 1
%BA    &ordm    Masculine Ordinal
%BB    &raquo  Right Angle Quote
%BC    &frac14  Fraction One Fourth
%BD    &frac12  Fraction One Half
%BE    &frac34  Fraction Three Fourths
%BF    &iquest  Inverted Question Mark
%C0    &Agrave  Capital A grave accent
%C1    &Aacute  Capital A acute accent
%C2    &Acirc  Capital A circumflex accent
%C3    &Atilde  Capital A tilde
%C4    &Auml    Capital A umlaut
%C5    &Aring  Capital A ring
%C6    &AElig  Capital AE ligature
%C7    &Ccedil  Capital C cedilla
%C8    &Egrave  Capital E grave accent
%C9    &Eacute  Capital E acute accent
%CA    &Ecirc  Capital E cirumflex accent
%CB    &Euml    Capital E umlaut
%CC    &Igrave  Capital I grave accent
%CD    &Iacute  Capital I acute accent
%CE    &Icirc  Capital I cirumflex accent
%CF    &Iuml    Capital I umlaut
%D0    &ETH    Capital eth Icelandic
%D1    &Ntilde  Capital N tilde
%D2    &Ograve  Capital O grave accent
%D3    &Oacute  Capital O acute accent
%D4    &Ocirc  Capital O cirumflex accent
%D5    &Ntilde  Capital O tilde
%D6    &Ouml    Capital O umlaut
%D7    &times  Multiply Sign
%D8    &Oslash  Capital O slash
%D9    &Ugrave  Capital U grave accent
%DA    &Uacute  Capital U acute accent
%DB    &Ucirc  Capital U cirumflex accent
%DC    &Uuml    Capital U umlaut
%DD    &Uacute  Capital Y acute accent
%DE    &THORN  Capital thorn Icelandic
%DF    &szlig  Small sz ligature German
%E0    &agrave  Small a grave accent
%E1    &aacute  Small a acute accent
%E2    &acirc  Small a circumflex accent
%E3    &atilde  Small a tilde
%E4    &auml    Small a umlaut
%E5    &aring  Small a ring
%E6    &aelig  Small a ligature
%E7    &ccedil  Small c cedilla
%E8    &egrave  Small e grave accent
%E9    &eacute  Small e acute accent
%EA    &ecirc  Small e circumflex accent
%EB    &euml    Small e umlaut
%EC    &igrave  Small i grave accent
%ED    &iacute  Small i acute accent
%EE    &icirc  Small i circumflex accent
%EF    &iuml    Small i umlaut
%F0    &eth    Small eth Icelandic
%F1    &ntilde  Small n tilde
%F2    &ograve  Small o grave accent
%F3    &oacute  Small o acute accent
%F4    &ocirc  Small o circumflex accent
%F5    &otilde  Small o tilde
%F6    &ouml    Small o umlaut
%F7    &divide  Division Sign
%F8    &oslash  Small o slash
%F9    &ugrave  Small u grave accent
%FA    &uacute  Small u acute accent
%FB    &ucirc  Small u circumflex accent
%FC    &uuml    Small u umlaut
%FD    &yacute  Small y acute accent
%FE    &thorn  Small thorn Icelandic
%FF    &yuml    Small y umlaut
