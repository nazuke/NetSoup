#!/usr/local/bin/perl
#
#   NetSoup::XHTML::Widgets::I18N.pm v00.00.01z 12042000
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
#   Description: This Perl 5.0 class manages internationalised
#                XHTML string components.
#
#
#   Methods:
#       initialise  -  This method is the object initialiser for this class


package NetSoup::XHTML::Widgets::I18N;
use strict;
use NetSoup::Text::CodePage::ascii2hex;
use NetSoup::Text::CodePage::ascii2url;
use NetSoup::XHTML::Widgets::Serialise;
use NetSoup::XML::DOM2::Core::Element;
use NetSoup::XML::DOM2::Core::Text;
use NetSoup::XML::DOM2::Traversal::DocumentTraversal;
use NetSoup::XML::DOM2::Traversal::Serialise;
use NetSoup::XML::DOM2;
@NetSoup::XHTML::Widgets::I18N::ISA = qw( NetSoup::XHTML::Widgets::Serialise );
my $TRAVERSAL  = "NetSoup::XML::DOM2::Traversal::DocumentTraversal";
my $ELEMENT    = "NetSoup::XML::DOM2::Core::Element";
my $TEXT       = "NetSoup::XML::DOM2::Core::Text";
my $A2H        = NetSoup::Text::CodePage::ascii2hex->new();
my $A2U        = NetSoup::Text::CodePage::ascii2url->new();
my $NAMESPACE  = "NetSoup";
my $JavaScript = "";
while( <NetSoup::XHTML::Widgets::I18N::DATA> ) {
  $JavaScript .= $_;
}
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    I18N
  #    hash    {
  #              Document => $Document
  #            }
  # Result Returned:
  #    I18N
  # Example:
  #    my $I18N = NetSoup::XHTML::Widgets::I18N->new( Document => $Document );
  my $I18N         = shift;                                                                   # Get I18N object
  my %args         = @_;                                                                      # Get arguments
  my $Document     = $args{Document};                                                         # Get DOM2 Document object
  my $DocTraversal = $TRAVERSAL->new();                                                       # Get new traversal object...
  my $TreeWalker   = $DocTraversal->createTreeWalker( Root                     => $Document,  # ... And spawn a TreeWalker object
                                                      WhatToShow               => undef,
                                                      Filter                   => undef,
                                                      EntityReferenceExpansion => 0 );
  my $flag         = 0;
  my $Head         = undef;
  my $Widget       = $ELEMENT->new( NodeName     => "I18N",                                   # Create new I18N Widget element
                                    NamespaceURI => $NAMESPACE );
  $TreeWalker->walkTree( Node     => $Document,                                               # Search for I18N Widget in Document
                         Callback => sub {
                           my $Node = shift;
                         SWITCH: for( $Node->nodeName() ) {
                             m/^head$/i && do {
                               $Head = $Node;                                                 # Store Widget Node reference
                               last SWITCH;
                             };
                             m/^I18N$/i && do {
                               $Widget = $Node;                                               # Store Widget Node reference
                               $flag++;
                               last SWITCH;
                             };
                           }
                           return(1);
                         } );
  return( undef ) if( ! defined $Head );                                                      # Return undef if not an XHTML document
  $I18N->{Flag}     = $flag;                                                                  # Store flag in object
  $I18N->{Document} = $Document;                                                              # Store Document in object
  $I18N->{Head}     = $Head;                                                                  # Store Head Node in object
  $I18N->{Widget}   = $Widget;                                                                # Store Widget in object
  $I18N->_create() if( ! $flag );                                                             # Convert Document to I18N
  return( $I18N );
}


sub _create {
  # This private method transforms a regular XHTML document into an I18N compatible document.
  # Calls:
  #    none
  # Parameters Required:
  #    I18N
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $I18N         = shift;                                                                           # Get I18N object
  my %args         = @_;                                                                              # Get arguments
  my $DocTraversal = $TRAVERSAL->new();                                                               # Get new traversal object...
  my $TreeWalker   = $DocTraversal->createTreeWalker( Root                     => $I18N->{Document},  # ... And spawn a Tree Walker object
                                                      WhatToShow               => undef,
                                                      Filter                   => undef,
                                                      EntityReferenceExpansion => 0 );
  my @strings      = ();                                                                              # Array of strings
  my $length       = -1;                                                                              # String counter in array
  $TreeWalker->walkTree( Node     => $I18N->{Document},                                               # Search for I18N Widget in Document
                         Callback => sub {
                           my $Node   = shift;
                           my $Parent = $Node->parentNode();
                           if( defined $Parent ) {
                           SKIP: for( $Parent->nodeName() ) {
                               m/^script/i && return(1);
                             }
                           }
                         NODETYPE: for( $Node->nodeType() ) {
                             m/TEXT_NODE/i && do {
                               push( @strings, $Node->nodeValue() );
                               $length++;
                               my $script = qq( <script language="JavaScript">
                                                document.write(I18NString($length));
                                                </script> );
                               $script    =~ s/[ \t\x0A\x0D]+/ /gs;
                               $Node->nodeValue( NodeValue => $script );
                               last NODETYPE;
                             };
                             m/ELEMENT_NODE/i && do {
                             SWITCH: for( $Node->nodeName() ) {
                                 m/^img$/i && do {
                                   my $alt = $Node->getAttribute( Name => "alt" );
                                   if( $alt ) {
                                     push( @strings, $alt );
                                     $length++;
                                     my $script = qq(\&{I18NString($length)};);
                                     $Node->setAttribute( Name  => "alt",
                                                          Value => $script );
                                   }
                                   last NODETYPE;
                                 };
                               }
                               last NODETYPE;
                             };
                           }
                           return(1);
                         } );
  $I18N->{Catalogue} = $ELEMENT->new( NodeName     => "catalogue",
                                      NamespaceURI => $NAMESPACE );                                   # Create new Catalogue element
  $I18N->{Widget}->appendChild( NewChild => $I18N->{Catalogue} );                                     # Add Catalogue to Widget
  $I18N->setLang( Strings => \@strings, Language => "default" );                                      # Add default string set
  my $firstChild = $I18N->{Head}->firstChild();
  $I18N->{Head}->insertBefore( NewChild => $I18N->{Widget},                                           # Insert completed Widget into Document <head> section
                               RefChild => $firstChild );
  return(1);
}


