#!/usr/local/bin/perl
#
#   NetSoup::XHTML::MenuMaker::Drivers::Cascade.pm
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


package NetSoup::XHTML::MenuMaker::Drivers::Cascade;
use strict;
use NetSoup::XHTML::MenuMaker::Drivers::Cascade::CSS;
use NetSoup::XHTML::MenuMaker::Drivers;
use NetSoup::XHTML::MenuMaker::Drivers::Cascade::JavaScript;
use NetSoup::XML::DOM2::Core::Document;
use NetSoup::XML::File;
use NetSoup::XML::Parser;
@NetSoup::XHTML::MenuMaker::Drivers::Cascade::ISA = qw( NetSoup::XHTML::MenuMaker::Drivers );
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
  my $Cascade            = shift;                          # Get Cascade object
  my %args               = @_;                             # Get arguments
  $Cascade->{EmitJS}     = $args{EmitJS}     || 0;         # Emit JavaScript if set to true
  $Cascade->{CompressJS} = $args{CompressJS} || 0;         # Simple JavaScript compression if true
  $Cascade->{Stylesheet} = $args{Stylesheet} || "";        # Custom stylesheet
  $Cascade->{Hilite}     = $args{Hilite}     || "C10729";  # Highlighted menu item colour
  $Cascade->{Normal}     = $args{Normal}     || "444488";  # Un-highlighted menu item colour
  $Cascade->{Hints}      = [];
  $Cascade->SUPER::initialise;
  return( $Cascade );
}


