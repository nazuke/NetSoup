#!/usr/local/bin/perl -w

package NetSoup::Embperl::Classes::Filters::Hyperlink::Public;
use strict;
use XML::DOM;
use NetSoup::Apache;
use NetSoup::Files::Load;
use NetSoup::Util::Sort::Length;
use NetSoup::XML::TreeClimber;
use NetSoup::Files::Cache;
use NetSoup::XHTML::MenuMaker::Drivers;
@NetSoup::Embperl::Classes::Filters::Hyperlink::Public::ISA = qw( NetSoup::Apache );
use constant CACHE_AGE => 300;
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
    if ( ! -e $r->dir_config( "FILTER_HYPERLINK_STRINGS" ) ) {
      return( undef );
    } else {
      foreach my $string ( split( m/[\r\n]/, $LOAD->immediate( Pathname => $r->dir_config( "FILTER_HYPERLINK_STRINGS" ) ) ) ) {
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
  my $content   = shift;
  my $Cache     = NetSoup::Files::Cache->new( Age => $r->dir_config( "FILTER_HYPERLINK_CACHE_AGE" ) || CACHE_AGE );
  my $digest    = $Cache->digest( "LNKR" . $content );
  my $cached    = $Cache->load_cache( Descriptor => $digest );
  if( defined $cached ) {
    return( $cached );
  } else {
    my $HL   = NetSoup::Embperl::Classes::Filters::Hyperlink::Public->new( R => $r );
    $content = $HL->linker( R => $r, Content => $content );
    $Cache->save_cache( Descriptor => $digest, Data => $content );
  }
  return( $content );
}


sub linker {
  my $Hyperlink = shift;
  my %args      = @_;
  my $r         = $args{R};
  my $content   = $args{Content};
  my $Parser    = XML::DOM::Parser->new();
  my $Document  = $Parser->parse( $content, NoExpand => 1 );
  my %hash      = ();
  if ( defined $Document ) {
    my $TreeClimber = NetSoup::XML::TreeClimber->new( Filter => sub {
                                                        my $Node = shift;
                                                        if( ( $Node->getNodeTypeName() eq "TEXT_NODE" ) &&
                                                            ( $Node->getParentNode()->getTagName() !~ m/^(a)$/i ) ) {
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
    $content = $Document->toString();
  } else {
    $content = qq(ERROR: Malformed XML Document ") . $r->filename() . qq("\n);
  }
  return( $content );
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
    next INSERT if( ( ! $key ) || ( ! $Hyperlink->{HASH}->{$key} ) );
    my $target = "_self";
    if ( $Hyperlink->{HASH}->{$key} =~ m:/[^/]+\.pdf:i ) {
      $target = "_blank";
    }


    my $A = $Document->createElement( "a" );
    $A->setAttribute( "href", $Hyperlink->{HASH}->{$key} );
    $A->setAttribute( "target", $target );


    if( $string =~ m/^($key)$/is ) {
      my $Text = $Document->createTextNode( $1 );
      $A->appendChild( $Text );
      my $Parent = $Node->getParentNode();
      if( defined $Parent ) {
        $Parent->insertBefore( $A, $Node );
        $Parent->removeChild( $Node );
        $flag++;
      }
      last INSERT;


    } elsif( $string =~ m/^($key)(\s.*)$/is ) {
      my ( $left, $right ) = ( $1, $2 );
      my $TextLeft         = $Document->createTextNode( $left );
      my $TextRight        = $Document->createTextNode( $right );
      $A->appendChild( $TextLeft );
      my $Parent = $Node->getParentNode();
      if( defined $Parent ) {
        $Parent->insertBefore( $TextRight, $Node );
        $Parent->insertBefore( $A, $TextRight );
        $Parent->removeChild( $Node );
        $flag++;
      }
      last INSERT;


    } elsif( $string =~ m/^(.*\s)($key)(\s.*)$/is ) {
      my ( $left, $middle, $right ) = ( $1, $2, $3 );
      my $TextLeft                  = $Document->createTextNode( $left );
      my $TextMiddle                = $Document->createTextNode( $middle );
      my $TextRight                 = $Document->createTextNode( $right );
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


    } elsif( $string =~ m/^(.*\s)($key)$/is ) {
      my ( $left, $right ) = ( $1, $2 );
      my $TextLeft         = $Document->createTextNode( $left );
      my $TextRight        = $Document->createTextNode( $right );
      $A->appendChild( $TextRight );
      my $Parent = $Node->getParentNode();
      if( defined $Parent ) {
        $Parent->insertBefore( $A, $Node );
        $Parent->insertBefore( $TextLeft, $A );
        $Parent->removeChild( $Node );
        $flag++;
      }
      last INSERT;


    } elsif( $string =~ m/^([ \t\r\n\s]+)$/s ) {
      ;
    } else {
      ;
    }
  }
  return( $flag );
}
