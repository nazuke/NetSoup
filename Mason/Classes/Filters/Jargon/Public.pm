#!/usr/local/bin/perl -w

package NetSoup::Mason::Classes::Filters::Jargon::Public;
use strict;
use XML::DOM;
use NetSoup::Apache;
use NetSoup::Files::Load;
use NetSoup::Util::Sort::Length;
use NetSoup::Encoding::Hex;
use NetSoup::XML::TreeClimber;
use NetSoup::XHTML::MenuMaker::Drivers;
use NetSoup::Mason::Classes::Filters::Jargon::JS;
@NetSoup::Mason::Classes::Filters::Jargon::Public::ISA = qw( NetSoup::Apache );
my $LOAD = NetSoup::Files::Load->new();
my $HEX  = NetSoup::Encoding::Hex->new();
1;


sub initialise {
  my $Jargon         = shift;
  my %args           = @_;
  my $r              = $args{R};
  $Jargon->{HASH}    = {};
  $Jargon->{SORTED}  = [];
  $Jargon->{Drivers} = NetSoup::XHTML::MenuMaker::Drivers->new();
  {
    if ( ! -e $r->dir_config( "FILTER_JARGON_STRINGS" ) ) {
      return( undef );
    } else {
    STRINGS: foreach my $string ( split( m/[\r\n]/, $LOAD->immediate( Pathname => $r->dir_config( "FILTER_JARGON_STRINGS" ) ) ) ) {
        next STRINGS if( ( $string =~ m/^\#/ ) || ( $string =~ m/^[ \t]*$/ ) );
        my ( $key, $value ) = ( $string =~ m/^([^\t]+)\t+([^\t]+)$/s );
        $Jargon->{HASH}->{$key} = $value;
      }
    }
  }
  {
    my $Sort     = NetSoup::Util::Sort::Length->new();
    my @unsorted = keys %{$Jargon->{HASH}};
    $Sort->sort4( Array => \@unsorted, Target => $Jargon->{SORTED} );
  }
  return( $Jargon );
}


sub definitions {
  my $Jargon  = shift;
  my $r       = shift;
  my $J       = NetSoup::Mason::Classes::Filters::Jargon::Public->new( R => $r );
  return( $J->render_definitions( R => $r ) );
}


sub render_definitions {
  my $Jargon   = shift;
  my %args     = @_;
  my $r        = $args{R};
  my $rendered = <<END_STYLE;
<style type="text/css">
  <!--
    table.JGDEF {
      position:            absolute;
      top:                 0px;
      left:                0px;
      display:             none;
      font-family:         sans-serif;
      font-size:           10pt;
      background-color:    #EEEEFF;
      color:               #000088;
      border-top-color:    #FFFFFF;
      border-left-color:   #AAAAAA;
      border-right-color:  #444444;
      border-bottom-color: #222222;
      border-style:        solid;
      border-width:        1px;
      padding:             6px;
    }
    span.JGDEF {
      border-bottom-style: dotted;
      border-bottom-color: #FF0000;
      border-bottom-width: 2px;
    }
  //-->
</style>
END_STYLE
  ;
 INSERT: foreach my $key ( @{$Jargon->{SORTED}} ) {
    next INSERT if( ( ! $key ) || ( ! $Jargon->{HASH}->{$key} ) );
    my $table  = qq(<table class="JGDEF" id="__ID__"><tr><td>__JARGON__</td></tr></table>);
    my $id     = "JG" . $HEX->bin2hex( Data => $key );
    $table     =~ s/__ID__/$id/gs;
    $table     =~ s/__JARGON__/$Jargon->{HASH}->{$key}/gs;
    $rendered .= $table;
  }
  return( $rendered );
}


sub filter {
  my $Jargon   = shift;
  my $r        = shift;
  my $Document = shift;
  my $J        = NetSoup::Mason::Classes::Filters::Jargon::Public->new( R => $r );
  return( $J->jargon( R => $r, Document => $Document ) );
}


sub jargon {
  my $Jargon   = shift;
  my %args     = @_;
  my $r        = $args{R};
  my $Document = $args{Document};
  if ( -e $r->dir_config( "FILTER_JARGON_STRINGS" ) ) {
    $Jargon->render_filter( R        => $r,
                            Document => $Document );
  } else {
    $r->warn( qq(ERROR: ") . $r->dir_config( "FILTER_JARGON_STRINGS" ) . qq(" File not Found) );
    return( undef );
  }
  return(1);
}


sub render_filter {
  my $Jargon      = shift;
  my %args        = @_;
  my $r           = $args{R};
  my $Document    = $args{Document};
  my %hash        = ();
  my $TreeClimber = NetSoup::XML::TreeClimber->new( Filter => sub {
                                                      my $Node = shift;
                                                      if( ( $Node->getNodeTypeName() eq "TEXT_NODE" ) &&
                                                          ( $Node->getParentNode()->getTagName() !~ m/^(title|h[0-9]|script|style)$/i ) ) {
                                                        if( ! exists $hash{$Node} ) {
                                                          $hash{$Node} = 1;
                                                          return(1);
                                                        }
                                                      }
                                                      return( undef );
                                                    } );
 CLIMB: while(1) {
    my $flag = 0;
    $TreeClimber->climb( Node     => $Document,
                         Callback => sub {
                           my $Node  = shift;
                           my $flag += $Jargon->insert_html( R        => $r,
                                                             Document => $Document,
                                                             Node     => $Node );
                           return(1);
                         } );
    last CLIMB if( ! $flag );
  }
  return(1);
}


sub insert_html {
  my $Jargon   = shift;
  my %args     = @_;
  my $r        = $args{R};
  my $Document = $args{Document};
  my $Node     = $args{Node};
  my $string   = $Node->getNodeValue();
  my $flag     = 0;
  return( $flag ) if( ( length( $string ) == 0 ) || ( $string =~ m/^([ \t\r\n\s]+)$/s ) );
 INSERT: foreach my $key ( @{$Jargon->{SORTED}} ) {
    next INSERT if( $string !~ m/$key/is );
    next INSERT if( ( ! $key ) || ( ! $Jargon->{HASH}->{$key} ) );
    my $id   = "JG" . $HEX->bin2hex( Data => $key );
    my $Span = $Document->createElement( "span" );  # Prepare JavaScript wrapper
    $Span->setAttribute( "class", "JGDEF" );
    $Span->setAttribute( "onMouseOver", qq(jgPosPop('$id')) );
    $Span->setAttribute( "onMouseOut",  qq(jgDisPop('$id')) );
    if( $string =~ m/^$key$/is ) {
      my @strings = ( $string =~ m/^($key)$/is );
      my $Text = $Document->createTextNode( $strings[0] );
      $Span->appendChild( $Text );
      my $Parent = $Node->getParentNode();
      if( defined $Parent ) {
        $Parent->insertBefore( $Span, $Node );
        $Parent->removeChild( $Node );
        $flag++;
      }
      last INSERT;
    } elsif( $string =~ m/^$key\s.*$/is ) {
      my @strings = ( $string =~ m/^($key)(\s.*)$/is );
      my $TextLeft         = $Document->createTextNode( $strings[0] );
      my $TextRight        = $Document->createTextNode( $strings[@strings-1] );
      $Span->appendChild( $TextLeft );
      my $Parent = $Node->getParentNode();
      if( defined $Parent ) {
        $Parent->insertBefore( $TextRight, $Node );
        $Parent->insertBefore( $Span, $TextRight );
        $Parent->removeChild( $Node );
        $flag++;
      }
      last INSERT;
    } elsif( $string =~ m/^.*\s$key\s.*$/is ) {
      my @strings = ( $string =~ m/^(.*\s)($key)(\s.*)$/is );
      my $TextLeft                  = $Document->createTextNode( $strings[0] );
      my $TextMiddle                = $Document->createTextNode( $strings[1] );
      my $TextRight                 = $Document->createTextNode( $strings[@strings-1] );
      $Span->appendChild( $TextMiddle );
      my $Parent   = $Node->getParentNode();
      if( defined $Parent ) {
        $Parent->insertBefore( $TextRight, $Node );
        $Parent->insertBefore( $Span,      $TextRight );
        $Parent->insertBefore( $TextLeft,  $Span );
        $Parent->removeChild( $Node );  # Remove old text data
        $flag++;
      }
      last INSERT;
    } elsif( $string =~ m/^.*\s$key$/is ) {
      my @strings = ( $string =~ m/^(.*\s)($key)$/is );
      my $TextLeft         = $Document->createTextNode( $strings[0] );
      my $TextRight        = $Document->createTextNode( $strings[@strings-1] );
      $Span->appendChild( $TextRight );
      my $Parent = $Node->getParentNode();
      if( defined $Parent ) {
        $Parent->insertBefore( $Span, $Node );
        $Parent->insertBefore( $TextLeft, $Span );
        $Parent->removeChild( $Node );
        $flag++;
      }
      last INSERT;
    } else {
      ;
    }
  }
  return( $flag );
}


sub js {
  return( NetSoup::Mason::Classes::Filters::Jargon::JS->js() );
}
