#!/usr/local/bin/perl -w

package NetSoup::Apache::Hyperlink;
use strict;
use Apache::Constants;
use NetSoup::Apache;
use NetSoup::Autonomy::DRE::Query::HTTP;
use NetSoup::XML::File;
use NetSoup::Util::Sort::Length;
use constant DT   => "NetSoup::XML::DOM2::Traversal::DocumentTraversal";
use constant FILE => NetSoup::XML::File->new();
@NetSoup::Apache::Hyperlink::ISA    = qw( NetSoup::Apache );
%NetSoup::Apache::Hyperlink::CACHE  = ();
%NetSoup::Apache::Hyperlink::STATIC = ();
1;


sub hyperlink {
  my %args         = @_;
  my $r            = $args{R};
  my $strings      = $args{Strings};
  my $insert_links = $args{Insert} || \&insert_links;
  my $Document     = FILE->load( Pathname => $r->filename() );
  if( defined $Document ) {
    my $TW = DT->new()->createTreeWalker( CurrentNode              => $Document,
                                          WhatToShow               => undef,
                                          EntityReferenceExpansion => 0,
                                          Filter                   => sub {
                                            my $Node = shift;
                                            if( ( $Node->nodeType() eq "TEXT_NODE" ) &&
                                                ( $Node->parentNode()->nodeName() !~ m/^(title|h[0-9]|a|script|style)$/i ) ) {
                                              return(1);
                                            }
                                            return(0);
                                          } );
    my $DRE = NetSoup::Autonomy::DRE::Query::HTTP->new( Caching  => $r->dir_config( "CACHING" ) || 0,
                                                        Period   => $r->dir_config( "PERIOD" )  || 120,
                                                        Hostname => $r->dir_config( "HOSTNAME" ),
                                                        Port     => $r->dir_config( "PORT" ) );
    foreach my $string ( &$strings( R => $r ) ) {
      #print( STDERR qq(STRING "$string"\n) );
      if( exists $NetSoup::Apache::Hyperlink::CACHE{$string} ) {
        #print( STDERR qq(Cached: "$string"\n) );
      } else {
        #print( STDERR qq(Looking up: "$string"\n) );
        $DRE->query( QueryText => $string,
                     QNum      => 1,
                     Database  => $r->dir_config( "DATABASE" ) );
        if( $DRE->numhits() > 0 ) {
          $NetSoup::Apache::Hyperlink::CACHE{$string} = $DRE->field( Index => 1, Field => "doc_name" );
        }
      }
    }
  RENDER: {
      $TW->walkTree( Node     => $Document,
                     Callback => sub {
                       my $Node = shift;
                       my $Text = &$insert_links( R     => $r,
                                                  Text  => $Node->nodeValue(),
                                                  Links => \%NetSoup::Apache::Hyperlink::CACHE );
                       $Node->nodeValue( NodeValue => $Text );
                       return(1);
                     } );
    }
    return( FILE->serialise( Document => $Document,
                             OmitPI   => 1 ) );
  }
  print( STDERR qq(ERROR: Malformed XML Document ") . $r->filename() . qq("\n) );
  return( undef );
}


sub staticlink {
  my %args         = @_;
  my $r            = $args{R};
  my $strings      = $args{Strings};
  my $insert_links = $args{Insert} || \&insert_links;
  my $Document     = FILE->load( Pathname => $r->filename() );
  if( defined $Document ) {
    my $TW = DT->new()->createTreeWalker( CurrentNode              => $Document,
                                          WhatToShow               => undef,
                                          EntityReferenceExpansion => 0,
                                          Filter                   => sub {
                                            my $Node = shift;
                                            if( ( $Node->nodeType() eq "TEXT_NODE" ) &&
                                                ( $Node->parentNode()->nodeName() !~ m/^(title|h[0-9]|a|script|style)$/i ) ) {
                                              return(1);
                                            }
                                            return(0);
                                          } );
    foreach my $string ( &$strings( R => $r ) ) {
      my ( $key, $value ) = ( $string =~ m/^([^\t]+)\t+([^\t]+)$/s );
      $NetSoup::Apache::Hyperlink::STATIC{$key} = $value;
    }
  RENDER: {
      $TW->walkTree( Node     => $Document,
                     Callback => sub {
                       my $Node = shift;
                       my $Text = &$insert_links( R     => $r,
                                                  Text  => $Node->nodeValue(),
                                                  Links => \%NetSoup::Apache::Hyperlink::STATIC );
                       $Node->nodeValue( NodeValue => $Text );
                       return(1);
                     } );
    }
    return( FILE->serialise( Document => $Document,
                             OmitPI   => 1,
                             StrictSGML => 1 ) );
  }
  print( STDERR qq(ERROR: Malformed XML Document ") . $r->filename() . qq("\n) );
  return( undef );
}


sub insert_links {
  my %args     = @_;
  my $r        = $args{R};
  my $Text     = $args{Text};
  my $Links    = $args{Links};
  my $Sort     = NetSoup::Util::Sort::Length->new();
  my $CSS      = $r->dir_config( "FILTER_HYPERLINK_CLASS" ) || "";
  $Text        =~ s/[\t \r\n]+/ /gs;
  my @unsorted = keys %{$Links};
  my @sorted   = ();
  my $uri      = $r->uri();
  $uri         =~ s:/[^/]+\.[^/]+$:/:;
  $Sort->sort4( Array  => \@unsorted, Target => \@sorted );
 INSERT: foreach my $key ( @sorted ) {
    next INSERT if( $uri eq $Links->{$key} ); # Don't link to self
    next INSERT if( ( ! $key ) || ( ! $Links->{$key} ) );
    my $target = "_self";
    if( $Links->{$key} =~ m:/[^/]+\.pdf:i ) {
      $target = "_blank";
    }
    if( $Text =~ m/^$key$/gis ) {
      $Text = qq(<a class="$CSS" href="$Links->{$key}" target="$target">$Text<\/a>);
      last INSERT;  
    } else {
      if( $Text =~ m/^$key([^"\w\d<>\/]*)/gis ) {
        $Text =~ s/^($key)([^"\w\d<>\/]*)/<a class="$CSS" href="$Links->{$key}" target="$target">$1<\/a>$2/gis;
      } elsif( $Text =~ m/([^"\w\d<>\/]*)$key$/gis ) {
        $Text =~ s/([^"\w\d<>\/]*)($key)$/$1<a class="$CSS" href="$Links->{$key}" target="$target">$2<\/a>/gis;
      } else {
        $Text =~ s/([^"\w\d<>\/]+)($key)([^"\w\d<>\/]+)/$1<a class="$CSS" href="$Links->{$key}" target="$target">$2<\/a>$3/gis;
      }
    }
  }
  return( $Text );
}
