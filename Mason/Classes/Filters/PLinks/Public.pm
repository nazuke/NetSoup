#!/usr/local/bin/perl -w

package NetSoup::Mason::Classes::Filters::PLinks::Public;
use strict;
use XML::DOM;
use NetSoup::Apache;
use NetSoup::XML::TreeClimber;
use NetSoup::Mason::Classes::Filters::PLinks::JS;
use NetSoup::Protocol::DRE::Query;
@NetSoup::Mason::Classes::Filters::PLinks::Public::ISA = qw( NetSoup::Apache );
1;


sub initialise {
  my $PLinks          = shift;
  my %args            = @_;
  $PLinks->{R}        = $args{R};
  $PLinks->{Document} = $args{Document};
  $PLinks->{Uniq}     = 0;
  return( $PLinks );
}


sub css {
  my $PLinks = shift;
  my %args   = @_;
  my $css    = <<END_STYLE;
<style type="text/css">
  <!--
    table.PNK {
      position:            absolute;
      top:                 0px;
      left:                0px;
      display:             none;
      font-family:         sans-serif;
      font-size:           9pt;
      background-color:    #EEEEFF;
      color:               #000088;
      border-top-color:    #FFFFFF;
      border-left-color:   #AAAAAA;
      border-right-color:  #444444;
      border-bottom-color: #222222;
      border-style:        solid;
      border-width:        1px;
      padding:             2px;
    }
    td.PNKTitle {
      background-color:    #8888AA;
      color:               #FFFFFF;
      font-weight:         bold;
      margin-left:         10px;
      text-align:          left;
    }
    table.PNK td {
      padding:             2px;
    }
    span.PNK {
      background-color:    #DDDDFF;
      color:               #444444;
      font-weight:         bold;
      margin-left:         10px;
    }
    table.PNK a:link, table.PNK a:hover, table.PNK a:visited {
      text-decoration:     none;
    }
    table.PNK a:hover {
      background-color:    #FF0000;
      color:               #FFFFFF;
    }
  -->
</style>
END_STYLE
  ;
  return( $css );
}


sub filter {
  my $PLinks   = shift;
  my $r        = shift;
  my $Document = shift;
  my $F        = NetSoup::Mason::Classes::Filters::PLinks::Public->new( R => $r, Document => $Document );
  return( $F->render_filter() );
}


sub render_filter {
  my $PLinks = shift;
  my %args   = @_;
  my $TC     = NetSoup::XML::TreeClimber->new( Filter => sub {
                                                 my $Node = shift;
                                                 if( $Node->getNodeName() =~ m/^p$/i ) {
                                                   return(1);
                                                 }
                                                 return( undef );
                                               } );
  $TC->climb( Node     => $PLinks->{Document},
              Callback => sub {
                my $Node = shift;
                $PLinks->insert_html( Node => $Node );
              } );
  return(1);
}


sub insert_html {
  my $PLinks = shift;
  my %args   = @_;
  my $r      = $PLinks->{R};
  my $Document = $PLinks->{Document};
  my $Node   = $args{Node};
  my $string = $Node->toString();
  if( $string ) {
    my $Query = NetSoup::Protocol::DRE::Query->new( Caching  => 1,
                                                    Period   => 60,
                                                    Hostname => $r->dir_config( 'HYPERLINKS_DRE_IP' ),
                                                    Port     => $r->dir_config( 'HYPERLINKS_DRE_QUERY_PORT' ) );
    $Query->query( QMethod   => "q",
                   QueryText => $string,
                   QNum      => 3,
                   Database  => "General+PressReleases" );
    if( $Query->numhits() > 0 ) {
      my $id    = $PLinks->id();
      my %links = {};
      for( my $i = 1 ; $i <= $Query->numhits() ; $i++ ) {
        if( $Query->field( Index => $i, Field => "url_title" ) ) {
          $links{$Query->field( Index => $i,
                                Field => "doc_name" )} = $Query->field( Index => $i,
                                                                        Field => "url_title" );
        }
      }
      $PLinks->popup( ID    => $id,
                      Links => \%links );
      my $Span = $Document->createElement( "span" );
      $Span->setAttribute( "class", "PNK" );
      $Span->setAttribute( "onMouseOver", qq(pnkPosPop('$id')) );
      $Node->appendChild( $Span );
      my $Text = $Document->createTextNode( '(links)' );
      $Span->appendChild( $Text );
    }
  }
  return(1);
}


sub popup {
  my $PLinks   = shift;
  my %args     = @_;
  my $id       = $args{ID};
  my %links    = %{$args{Links}};
  my $r        = $PLinks->{R};
  my $Document = $PLinks->{Document};
  my $Div      = $Document->getFirstChild();
  my $Table    = $Document->createElement( "table" );
  $Table->setAttribute( "id", $id );
  $Table->setAttribute( "class", "PNK" );
  #$Table->setAttribute( "onMouseOver", qq(pnkPosPop2('$id')) );
  #$Table->setAttribute( "onMouseOut",  qq(pnkDisPop('$id')) );
  $Div->appendChild( $Table );
  my $Tr = $Document->createElement( "tr" );
  $Table->appendChild( $Tr );
  my $Td = $Document->createElement( "td" );
  $Td->setAttribute( "class", "PNKTitle" );
  $Tr->appendChild( $Td );
  my $Span = $Document->createElement( "span" );
  $Span->setAttribute( "onClick", qq(pnkDisPop('$id')) );
  $Td->appendChild( $Span );
  my $Text = $Document->createTextNode( "X" );
  $Span->appendChild( $Text );
  foreach my $doc_name ( sort keys %links ) {
    my $Tr = $Document->createElement( "tr" );
    $Table->appendChild( $Tr );
    my $Td = $Document->createElement( "td" );
    $Tr->appendChild( $Td );
    my $A = $Document->createElement( "a" );
    $A->setAttribute( "href", $doc_name );
    $Td->appendChild( $A );
    my $Text = $Document->createTextNode( $links{$doc_name} );
    $A->appendChild( $Text );
  }
  return(1);
}


sub id {
  my $PLinks = shift;
  $PLinks->{Uniq}++;
  return( "PNK" . $PLinks->{Uniq} );
}
