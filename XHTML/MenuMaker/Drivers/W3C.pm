#!/usr/local/bin/perl
#
#   NetSoup::XHTML::MenuMaker::Drivers::W3C.pm
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


package NetSoup::XHTML::MenuMaker::Drivers::W3C;
use strict;
use NetSoup::XHTML::MenuMaker::Drivers::W3C::CSS;
use NetSoup::XHTML::MenuMaker::Drivers;
use NetSoup::XHTML::MenuMaker::Drivers::W3C::JavaScript;
use NetSoup::XML::DOM2::Core::Document;
use NetSoup::XML::File;
use NetSoup::XML::Parser;
@NetSoup::XHTML::MenuMaker::Drivers::W3C::ISA = qw( NetSoup::XHTML::MenuMaker::Drivers );
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
  #    method call
  my $W3C            = shift;                         # Get W3C object
  my %args           = @_;                            # Get arguments
  $W3C->{EmitJS}     = $args{EmitJS}     || 0;        # Emit JavaScript if set to true
  $W3C->{CompressJS} = $args{CompressJS} || 0;        # Simple JavaScript compression if true
  $W3C->{Method}     = $args{Method}     || "hover";  # Access method: hover|click
  $W3C->SUPER::initialise;
  return( $W3C );
}


sub build {
  my $W3C      = shift;                                                                # Get W3C object
  my %args     = @_;
  my $pathname = $args{Pathname} || "MenuMaker.xml";
  my $outfile  = $args{Target}   || "MenuMaker.html";
  my $Document = NetSoup::XML::File->new()->load( Pathname => $pathname );
  my $Shell    = NetSoup::XML::DOM2::Core::Document->new( DocumentElement => "div" );  # In-memory XML menu document
  if( defined $Document ) {
    $W3C->traverse( Shell    => $Shell,
                    Document => $Document,
                    ID       => "MMShell",
                    Level    => 1 );
    my $DIV      = $Shell->getElementById( ElementId => "MMShell" );
    my $Table    = $Shell->createElement( TagName => "table" );
    my $TBody    = $Shell->createElement( TagName => "tbody" );
    my $TR       = $Shell->createElement( TagName => "tr" );
    my $NodeList = $DIV->getElementsByTagName( TagName => "td" );
    $Table->setAttribute( Name => "class", Value => "MM1" );
    $DIV->replaceChild( OldChild => $DIV->firstChild(),
                        NewChild => $Table );
    for( my $i = 0 ; $i < $NodeList->nodeListLength() ; $i++ ) {
      $TR->appendChild( NewChild => $NodeList->item( Item => $i ) );
    }
    $Table->appendChild( NewChild => $TBody );
    $TBody->appendChild( NewChild => $TR );
    { # Remove arrow images from top level
      my $NodeList = $DIV->getElementsByTagName( TagName => "img" );
      for( my $i = 0 ; $i < $NodeList->nodeListLength() ; $i++ ) {
        $NodeList->item( Item => $i )->parentNode->removeChild( OldChild => $NodeList->item( Item => $i ) );
      }
    }
  } else {
    print( STDERR "Error: Invalid XML Document\n" );
    return( undef );
  }
  $Shell->removeChild( OldChild => $Shell->firstChild() );                            # Remove the XML Processing Instruction
  if( $W3C->{EmitJS} ) {                                                              # Emit JavaScript code fragment
    my $JS = NetSoup::XML::DOM2::Core::Document->new( DocumentElement => "script" );  # In-memory XML menu document
    $W3C->emit_css( JS => $JS );
    $W3C->emit_js( Shell => $Shell, JS => $JS );
    $W3C->write_js( JS => $JS, Pathname => $outfile );
  } else {                                                                            # Emit static XHTML/CSS/JavaScript
    $W3C->inject_js( Shell => $Shell );
    $W3C->inject_css( Shell => $Shell );
    $W3C->write_xhtml( Shell => $Shell, Pathname => $outfile );
  }
  return(1);
}