sub setLang {
  # This method sets a language entry in the I18N Widget.
  # Calls:
  #    none
  # Parameters Required:
  #    I18N
  #    hash    {
  #              Strings  => \@strings
  #              Language => $language
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $I18N     = shift;                                                  # Get I18N object
  my %args     = @_;                                                     # Get arguments
  my $language = $args{Language};                                        # Get strings array
  my $count    = 0;
  my $Set      = $ELEMENT->new( NodeName     => "set",                   # Create new Set element
                                NamespaceURI => $NAMESPACE );
  $Set->setAttribute( Name => "lang", Value => $language );              # Configure Set element
  foreach my $string ( @{$args{Strings}} ) {                             # Add strings to Set
    $A2H->ascii2hex( Data => \$string );                                 # Convert string to hex code
    my $I18NString = $ELEMENT->new( NodeName     => "I18NString",
                                    NamespaceURI => $NAMESPACE );
    $I18NString->setAttribute( Name => "content", Value => $string );
    $I18NString->setAttribute( Name => "index",   Value => $count );
    $I18NString->setAttribute( Name => "lang",    Value => $language );  #
    $Set->appendChild( NewChild => $I18NString );
    $count++;
  }
  $I18N->{Catalogue}->appendChild( NewChild => $Set );                   # Add Set to Catalogue element
  $I18N->_script();                                                      # Build JavaScript code element
  return(1);
}


sub getLang {
  # This method adds a new language entry to the I18N Widget.
  # Calls:
  #    none
  # Parameters Required:
  #    I18N
  #    hash    {
  #              Strings  => \@strings
  #              Language => $language
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $I18N         = shift;                                                                                          # Get I18N object
  my %args         = @_;                                                                                             # Get arguments
  my $strings      = $args{Strings};                                                                                 # Get strings array
  my $language     = $args{Language};                                                                                # Get strings array
  my $DocTraversal = $TRAVERSAL->new();                                                                              # Get new traversal object...
  my $TreeWalker   = $DocTraversal->createTreeWalker( WhatToShow               => undef,                             # ... And spawn a Tree Walker object
                                                      Filter                   => sub {},
                                                      EntityReferenceExpansion => 0,
                                                      CurrentNode              => $I18N->{Widget} );                 #
  $TreeWalker->walkTree( Node     => $I18N->{Widget},                                                                #
                         Callback => sub {
                           my $Node = shift;
                           return(1) if( $Node->nodeName() ne "set" );
                           return(1) if( $Node->getAttribute( Name => "lang" ) ne $language );
                           my $MiniTraverse = $TRAVERSAL->new();                                                     # Get new traversal object...
                           my $MiniWalker   = $MiniTraverse->createTreeWalker( WhatToShow               => undef,    # Traverse the Set element
                                                                               Filter                   => sub {},
                                                                               EntityReferenceExpansion => 0,
                                                                               CurrentNode              => $Node );  #
                           $MiniWalker->walkTree( Node     => $Node,
                                                  Callback => sub {
                                                    my $mNode = shift;
                                                    if( $mNode->nodeName() =~ m/I18NString/i ) {
                                                      my $content = $mNode->getAttribute( Name => "content" );       # Get content attribute
                                                      $A2H->hex2ascii( Data => \$content );
                                                      push( @$strings, $content );
                                                    }
                                                    return(1);
                                                  } );
                           return(1);
                         } );
   return(1);
}