sub build {
  my $Cascade   = shift;                                                                # Get Cascade object
  my %args      = @_;
  my $pathname  = $args{Pathname} || "MenuMaker.xml";
  my $outfile   = $args{Target}   || "MenuMaker.shtml";
  my $Spec      = NetSoup::XML::File->new()->load( Pathname => $pathname );             # Load XML Menu Specification
  my $Container = NetSoup::XML::DOM2::Core::Document->new( DocumentElement => "div" );  # In-memory XML menu document
  my $div       = $Container->createElement( TagName => "div" );
  $div->setAttribute( Name => "class", Value => "MMShell" );
  $Container->appendChild( NewChild => $div );
  if( defined $Spec ) {
    my $table = $Container->createElement( TagName => "table" );
    my $tr    = $Container->createElement( TagName => "tr" );
    #$table->setAttribute( Name => "border", Value => "0" );
    $table->setAttribute( Name => "class", Value => "MMc" );
    $table->setAttribute( Name => "cellpadding", Value => "0" );
    $table->setAttribute( Name => "cellspacing", Value => "0" );
    $div->appendChild( NewChild => $table );
    $table->appendChild( NewChild => $tr );
    my $NodeList = $Spec->getElementsByTagName( TagName => "item" );
    my $SubTable = $Cascade->topleveltable();
    my $SubTr    = $SubTable->getElementById( ElementId => "tr1" );
    $SubTr->removeChild( OldChild => $SubTable->getElementById( ElementId => "td1" ) );
    $div->appendChild( NewChild => $SubTable );
    for( my $i = 0 ; $i < $NodeList->nodeListLength() ; $i++ ) {
      my $Node  = $NodeList->item( Item => $i );
      my $Depth = $Node->nsNodeDepth();
      if( $Depth == 1 ) {
        print( STDERR " " . "  " x $Depth . $Node->getAttribute( Name => "name" ) . "\n" );
        my $td = $Container->createElement( TagName => "td" );
        $td->setAttribute( Name => "class",  Value => "MMc" );
        $td->setAttribute( Name => "valign", Value => "top" );
        if( $Node->getAttribute( Name => "href" ) ) {
          $td->setAttribute( Name  => "onClick",
                             Value => "MMj(\'" . $Node->getAttribute( Name => "href" ) . "\')" );
          $td->setAttribute( Name  => "onMouseOver",
                             Value => $td->getAttribute( Name => "onMouseOver" ) . "MMcc();" );
        }
        $td->setAttribute( Name  => "onMouseOver",
                           Value => $td->getAttribute( Name => "onMouseOver" ) . "MMh(this);" );
        $td->setAttribute( Name  => "onMouseOut",
                           Value => $td->getAttribute( Name => "onMouseOut" ) . "MMl(this);" );
        $td->appendChild( NewChild => $Container->createTextNode( Data => $Node->getAttribute( Name => "name", nsNBSP => 1 ) ) );
        if( $Node ->hasChildNodes() ) {
          my $id = $Cascade->uniqid();
          $td->setAttribute( Name  => "onMouseOver",
                             Value => $td->getAttribute( Name => "onMouseOver" ) . qq(MMsm($Depth,'$id');) );
          my $SubTd = $Container->createElement( TagName => "td" );
          $SubTd->setAttribute( Name => "valign", Value => "top" );
          $SubTr->appendChild( NewChild => $SubTd );
          $SubTd->appendChild( NewChild => $Cascade->createmenu( Spec      => $Spec,
                                                                 Container => $Container,
                                                                 pNode     => $Node,
                                                                 ID        => $id,
                                                                 Depth     => $Depth + 1 ) );
        }
        $tr->appendChild( NewChild => $td );
        my $spantd = $Container->createElement( TagName => "td" );
        my $span   = $Container->createElement( TagName => "span" );
        $SubTable->getElementById( ElementId => "placeholder" )->appendChild( NewChild => $spantd );
        $spantd->setAttribute( Name => "class",   Value => "MMph" );
        $spantd->setAttribute( Name => "onClick", Value => "MMcc();" );
        $spantd->setAttribute( Name => "valign",  Value => "top" );
        $spantd->appendChild( NewChild => $span );
        $span->appendChild( NewChild => $Container->createTextNode( Data => $Node->getAttribute( Name => "name", nsNBSP => 1 ) ) );
        $span->setAttribute( Name => "class", Value => "MMph" );
      }
    }
    $SubTable->getElementById( ElementId => "placeholder" )->removeAttribute( Name => "id" );
    $SubTable->getElementById( ElementId => "tr1" )->removeAttribute( Name => "id" );
  } else {
    print( STDERR qq(Error: Invalid XML Document in "$pathname"\n) );
    return( undef );
  }
  $Container->removeChild( OldChild => $Container->firstChild() );  # Remove the XML Processing Instruction
  if( $Cascade->{EmitJS} ) {
    my $JS = NetSoup::XML::DOM2::Core::Document->new( DocumentElement => "script" );  # In-memory XML menu document
    $Cascade->emit_css( JS => $JS );
    if( @{$Cascade->{Hints}} ) {
      $Cascade->emit_hints( Container => $Container, JS => $JS );
    }
    $Cascade->emit_js( Container => $Container, JS => $JS );
    $Cascade->write_js( JS => $JS, Pathname => $outfile );
  } else {
    $Cascade->inject_js( Container => $Container );
    $Cascade->inject_css( Container => $Container );
    $Cascade->write_xhtml( Container => $Container, Pathname => $outfile );
  }
  return(1);
}