sub traverse {
  my $W3C             = shift;           # Get W3C object
  my %args            = @_;
  my $Shell           = $args{Shell},    # Menu shell XML document
  my $Document        = $args{Document}; # Containing document
  my $ID              = $args{ID} || "";
  my $Level           = $args{Level};
  my $NodeList        = $Document->getElementsByTagName( TagName => "item" );
  my ( $DIV, $TBody ) = $W3C->create_div( Shell => $Shell, Level => $Level );
  if( $ID ) {
    $DIV->setAttribute( Name => "id", Value => $ID );
  }
  for( my $i = 0 ; $i < $NodeList->nodeListLength() ; $i++ ) {
    my $Node = $NodeList->item( Item => $i );
    if( $Node->nodeIndent() == $Level ) {
      print( STDERR "  " x $Level . $Node->getAttribute( Name => "name" ) . "\n" );
      my $id     = $W3C->uniqid();
      my $Action = "";
      my $Flag   = 0;


      if( $Node->hasChildNodes() ) {
        $Action = "sm" . ( $Level + 1 ) . qq(('$id'));  # Open next level nested menu
      } else {
        $Action = "hm" . ( $Level ) . qq(('$id'));      # Hide next level nested menu if leaf item
      }


      if( $Node->hasChildNodes() ) {
        $Flag = 1;
      }
      $TBody->appendChild( NewChild => $W3C->create_button( Document => $Shell,
                                                            Text     => $Node->getAttribute( Name => "name" ),
                                                            HREF     => $Node->getAttribute( Name => "href" ) || "javascript:MMnv()",
                                                            Action   => $Action,
                                                            Flag     => $Flag,
                                                            Style    => $Node->getAttribute( Name => "style" ) || "" ) );
      if( $Node->hasChildNodes() ) {
        $W3C->traverse( Shell    => $Shell,
                        Document => $Node,
                        ID       => $id,
                        Level    => $Level + 1 );
      }
    }
  }
  $Shell->appendChild( NewChild => $DIV );
  return(1);
}


sub create_div {
  my $W3C   = shift;  # Get W3C object
  my %args  = @_;
  my $Shell = $args{Shell};
  my $Level = $args{Level};
  my $DIV   = $Shell->createElement( TagName => "div" );
  my $Table = $Shell->createElement( TagName => "table" );
  my $TBody = $Shell->createElement( TagName => "tbody" );
  $DIV->setAttribute( Name => "id",    Value => $W3C->uniqid() );
  $DIV->setAttribute( Name => "class", Value => "MM" . $Level );
  $DIV->appendChild( NewChild => $Table );
  $Table->setAttribute( Name => "class",  Value => "MMMenu" );
  $Table->appendChild( NewChild => $TBody );
  return( $DIV, $TBody );
}


sub create_button {
  my $W3C      = shift;                                        # Get W3C object
  my %args     = @_;
  my $Document = $args{Document};
  my $HREF     = $args{HREF}   || "javascript:MMnv()";         # Real URL, or dummy JavaScript psuedo-URL
  my $Action   = $args{Action} || "";                          # Action opens nested menu levels
  my $Flag     = $args{Flag}   || 0;
  my $Text     = $args{Text};                                  # Menu item label
  my $Style    = $args{Style} || "";                           # Optional CSS style
  my $tr       = $Document->createElement( TagName => "tr" );
  my $td       = $Document->createElement( TagName => "td" );  # Create TD Element
  $td->setAttribute( Name => "class", Value => "MM" );
  {


    if( $W3C->{Method} eq "click" ) {
      ###########################
      #  "click" Access Method  #
      ###########################
      $td->setAttribute( Name => "onMouseOver", Value => "MMhc(this)" );
      $td->setAttribute( Name => "onMouseOut",  Value => "MMrc(this)" );
      if( $Action ) {
        $td->setAttribute( Name => "onClick", Value => $Action );
      } else {
        if( $HREF ne "javascript:MMnv()" ) {
          $td->setAttribute( Name => "onClick", Value => "MMj(\'$HREF\')" );
        }
      }
    } else {
      ###########################
      #  "hover" Access Method  #
      ###########################


      if( $Action ) {
        $td->setAttribute( Name => "onMouseOver", Value => "MMhc(this);$Action" );  # Highlight menu item and run action
      } else {
        if( $HREF ne "javascript:MMnv()" ) {
          $td->setAttribute( Name => "onClick", Value => "MMj(\'$HREF\')" );
        }
      }
      $td->setAttribute( Name => "onMouseOut",  Value => "MMrc(this)" );





    }
  }
  if( $Style ) {
    $td->setAttribute( Name => "Style", Value => $Style );
  }
  $tr->appendChild( NewChild => $td );
  # Create A Element
  my $a = $Document->createElement( TagName => "a" );
  $a->setAttribute( Name => "class", Value => "MMB" );
  $a->setAttribute( Name => "href",  Value => $HREF );




  {
    #########################
    #  Hide/Show Sub-Menus  #
    #########################
    if( $W3C->{Method} eq "click" ) {
      if( $Action ) {
        $a->setAttribute( Name => "onClick", Value => $Action );
      }
    } else {
      if( $Action ) {
        $a->setAttribute( Name => "onMouseOver", Value => $Action );
      }
    }
  }




  $td->appendChild( NewChild => $a );
  # Create Text Node Element
  my $text = $Document->createTextNode( Data => $Text );
  $a->appendChild( NewChild => $text );
  if( $Flag ) {
    # Refer to the NetSoup::Apache::Images::MenuMaker::Icon module
    my $img = $Document->createElement( TagName => "img" );
    $img->setAttribute( Name => "src", Value => "/MenuMaker/Icon" );
    $td->appendChild( NewChild => $img );
  }
  return( $tr );
}


