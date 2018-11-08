#!/usr/local/bin/perl
#
#   NetSoup::XML::GUI::ViewEdit.pm v00.00.01a 12042000
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
#       method  -  description


package NetSoup::XML::GUI::ViewEdit;
use strict;
use Tk;
use Tk::HList;
use Tk::Tree;
use Tk::Toplevel;
use NetSoup::Core;
use NetSoup::XML::Parser;
use NetSoup::XML::DOM2::Traversal::DocumentTraversal;
use NetSoup::Files::Load;
use NetSoup::Files::Save;
@NetSoup::XML::GUI::ViewEdit::ISA = qw( NetSoup::Core );
my $LOAD = NetSoup::Files::Load->new();
my $SAVE = NetSoup::Files::Save->new();
1;


sub initialise {
  # This method creates a new XML viewedit widget.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash {
  #           Window   => $MW
  #           Pathname => $pathname
  #         }
  # Result Returned:
  #    boolean
  # Example:
  #    $ViewEdit->initialise( Window => $MW, Pathname => $pathname );
  my $ViewEdit          = shift;                                                                        # Get object
  my %args              = @_;                                                                           # Get method arguments
  my $Traverser         = NetSoup::XML::DOM2::Traversal::DocumentTraversal->new();                   # Get new traversal object...
  my $separator         = "/";                                                                          # Separator variable for ViewEdit object
  $ViewEdit->{PWindow}  = $args{Window};                                                                # Get parent window
  $ViewEdit->{Pathname} = $args{Pathname};                                                              # Get document pathname
  
  
  
  
  $ViewEdit->{State}    = { NodeList => {},                                                             # State hash
                            Selected => undef };
  $ViewEdit->{NodeList}    = [];# List of references to Document Nodes
  
  
  
  
  $ViewEdit->{XML}      = "";                                                              # Get document pathname
  $LOAD->load( Pathname => $ViewEdit->{Pathname},
               Data     => \$ViewEdit->{XML} );
  my $Parser            = NetSoup::XML::Parser->new();
  
  
  
  
  
  $ViewEdit->{Document} = $Parser->parse( XML        => \$ViewEdit->{XML},
                                          Whitespace => "preserve" );
  my $Window            = $ViewEdit->{PWindow}->Toplevel( -title  => $ViewEdit->{Pathname},                                        # Create new top level window
                                                          -width  => 600,
                                                          -height => 440 );
  my $Controls          = $Window->Frame();
  my $Commit            = $Controls->Button( -text    => "Commit",
                                             -command => sub {
                                               my $target    = "";
                                               my $Serialise = $Traverser->createSerialise( Node                     => $ViewEdit->{Document},        # ... And spawn a Tree Walker object
                                                                                            WhatToShow               => undef,
                                                                                            Filter                   => undef,
                                                                                            EntityReferenceExpansion => 0 );
                                               
                                               
                                               
                                               
                                               foreach my $Pair ( @{$ViewEdit->{NodeList}} ) {# Iterate over NodeList pairs
                                                 
                                                 
                                                 
                                               }
                                               
                                               
                                               
                                               
                                               
                                               
                                               #                                               if( defined $ViewEdit->{State}->{Selected} ) {
                                               #                                                 my $string = $TextArea->get( "0.0", "end" );
                                               #                                                  chomp( $string );
                                               #                                                  $ViewEdit->{State}->{Selected}->nodeValue( NodeValue => $string );
                                               #                                               }
                                               $Serialise->serialise( Node   => $ViewEdit->{Document},
                                                                      Target => \$target );
                                               $SAVE->save( Pathname => $ViewEdit->{Pathname},
                                                            Data     => \$target );
                                               return(1);
                                             } );
  my $ScrlTree = $Window->ScrlTree( -drawbranch => 1,                                        # Create new scrolling Tree view object
                                    -header     => 1,
                                    -indicator  => 1,
                                    -itemtype   => "window",
                                    -selectmode => "single",
                                    -separator  => $separator,
                                    -browsecmd  => sub {
                                      my $path = shift;
                                      my $Node = $ViewEdit->{State}->{NodeList}->{$path} || return(1);
                                      if( defined $ViewEdit->{State}->{Selected} ) {
#                                         my $string = $TextArea->get( "0.0", "end" );
#                                         chomp( $string );
#                                         $ViewEdit->{State}->{Selected}->nodeValue( NodeValue => $string );
                                      }
                                      $ViewEdit->{State}->{Selected} = $Node;
#                                      $TextArea->delete( "0.0", "end" );
#                                       $TextArea->insert( "0.0", $Node->nodeValue() );
                                      return(1);
                                    } );




  my $TextArea = sub {                                              # Create new text area widget
    my %param  = @_;
    my $node   = $param{Node};
    my $Value  = $param{Value};
    my $width  = 40;
    my $height = ( length( $Value ) / $width ) + 1;
    my $TA     = $ScrlTree->Text( -width  => $width,
                                  -height => $height,
                                  -wrap   => "word" );
    $TA->insert( "0.0", $Value );
    push( @{$ViewEdit->{NodeList}}, [ $node, $TA ] );
    return( $TA );
  };




  my $TreeWalker = $Traverser->createTreeWalker( Node                     => $ViewEdit->{Document},        # ... And spawn a Tree Walker object
                                                 WhatToShow               => undef,
                                                 Filter                   => undef,
                                                 EntityReferenceExpansion => 0 );
   my $callback = sub {                                                                          # Configure Tree Walker callback
    my $Node = shift;
    my $Copy = $Node;
    my $path = $separator . $Node;
  PARENT: for(;;) {
      $Copy = $Copy->parentNode();
      if( defined $Copy ) {
        $path = $separator . $Copy . $path;
      } else {
        last PARENT;
      }
    }
  SWITCH: for( $Node->nodeName() || "<void>" ) {
      m/TEXT_NODE/i && do {


        $ViewEdit->{State}->{NodeList}->{$path} = $Node;


        $ScrlTree->add( $path,                            # Add new branch to tree
                        -widget => &$TextArea( Node  => $Node,
                                               Value => $Node->nodeValue() ) );
        last SWITCH;
      };
      m/<void>/i && do {
        last SWITCH;
      };
      m//i && do {
        $ScrlTree->add( $path,                            # Add new branch to tree
                        -itemtype => "text",
                        -text     => $Node->nodeName() );
        last SWITCH;
      };
    }
  };
  $ScrlTree->add( $separator,                            # Add new branch to tree
                  -itemtype => "text",
                  -text     => "DOCUMENT" );
  $TreeWalker->walkTree( Node     => $ViewEdit->{Document},                                                 # Walk the Document Object Model tree
                         Callback => $callback );
  $ScrlTree->autosetmode();
  $ScrlTree->pack( -anchor => "n",
                   -expand => 1,
                   -fill   => "both",
                   -side   => "top" );
  $Controls->pack( -anchor => "s",
                   -expand => 0,
                   -fill   => "x",
                   -side   => "bottom" );
  $Commit->pack( -anchor => "n",
                 -expand => 0,
                 -fill   => "both",
                 -side   => "bottom" );
  return( $ViewEdit );
}
