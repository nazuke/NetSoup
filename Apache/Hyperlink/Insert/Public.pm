#!/usr/local/bin/perl -w


package NetSoup::Apache::Hyperlink::Insert::Public;
use Apache::Constants;
use NetSoup::Autonomy::DRE::Query::HTTP;
use NetSoup::Apache::Hyperlink::Insert::KillList;
use NetSoup::Apache::Hyperlink::Phrases::Public;
use NetSoup::XML::File;
use NetSoup::Autonomy::DRE::Query::Burst;
use constant DT => "NetSoup::XML::DOM2::Traversal::DocumentTraversal";
%NetSoup::Apache::Hyperlink::Insert::Public::FREQ = ();
1;


sub handler {
  my $r        = shift;
  my $Document = NetSoup::XML::File->new()->load( Pathname => $r->filename() );
  my %LCase    = ();  # Word frequency list lower case versions
  my %Freq     = ();  # Word frequency list
  my $NumLinks = 10;
  $r->send_http_header( "text/html" );
  if( defined $Document ) {
    my $TW = DT->new()->createTreeWalker( CurrentNode              => $Document,
                                          WhatToShow               => undef,
                                          EntityReferenceExpansion => 0,
                                          Filter                   => sub {
                                            my $Node = shift;
                                            if( ( $Node->nodeType() eq "TEXT_NODE" ) &&
                                                ( $Node->parentNode()->nodeName() !~ m/^(script|style)$/i ) ) {
                                              return(1);
                                            }
                                            return(0);
                                          } );
  SCAN: {
      $TW->walkTree( Node     => $Document,
                     Callback => sub {
                       my $Node = shift;
                       my $Text = insert_links( R    => $r,
                                                Text => $Node->nodeValue(),
                                                Freq => \%Freq );
                       return(1);
                     } );
    }
  RENDER: {
      $TW->walkTree( Node     => $Document,
                     Callback => sub {
                       my $Node = shift;
                       my $Text = insert_links( R    => $r,
                                                Text => $Node->nodeValue(),
                                                Freq => \%Freq );
                       $Node->nodeValue( NodeValue => $Text );
                       return(1);
                     } );
    }
    my $Serialise = DT->new()->createSerialise( CurrentNode => $Document );
    my $HTML      = "";
    $Serialise->serialise( Node   => $Document,
                           Target => \$HTML );
    print( $HTML );
  } else {
    return( 500 );
  }
  return( OK );
}


sub insert_links {
  my %args  = @_;
  my $r     = $args{R};
  my $Text  = $args{Text};
  my $Freq  = $args{Freq};
  my @words = split( /[\x00-\x2C\x2E-\x40\x5B-\x60\x7B-\xFF]+/, $Text );
  

  my $Burst = NetSoup::Autonomy::DRE::Query::Burst->new( Caching  => 1,
                                                         Period   => 60 * 60 * 5,
                                                         Hostname => $r->dir_config( "DRE" ),
                                                         Port     => $r->dir_config( "PORT" ) );
  $r->warn( "insert_links()" );


  $NumLinks = ( @words / 100 ) * $r->dir_config( "PERCENT" );
 
  
  foreach my $word ( @words ) {
    my $lcase = lc( $word );
    if( ( exists $NetSoup::Apache::Hyperlink::KillList::KILL{$lcase} ) &&
        ( length( $lcase ) <= 2 ) &&
        ( $lcase !~ m/^[0-9a-z\-\'\&;]+$/ ) ) {
      $NetSoup::Apache::Hyperlink::KillList::DICT{$lcase} = $lcase;
      if( exists $NetSoup::Apache::Hyperlink::Insert::Public::FREQ{$lcase} ) {
        $NetSoup::Apache::Hyperlink::Insert::Public::FREQ{$lcase}++;
      } else {
        $NetSoup::Apache::Hyperlink::Insert::Public::FREQ{$word} = 1;
      }
      if( exists $LCase{$lcase} ) {
        $LCase{$lcase}++;
        $Freq->{$word}++;
      } else {
        $LCase{$lcase} = 1;
        $Freq->{$word} = 1;
      }
    }
  }




 QUERY: foreach my $key ( keys %{$Freq} ) {
    if( ( $Freq->{$key} >= $r->dir_config( "LOW" ) ) && ( $Freq->{$key} <= $r->dir_config( "HIGH" ) ) ) {
      
      
      $Burst->mquery_client( QMethod   => "q",
                             QueryText => $key,
                             QNum      => 1,
                             Database  => $r->dir_config( "DATABASE" ) );


      if( $HTTP->numhits() > 0 ) {
        my $link = qq(<a href=") . $HTTP->field( Index => 1, Field => "doc_name" ) . qq(">$key</a>);
        $Text    =~ s/([\r\n\t ])$key([^a-zA-Z])/$1$link$2/gis;
        $NumLinks--;
      }
    }
    last QUERY if( $NumLinks <= 0 );
  }













  return( $Text );
}
