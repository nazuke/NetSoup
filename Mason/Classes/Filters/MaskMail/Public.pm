#!/usr/local/bin/perl -w

package NetSoup::Mason::Classes::Filters::MaskMail::Public;
use strict;
use XML::DOM;
use NetSoup::Apache;
use NetSoup::XML::TreeClimber;
use NetSoup::Files::Cache;
use NetSoup::Mason::Classes::Filters::MaskMail::JS;
@NetSoup::Mason::Classes::Filters::MaskMail::Public::ISA = qw( NetSoup::Apache );
use constant CACHE_AGE => 300;
1;


sub initialise {
  my $MaskMail   = shift;
  my %args       = @_;
  $MaskMail->{R} = $args{R};
  return( $MaskMail );
}


sub filter {
  my $MaskMail = shift;
  my $r         = shift;
  my $content   = shift;
  my $Cache     = NetSoup::Files::Cache->new( Age => $r->dir_config( "FILTER_MASKMAIL_CACHE_AGE" ) || CACHE_AGE );
  my $digest    = $Cache->digest( "MSKM" . $content );
  my $cached    = $Cache->load_cache( Descriptor => $digest );
  if( defined $cached ) {
    return( $cached );
  } else {
    my $HL   = NetSoup::Mason::Classes::Filters::MaskMail::Public->new( R => $r );
    $content = $HL->linker( Content => $content );
    $Cache->save_cache( Descriptor => $digest, Data => $content );
  }
  return( $content );
}


sub linker {
  my $MaskMail = shift;
  my %args      = @_;
  my $r         = $MaskMail->{R};
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
    $TreeClimber->climb( Node     => $Document,
                         Callback => sub {
                           my $Node = shift;
                           $MaskMail->insert_links( Document => $Document,
                                                    Node     => $Node );
                           return(1);
                         } );
    $content = $Document->toString();
  } else {
    $content = qq(ERROR: Malformed XML Document ") . $r->filename() . qq("\n);
  }
  return( $content );
}


sub insert_links {
  my $MaskMail = shift;
  my %args     = @_;
  my $r        = $MaskMail->{R};
  my $Document = $args{Document};
  my $Node     = $args{Node};
  my $string   = $Node->getNodeValue();
  my $flag     = 0;
  return( $flag ) if( ( length( $string ) == 0 ) || ( $string =~ m/^([ \t\r\n\s]+)$/s ) );


  my $Script = $Document->createElement( "script" );
  $Script->setAttribute( "language", "JavaScript" );
  $Script->setAttribute( "type", "text/javascript" );
  if( $string =~ m/^([^\@]+\@[^\@]+)$/is ) {
    my $Comment = $Document->createComment( $MaskMail->makeScript( String => $1 ) );
    $Script->appendChild( $Comment );
    my $Parent = $Node->getParentNode();
    if( defined $Parent ) {
      $Parent->insertBefore( $Script, $Node );
      $Parent->removeChild( $Node );
      $flag++;
    }


  } elsif( $string =~ m/^([^\@]+\@[^\@]+)(\s.*)$/is ) {
    my ( $left, $right ) = ( $1, $2 );
    my $Comment          = $Document->createComment( $MaskMail->makeScript( String => $left ) );
    my $TextRight        = $Document->createTextNode( $right );
    $Script->appendChild( $Comment );
    my $Parent = $Node->getParentNode();
    if( defined $Parent ) {
      $Parent->insertBefore( $TextRight, $Node );
      $Parent->insertBefore( $Script, $TextRight );
      $Parent->removeChild( $Node );
      $flag++;
    }


  } elsif( $string =~ m/^(.*\s)([^\@]+\@[^\@]+)(\s.*)$/is ) {
    my ( $left, $middle, $right ) = ( $1, $2, $3 );
    my $TextLeft                  = $Document->createTextNode( $left );
    my $Comment                   = $Document->createComment( $MaskMail->makeScript( String => $middle ) );
    my $TextRight                 = $Document->createTextNode( $right );
    $Script->appendChild( $Comment );
    my $Parent = $Node->getParentNode();
    if( defined $Parent ) {
      $Parent->insertBefore( $TextRight, $Node );
      $Parent->insertBefore( $Script,         $TextRight );
      $Parent->insertBefore( $TextLeft,  $Script );
      $Parent->removeChild( $Node );
      $flag++;
    }


  } elsif( $string =~ m/^(.*\s)([^\@]+\@[^\@]+)$/is ) {
    my ( $left, $right ) = ( $1, $2 );
    my $TextLeft         = $Document->createTextNode( $left );
    my $Comment          = $Document->createComment( $MaskMail->makeScript( String => $right ) );
    $Script->appendChild( $Comment );
    my $Parent = $Node->getParentNode();
    if( defined $Parent ) {
      $Parent->insertBefore( $Script, $Node );
      $Parent->insertBefore( $TextLeft, $Script );
      $Parent->removeChild( $Node );
      $flag++;
    }


  } elsif( $string =~ m/^([ \t\r\n\s]+)$/s ) {
    ;
  } else {
    ;
  }


  return( $flag );
}


sub makeScript {
  my $MaskMail = shift;
  my %args     = @_;
  my @chars    = split( m//, $args{String} );
  for( my $i = 0 ; $i < @chars ; $i++ ) {
    $chars[$i] = ord( $chars[$i] );
  }
  my $encoded = join( ",", @chars );
  my $script  = qq(\ndocument.write( "<a href=\\"mailto:" + decodeString( [__EMAIL__] ) + "\\">" + decodeString( [__EMAIL__] ) + "</a>");\n//);
  $script     =~ s/__EMAIL__/$encoded/gs;
  return( $script );
}


sub js {
  return( NetSoup::Mason::Classes::Filters::MaskMail::JS->js() );
}