sub _script {
  # This private method builds the JavaScript code element.
  # Calls:
  #    none
  # Parameters Required:
  #    I18N
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $I18N         = shift;                                                                              # Get I18N object
  my %args         = @_;                                                                                 # Get arguments
  my $Script       = $ELEMENT->new( NodeName => "script" );                                              # Create new Script element
  $Script->setAttribute( Name => "language", Value => "JavaScript" );                                    # Configure Script element
  my @Strings      = ();                                                                                 # Array of JavaScript
  my $DocTraversal = $TRAVERSAL->new();                                                                  # Get new traversal object...
  my $TreeWalker   = $DocTraversal->createTreeWalker( WhatToShow               => undef,                 # ... And spawn a Tree Walker object
                                                      Filter                   => sub {},
                                                      EntityReferenceExpansion => 0,
                                                      CurrentNode              => $I18N->{Catalogue} );  #
  my $callback = sub {                                                                                   # Prepare callback for TreeWalker
    my $Node = shift;
    if( $Node->nodeName() =~ m/set/i ) {
      my $lang = $Node->getAttribute( Name => "lang" );                                                  # Get lang attribute
      push( @Strings, qq(Strings["$lang"] = new Lang();) );                                              # Generate initialiser
      my $MiniTraverse = $TRAVERSAL->new();                                                              # Get new traversal object...
      my $MiniWalker   = $MiniTraverse->createTreeWalker( WhatToShow               => undef,             # Traverse the Set element
                                                          Filter                   => sub {},
                                                          EntityReferenceExpansion => 0,
                                                          CurrentNode              => $Node );           #
      $MiniWalker->walkTree( Node     => $Node,
                             Callback => sub {
                               my $mNode = shift;
                               if( $mNode->nodeName() =~ m/I18NString/i ) {
                                 my $lang    = $mNode->getAttribute( Name => "lang" );                   # Get lang attribute
                                 my $content = $mNode->getAttribute( Name => "content" );                # Get content attribute
                                 $A2H->hex2ascii( Data => \$content );
                                 $A2U->ascii2url( Data => \$content );
                                 push( @Strings, "Strings[\"$lang\"].add(\"$content\");" );              # Generate JavaScript
                               }
                               return(1);
                             } );
    }
  };
  $TreeWalker->walkTree( Node     => $I18N->{Catalogue},
                         Callback => $callback );
  my $Code    = $JavaScript;                                                                             # Make copy of JavaScript template
  my $Strings = join( "\n", @Strings );
  $Code       =~ s/<CODE>/$Strings/gis;                                                                  # Insert String array code into JavaScript
  $Script->appendChild( NewChild => $TEXT->new( NodeValue => $Code ) );                                  # Add Script to Widget
  $I18N->_removeScript();                                                                                # Remove old JavaScript code
  $I18N->{Widget}->appendChild( NewChild => $Script );                                                   # Add new JavaScript code to Widget
  return(1);
}


sub removeLang {
  # This method removes a language entry from the I18N Widget.
  return(1);
}


sub _removeScript {
  # This private method removes the old JavaScript code element.
  # Calls:
  #    none
  # Parameters Required:
  #    I18N
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $I18N         = shift;                                                                           # Get I18N object
  my %args         = @_;                                                                              # Get arguments
  my $DocTraversal = $TRAVERSAL->new();                                                               # Get new traversal object...
  my $TreeWalker   = $DocTraversal->createTreeWalker( WhatToShow               => undef,              # ... And spawn a Tree Walker object
                                                      Filter                   => sub {},
                                                      EntityReferenceExpansion => 0,
                                                      CurrentNode              => $I18N->{Widget} );
  $TreeWalker->walkTree( Node     => $I18N->{Widget},                                                 # Remove old JavaScript code
                         Callback => sub {
                           my $Node = shift;
                           if( $Node->nodeName() =~ m/^script$/i ) {
                             $I18N->{Widget}->removeChild( OldChild => $Node );
                           }
                           return(1);
                         } );
  return(1);
}


sub namespace {
  # This method returns the I18N namespace string.
  # Calls:
  #    none
  # Parameters Required:
  #    I18N
  # Result Returned:
  #    boolean
  # Example:
  #    my $namespace = $I18N->namespace();
  my $I18N = shift;      # Get I18N object
  return( $NAMESPACE );  # Return the namespace string
}


__DATA__


var Strings  = new Array(0);
var Language = new String();
var NavName  = new String( navigator.appName );
if( NavName.indexOf( "etscape" ) > 0 ) {
  Language = navigator.language;
} else if( NavName.indexOf( "xplorer" ) > 0 ) {
  Language = navigator.userLanguage;
} else {
  Language = navigator.language;
}


<CODE>


function Lang() {
  // This method is the Lang object constructor.
  var obj     = new Object;
  obj.strings = new Array;
  obj.length  = 0;
  obj.add     = new Function( "theString",
                              "this.strings[this.length] = new String(theString);\
                               this.length++;" );
  obj.get     = new Function( "index",
                              "return(unescape(this.strings[index]));" );
  return( obj );
}


function I18NString( index ) {
  // This function returns the string in the browser's language.
  var obj = Strings[Language] || Strings["default"];
  return( obj.get(index) );
}