sub createmenu {
  my $Cascade   = shift;             # Get Cascade object
  my %args      = @_;
  my $Spec      = $args{Spec};       # Containing document
  my $Container = $args{Container};  # Menu Container XML document
  my $pNode     = $args{pNode};      # Menu Container XML document
  my $ID        = $args{ID};
  my $Depth     = $args{Depth};        # Cascade depth
  my $Offset    = $args{Offset} || 0;  # Offset menu depth
  my $NodeList  = $pNode->getElementsByTagName( TagName => "item" );
  my $SubTable  = $Cascade->subtable();
  my $SubTr     = $SubTable->getElementById( ElementId => "tr1" );
  my $table     = $Container->createElement( TagName => "table" );
  #$table->setAttribute( Name => "border",      Value => "0" );
  $table->setAttribute( Name => "id",          Value => $ID );
  $table->setAttribute( Name => "class",       Value => "MMm" . ( $Depth - 1 ) );
  $table->setAttribute( Name => "cellpadding", Value => "0" );
  $table->setAttribute( Name => "cellspacing", Value => "0" );
  $SubTable->getElementById( ElementId => "td1" )->appendChild( NewChild => $table ); # Insert menu table into SubTable
  $table->appendChild( NewChild => $Cascade->padding( Padding => $Offset ) );
  my $offset = 0;
  for( my $i = 0 ; $i < $NodeList->nodeListLength() ; $i++ ) {
    my $Node  = $NodeList->item( Item => $i );
    if( $Depth == $Node->nsNodeDepth() ) {
      print( STDERR "R $offset" . "  " x $Depth . $Node->getAttribute( Name => "name" ) . "\n" );
      my $tr      = $Container->createElement( TagName => "tr" );
      my $tdLabel = $Container->createElement( TagName => "td" );
      $tdLabel->setAttribute( Name => "class", Value => "MMc" );
      $tdLabel->setAttribute( Name => "valign", Value => "top" );
      $tdLabel->setAttribute( Name  => "onMouseOver",
                              Value => $tdLabel->getAttribute( Name => "onMouseOver" ) . "MMh(this);" );
      $tdLabel->setAttribute( Name  => "onMouseOut",
                              Value => $tdLabel->getAttribute( Name => "onMouseOut" ) . "MMl(this);" );
      if( $Node->getAttribute( Name => "hint" ) ) {
        my $Hint = qq(<table id="__ID__" class="MMdesc"><tr><td>__HINT__</td></tr></table>);
        my $id = $Cascade->uniqid();
        $tdLabel->setAttribute( Name  => "onMouseOver",
                                Value => $tdLabel->getAttribute( Name => "onMouseOver" ) . qq(MMspd('$id');) );
        $tdLabel->setAttribute( Name  => "onMouseOut",
                                Value => $tdLabel->getAttribute( Name => "onMouseOut" ) . qq(MMhpd('$id');) );
        my $theHint = $Node->getAttribute( Name => "hint" );
        $Hint =~ s/__ID__/$id/gs;
        $Hint =~ s/__HINT__/$theHint/gs;
        push( @{$Cascade->{Hints}}, $Hint );
      }
      if( $Node->getAttribute( Name => "href" ) ) {
        $tdLabel->setAttribute( Name  => "onClick",
                                Value => "MMj(\'" . $Node->getAttribute( Name => "href" ) . "\')" );
        #$tdLabel->setAttribute( Name  => "onMouseOver",
        #                        Value => $tdLabel->getAttribute( Name => "onMouseOver" ) . qq(window.status=") . $Node->getAttribute( Name => "href" ) . qq(";) );
        #$tdLabel->setAttribute( Name  => "onMouseOut",
        #                        Value => $tdLabel->getAttribute( Name => "onMouseOut" ) . qq(window.status="";) );
      }
      $table->appendChild( NewChild => $tr );
      $tr->appendChild( NewChild => $tdLabel );
      $tdLabel->appendChild( NewChild => $Container->createTextNode( Data => $Node->getAttribute( Name => "name", nsNBSP => 1 ) ) );
      if( $Node->hasChildNodes() ) { # Generate Sub-Menus
        my $id    = $Cascade->uniqid();
        my $SubTd = $Container->createElement( TagName => "td" );
        $SubTd->setAttribute( Name => "valign", Value => "top" );
        $tdLabel->setAttribute( Name  => "onMouseOver",
                                Value => $tdLabel->getAttribute( Name => "onMouseOver" ) . qq(MMsm($Depth,'$id');) );
        $SubTr->appendChild( NewChild => $SubTd );
        $SubTd->appendChild( NewChild => $Cascade->createmenu( Spec      => $Spec,
                                                               Container => $Container,
                                                               pNode     => $Node,
                                                               ID        => $id,
                                                               Depth     => $Depth + 1,
                                                               Offset    => $Offset + $offset ) );
      } else {  # Insert Hyperlink
        $tdLabel->setAttribute( Name  => "onMouseOver",
                                Value => $tdLabel->getAttribute( Name => "onMouseOver" ) . qq(MMmc($Depth);) );
        $tdLabel->setAttribute( Name  => "onClick",
                                Value => "MMj(\'" . $Node->getAttribute( Name => "href" ) . "\')" );
      }
      $offset++;
    }
  }
  $SubTable->getElementById( ElementId => "tr1" )->removeAttribute( Name => "id" );
  $SubTable->getElementById( ElementId => "td1" )->removeAttribute( Name => "id" );
  $SubTable->getElementById( ElementId => "placeholder" )->removeAttribute( Name => "id" );
  return( $SubTable );
}