sub inject_js {
  # Create the JavaScript Element.
  my $W3C        = shift;  # Get W3C object
  my %args       = @_;
  my $Shell      = $args{Shell};
  my $JavaScript = NetSoup::XHTML::MenuMaker::Drivers::W3C::JavaScript->new();
  my $Script     = $Shell->createElement( TagName => "script" );
  $Script->setAttribute( Name => "type", Value => "text/javascript" );
  $Script->appendChild( NewChild => $Shell->createTextNode( Data => "\n<!--\n" . $JavaScript->script() . "\n//-->\n" ) );
  $Shell->insertBefore( NewChild => $Script, RefChild => $Shell->firstChild() );
  return(1);
}


sub emit_js {
  # Emit pure JavaScript.
  my $W3C        = shift;  # Get W3C object
  my %args       = @_;
  my $Shell      = $args{Shell};
  my $JS         = $args{JS};
  my $JavaScript = NetSoup::XHTML::MenuMaker::Drivers::W3C::JavaScript->new();
  my $XML        = NetSoup::XML::File->new()->serialise( Document => $Shell, Compact => 1 );
  $XML           =~ s/([\'])/\\$1/gs; # Escape single-quotes in JavaScript string
  if( $W3C->{CompressJS} ) { # "Compress" XHTML Segment
    $XML =~ s/ class=/ C=/gs;
    $XML =~ s/ href=/ H=/gs;
    $XML =~ s:"/MenuMaker/Icon":"ICN":gs;
    $XML =~ s/ onMouseOver=/ M1=/gs;
    $XML =~ s/ onMouseOut=/ M2=/gs;
    $XML =~ s/ onClick=/ M3=/gs;
    $XML =~ s/\(this\)/\(T\)/gs;
    { # Second Level Compression
      $XML =~ s:<img src="ICN" />:!x1:gs;
      $XML =~ s/ M1="MMhc\(T\)" / !1 /gs;
      $XML =~ s/ M2="MMrc\(T\)" / !2 /gs;
      $XML =~ s/ C="MMB"/ !3 /gs;
      $XML =~ s/ C="MM"/ !4 /gs;
      $XML =~ s/ C="MMMenu"/ !5 /gs;
      $XML =~ s/ C="MM1"/ !7 /gs;
      $XML =~ s/ C="MM2"/ !8 /gs;
      $XML =~ s/ C="MM3"/ !9 /gs;
      $XML =~ s/ C="MM4"/ !10 /gs;
    }
  }
  $JS->appendChild( NewChild => $JS->createTextNode( Data => "var theHTML = new String(\'" . $XML . "\');" ) );
  if( $W3C->{CompressJS} ) { # "Decompress" XHTML Segment in JavaScript
    { # Second Level Decompression
      $JS->appendChild( NewChild => $JS->createTextNode( Data => qq(theHTML = new String(theHTML.replace(/!x1/g,"<img src=\\\"ICN\\\" />"));) ) );
      $JS->appendChild( NewChild => $JS->createTextNode( Data => qq(theHTML = new String(theHTML.replace(/ !1 /g," M1=\\\"MMhc(T)\\\" "));) ) );
      $JS->appendChild( NewChild => $JS->createTextNode( Data => qq(theHTML = new String(theHTML.replace(/ !2 /g," M2=\\\"MMrc(T)\\\" "));) ) );
      $JS->appendChild( NewChild => $JS->createTextNode( Data => qq(theHTML = new String(theHTML.replace(/ !3 /g," C=\\\"MMB\\\" "));) ) );
      $JS->appendChild( NewChild => $JS->createTextNode( Data => qq(theHTML = new String(theHTML.replace(/ !4 /g," C=\\\"MM\\\" "));) ) );
      $JS->appendChild( NewChild => $JS->createTextNode( Data => qq(theHTML = new String(theHTML.replace(/ !5 /g," C=\\\"MMMenu\\\" "));) ) );
      $JS->appendChild( NewChild => $JS->createTextNode( Data => qq(theHTML = new String(theHTML.replace(/ !7 /g," C=\\\"MM1\\\""));) ) );
      $JS->appendChild( NewChild => $JS->createTextNode( Data => qq(theHTML = new String(theHTML.replace(/ !8 /g," C=\\\"MM2\\\""));) ) );
      $JS->appendChild( NewChild => $JS->createTextNode( Data => qq(theHTML = new String(theHTML.replace(/ !9 /g," C=\\\"MM3\\\""));) ) );
      $JS->appendChild( NewChild => $JS->createTextNode( Data => qq(theHTML = new String(theHTML.replace(/ !10 /g," C=\\\"MM4\\\""));) ) );
    }
    $JS->appendChild( NewChild => $JS->createTextNode( Data => qq(theHTML = new String(theHTML.replace(/ C=/g," class="));) ) );
    $JS->appendChild( NewChild => $JS->createTextNode( Data => qq(theHTML = new String(theHTML.replace(/ H=/g," href="));) ) );
    $JS->appendChild( NewChild => $JS->createTextNode( Data => qq(theHTML = new String(theHTML.replace(/\\\"ICN\\\"/g,"\\\"/MenuMaker/Icon\\\""));) ) );
    $JS->appendChild( NewChild => $JS->createTextNode( Data => qq(theHTML = new String(theHTML.replace(/ M1=/g," onMouseOver="));) ) );
    $JS->appendChild( NewChild => $JS->createTextNode( Data => qq(theHTML = new String(theHTML.replace(/ M2=/g," onMouseOut="));) ) );
    $JS->appendChild( NewChild => $JS->createTextNode( Data => qq(theHTML = new String(theHTML.replace(/ M3=/g," onClick="));) ) );
    $JS->appendChild( NewChild => $JS->createTextNode( Data => qq(theHTML = new String(theHTML.replace(/\\(T\\)/g,"(this)"));) ) );
  }
  $JS->appendChild( NewChild => $JS->createTextNode( Data => "document.write(theHTML);" ) );
  $JS->appendChild( NewChild => $JS->createTextNode( Data => $JavaScript->script() ) );
  return(1);
}


sub inject_css {
  # Create the CSS Element.
  my $W3C   = shift;  # Get W3C object
  my %args  = @_;
  my $Shell = $args{Shell};
  my $CSS   = NetSoup::XHTML::MenuMaker::Drivers::W3C::CSS->new();
  my $Style = $Shell->createElement( TagName => "style" );
  $Style->setAttribute( Name => "type", Value => "text/css" );
  $Style->appendChild( NewChild => $Shell->createTextNode( Data => "\n<!--\n" . $CSS->css() . "\n-->\n" ) );
  $Shell->insertBefore( NewChild => $Style, RefChild => $Shell->firstChild() );
  return(1);
}


sub emit_css {
  # Create the CSS Element.
  my $W3C   = shift;  # Get W3C object
  my %args  = @_;
  my $JS    = $args{JS};
  my $CSS   = NetSoup::XHTML::MenuMaker::Drivers::W3C::CSS->new();
  my $Style = $CSS->css();
  $Style    =~ s/[\r\n]+/\\n/gs;
  $Style    =~ s/[ \t]+/ /gs;
  $JS->appendChild( NewChild => $JS->createTextNode( Data => "document.write(\'<style type=\\\"text/css\\\">$Style</style>\')\n" ) );
  return(1);
}


sub write_xhtml {
  # Write the Finished XML Document
  my $W3C   = shift;  # Get W3C object
  my %args  = @_;
  my $Shell = $args{Shell};
  if( ! NetSoup::XML::File->new()->save( Pathname => $args{Pathname},
                                         Document => $Shell,
                                         Compact  => 1 ) ) {
    print( STDERR "Error\n" );
  }
  return(1);
}


sub write_js {
  # Write the Finished XML Document
  my $W3C  = shift;                                                    # Get W3C object
  my %args = @_;
  my $JS   = $args{JS};
  $JS->removeChild( OldChild => $JS->firstChild() );                   # Remove the XML Processing Instruction
  if( ! NetSoup::XML::File->new()->save( Pathname => $args{Pathname},
                                         Document => $JS ) ) {
    print( STDERR "Error\n" );
  }
  return(1);
}
