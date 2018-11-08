#!/usr/local/bin/perl -w

package NetSoup::Mason::Classes::Filters::Hyperlink::Public;
use strict;
use XML::DOM;
use NetSoup::Apache;
use NetSoup::Files::Load;
use NetSoup::Util::Sort::Length;
use NetSoup::XML::TreeClimber;
use NetSoup::XHTML::MenuMaker::Drivers;
@NetSoup::Mason::Classes::Filters::Hyperlink::Public::ISA = qw( NetSoup::Apache );
my $LOAD = NetSoup::Files::Load->new();
1;


sub initialise {
  my $Hyperlink         = shift;
  my %args              = @_;
  my $r                 = $args{R};
  $Hyperlink->{HASH}    = {};
  $Hyperlink->{SORTED}  = [];
  $Hyperlink->{Drivers} = NetSoup::XHTML::MenuMaker::Drivers->new();
  {
    if ( ! -e $r->dir_config( 'FILTER_HYPERLINK_STRINGS' ) ) {
      return( undef );
    } else {
    STRINGS: foreach my $string ( split( m/[\r\n]/, $LOAD->immediate( Pathname => $r->dir_config( 'FILTER_HYPERLINK_STRINGS' ) ) ) ) {
        next STRINGS if( ( $string =~ m/^\#/ ) || ( $string =~ m/^[ \t]*$/ ) );
        my ( $key, $value ) = ( $string =~ m/^([^\t]+)\t+([^\t]+)$/s );
        $Hyperlink->{HASH}->{$key} = $value;
      }
    }
  }
  {
    my $Sort     = NetSoup::Util::Sort::Length->new();
    my @unsorted = keys %{$Hyperlink->{HASH}};
    $Sort->sort4( Array => \@unsorted, Target => $Hyperlink->{SORTED} );
  }
  return( $Hyperlink );
}


sub filter {
  my $Hyperlink = shift;
  my $r         = shift;
  my $Document  = shift;
  my $HL        = NetSoup::Mason::Classes::Filters::Hyperlink::Public->new( R => $r );
  return( $HL->linker( R => $r, Document => $Document ) );
}


sub linker {
  my $Hyperlink   = shift;
  my %args        = @_;
  my $r           = $args{R};
  my $Document    = $args{Document};
  my $Tags        = join( "|", split( m/,/, $r->dir_config( 'FILTER_HYPERLINK_TAGS' ) || "p,li,strong,em" ) );
  my %hash        = ();
  my $TreeClimber = NetSoup::XML::TreeClimber->new( Filter => sub {
                                                      my $Node = shift;
                                                      if( ( $Node->getNodeTypeName() eq "TEXT_NODE" ) &&
                                                          ( $Node->getParentNode()->getTagName() =~ m/^($Tags)$/i ) ) {
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
                           my $Node = shift;
                           $flag += $Hyperlink->insert_links( R        => $r,
                                                              Document => $Document,
                                                              Node     => $Node );
                           return(1);
                         } );
    last CLIMB if( ! $flag );
  }
  return(1);
}


sub insert_links {
  my $Hyperlink = shift;
  my %args      = @_;
  my $r         = $args{R};
  my $Document  = $args{Document};
  my $Node      = $args{Node};
  my $string    = $Node->getNodeValue();
  my $flag      = 0;
  return( $flag ) if( ( length( $string ) == 0 ) || ( $string =~ m/^([ \t\r\n\s]+)$/s ) );
 INSERT: foreach my $key ( @{$Hyperlink->{SORTED}} ) {
    next INSERT if( $string !~ m/$key/is );  # Do next if key not in TEXT_NODE
    next INSERT if( ( ! $key ) || ( ! $Hyperlink->{HASH}->{$key} ) );
    my $target = "_self";
    if ( $Hyperlink->{HASH}->{$key} =~ m:/[^/]+\.pdf:i ) {
      $target = "_blank";
    }
    my $A = $Document->createElement( "a" );
    $A->setAttribute( "href", $Hyperlink->{HASH}->{$key} );
    $A->setAttribute( "target", $target );


    if( $string =~ m/^$key$/is ) {
      my @strings = ( $string =~ m/^($key)$/is );
      my $Text    = $Document->createTextNode( $strings[0] );
      $A->appendChild( $Text );
      my $Parent = $Node->getParentNode();
      if( defined $Parent ) {
        $Parent->insertBefore( $A, $Node );
        $Parent->removeChild( $Node );
        $flag++;
      }
      last INSERT;


    } elsif( $string =~ m/^$key\s.*$/is ) {
      my @strings   = ( $string =~ m/^($key)(\s.*)$/is );
      my $TextLeft  = $Document->createTextNode( $strings[0] );
      my $TextRight = $Document->createTextNode( $strings[@strings-1] );
      $A->appendChild( $TextLeft );
      my $Parent = $Node->getParentNode();
      if( defined $Parent ) {
        $Parent->insertBefore( $TextRight, $Node );
        $Parent->insertBefore( $A, $TextRight );
        $Parent->removeChild( $Node );
        $flag++;
      }
      last INSERT;


    } elsif( $string =~ m/^.*\s$key\s.*$/is ) {
      my @strings    = ( $string =~ m/^(.*\s)($key)(\s.*)$/is );
      my $TextLeft   = $Document->createTextNode( $strings[0] );
      my $TextMiddle = $Document->createTextNode( $strings[1] );
      my $TextRight  = $Document->createTextNode( $strings[@strings-1] );
      $A->appendChild( $TextMiddle );
      my $Parent = $Node->getParentNode();
      if( defined $Parent ) {
        $Parent->insertBefore( $TextRight, $Node );
        $Parent->insertBefore( $A,         $TextRight );
        $Parent->insertBefore( $TextLeft,  $A );
        $Parent->removeChild( $Node );
        $flag++;
      }
      last INSERT;


    } elsif( $string =~ m/^.*\s$key$/is ) {
      my @strings   = ( $string =~ m/^(.*\s)($key)$/is );
      my $TextLeft  = $Document->createTextNode( $strings[0] );
      my $TextRight = $Document->createTextNode( $strings[@strings-1] );
      $A->appendChild( $TextRight );
      my $Parent = $Node->getParentNode();
      if( defined $Parent ) {
        $Parent->insertBefore( $A, $Node );
        $Parent->insertBefore( $TextLeft, $A );
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