sub topleveltable {
  my $Cascade  = shift;
  my %args     = @_;
  my $Parser   = NetSoup::XML::Parser->new();
  my $subtable = qq(<table class="MMh" border="0" cellpadding="0" cellspacing="0" onClick="MMcc();"><tr id="tr1"><td valign="top" id="td1"></td></tr><tr id="placeholder" /></table>);
  return( $Parser->parse( XML => \$subtable ) );
}


sub subtable {
  my $Cascade  = shift;
  my %args     = @_;
  my $Parser   = NetSoup::XML::Parser->new();
  my $subtable = qq(<table class="MMh" border="0" cellpadding="0" cellspacing="0" onClick="MMcc();"><tr id="tr1"><td valign="top" id="td1"></td></tr><tr id="placeholder" /></table>);
  return( $Parser->parse( XML => \$subtable ) );
}


sub padding {
  my $Cascade = shift;
  my %args    = @_;
  my $Parser  = NetSoup::XML::Parser->new();
  my $padding = '<tr><td class="MMpd" valign="top">&nbsp;</td></tr>' x $args{Padding};
  return( $Parser->parse( XML => \$padding ) );
}


sub inject_js {
  # Create the JavaScript Element.
  my $Cascade    = shift;  # Get Cascade object
  my %args       = @_;
  my $Container  = $args{Container};
  my $JavaScript = NetSoup::XHTML::MenuMaker::Drivers::Cascade::JavaScript->new();
  my $Code       = $JavaScript->script();
  my $Script     = $Container->createElement( TagName => "script" );
  $Script->setAttribute( Name => "type", Value => "text/javascript" );
  $JavaScript->insertids( $Cascade->listids() );
  $Code =~ s/<!--HILITE-->/$Cascade->{Hilite}/gs;
  $Code =~ s/<!--NORMAL-->/$Cascade->{Normal}/gs;
  $Script->appendChild( NewChild => $Container->createTextNode( Data => "\n<!--\n$Code\n//-->\n" ) );
  $Container->insertBefore( NewChild => $Script, RefChild => $Container->firstChild() );
  return(1);
}


sub emit_js {
  # Emit pure JavaScript.
  my $Cascade    = shift;  # Get Cascade object
  my %args       = @_;
  my $Container  = $args{Container};
  my $JS         = $args{JS};
  my $JavaScript = NetSoup::XHTML::MenuMaker::Drivers::Cascade::JavaScript->new();
  my $Code       = $JavaScript->script();
  my $XML        = NetSoup::XML::File->new()->serialise( Document => $Container,
                                                         Compact  => 1,
                                                         OmitPI   => 1 );
  $XML           =~ s/([\'])/\\$1/gs; # Escape single-quotes in JavaScript string
  if( $Cascade->{CompressJS} ) { # "Compress" XHTML Segment
    $XML =~ s/ onMouseOver=/ 1=/gs;
    $XML =~ s/ onMouseOut=/ 2=/gs;
    $XML =~ s/ onClick=/ 3=/gs;
    $XML =~ s/ cellpadding=/ 4=/gs;
    $XML =~ s/ cellspacing=/ 5=/gs;
    $XML =~ s/ border=/ 6=/gs;
    $XML =~ s/ class=/ 7=/gs;
    $XML =~ s/ valign=/ 8=/gs;
    $XML =~ s/\(this\)/\(x\)/gs;
  }
  $JS->appendChild( NewChild => $JS->createTextNode( Data => "var theHTML = new String(\'" . $XML . "\');" ) );
  if( $Cascade->{CompressJS} ) { # "Decompress" XHTML Segment in JavaScript
    $JS->appendChild( NewChild => $JS->createTextNode( Data => qq(theHTML = new String(theHTML.replace(/ 1=/g," onMouseOver="));) ) );
    $JS->appendChild( NewChild => $JS->createTextNode( Data => qq(theHTML = new String(theHTML.replace(/ 2=/g," onMouseOut="));) ) );
    $JS->appendChild( NewChild => $JS->createTextNode( Data => qq(theHTML = new String(theHTML.replace(/ 3=/g," onClick="));) ) );
    $JS->appendChild( NewChild => $JS->createTextNode( Data => qq(theHTML = new String(theHTML.replace(/ 4=/g," cellpadding="));) ) );
    $JS->appendChild( NewChild => $JS->createTextNode( Data => qq(theHTML = new String(theHTML.replace(/ 5=/g," cellspacing="));) ) );
    $JS->appendChild( NewChild => $JS->createTextNode( Data => qq(theHTML = new String(theHTML.replace(/ 6=/g," border="));) ) );
    $JS->appendChild( NewChild => $JS->createTextNode( Data => qq(theHTML = new String(theHTML.replace(/ 7=/g," class="));) ) );
    $JS->appendChild( NewChild => $JS->createTextNode( Data => qq(theHTML = new String(theHTML.replace(/ 8=/g," valign="));) ) );
    $JS->appendChild( NewChild => $JS->createTextNode( Data => qq(theHTML = new String(theHTML.replace(/\\(x\\)/g,"(this)"));) ) );
  }
  $JS->appendChild( NewChild => $JS->createTextNode( Data => "document.write(theHTML);" ) );
  $Code =~ s/<!--HILITE-->/$Cascade->{Hilite}/gs;
  $Code =~ s/<!--NORMAL-->/$Cascade->{Normal}/gs;
  $JS->appendChild( NewChild => $JS->createTextNode( Data => $Code ) );
  return(1);
}


sub inject_css {
  # Create the CSS Element.
  my $Cascade   = shift;  # Get Cascade object
  my %args  = @_;
  my $Container = $args{Container};
  my $CSS   = NetSoup::XHTML::MenuMaker::Drivers::Cascade::CSS->new();
  my $Style = $Container->createElement( TagName => "style" );
  $Style->setAttribute( Name => "type", Value => "text/css" );
  $Style->appendChild( NewChild => $Container->createTextNode( Data => "\n<!--\n" . $Cascade->{Stylesheet} || $CSS->css() . "\n-->\n" ) );
  $Container->insertBefore( NewChild => $Style, RefChild => $Container->firstChild() );
  return(1);
}


sub emit_css {
  # Create the CSS Element.
  my $Cascade   = shift;  # Get Cascade object
  my %args  = @_;
  my $JS    = $args{JS};
  my $CSS   = NetSoup::XHTML::MenuMaker::Drivers::Cascade::CSS->new();
  my $Style = $Cascade->{Stylesheet} || $CSS->css();
  $Style    =~ s/[\r\n]+/\\n/gs;
  $Style    =~ s/[ \t]+/ /gs;
  $JS->appendChild( NewChild => $JS->createTextNode( Data => "document.write(\'<style type=\\\"text/css\\\">$Style</style>\');\n" ) );
  return(1);
}


sub emit_hints {
  # Emit pure JavaScript.
  my $Cascade   = shift;  # Get Cascade object
  my %args      = @_;
  my $Container = $args{Container};
  my $JS        = $args{JS};
  my $HTML      = join( "", @{$Cascade->{Hints}} );
  $HTML         =~ s/([\'])/\\$1/gs; # Escape single-quotes in JavaScript string
  $HTML         =~ s/[\s]+/ /gs;
  $JS->appendChild( NewChild => $JS->createTextNode( Data => "var theHints = new String(\'" . $HTML . "\');" ) );
  $JS->appendChild( NewChild => $JS->createTextNode( Data => "document.write(theHints);" ) );
  return(1);
}


sub write_xhtml {
  # Write the Finished XML Document
  my $Cascade   = shift;  # Get Cascade object
  my %args      = @_;
  my $Container = $args{Container};
  if( ! NetSoup::XML::File->new()->save( Pathname => $args{Pathname},
                                         Document => $Container,
                                         OmitPI   => 1,
                                         Compact  => 1,
                                         Beautify => 0 ) ) {
    print( STDERR "Error\n" );
  }
  return(1);
}


sub write_js {
  # Write the Finished XML Document
  my $Cascade  = shift;                                                # Get Cascade object
  my %args = @_;
  my $JS   = $args{JS};
  $JS->removeChild( OldChild => $JS->firstChild() );                   # Remove the XML Processing Instruction
  if( ! NetSoup::XML::File->new()->save( Pathname => $args{Pathname},
                                         Document => $JS ) ) {
    print( STDERR "Error\n" );
  }
  return(1);
}
