#!/usr/local/bin/perl -w

package NetSoup::Apache::Framework::Filters::Hyperlink;
use strict;
use NetSoup::Apache;
use NetSoup::Files::Load;
use NetSoup::XML::File;
use NetSoup::Util::Sort::Length;
use NetSoup::XML::Parser;
use NetSoup::XML::DOM2::Traversal::DocumentTraversal;
use constant DT   => "NetSoup::XML::DOM2::Traversal::DocumentTraversal";
use constant FILE => NetSoup::XML::File->new();
use constant LOAD => NetSoup::Files::Load->new();
@NetSoup::Apache::Framework::Filters::Hyperlink::ISA = qw( NetSoup::Apache );
1;


sub filter {
  my $this      = shift;
  my $r         = shift;
  my $content   = shift;
  my $Hyperlink = NetSoup::Apache::Framework::Filters::Hyperlink->new( R => $r );
  return( $Hyperlink->staticlink( R => $r, Content => $content ) );
}




sub initialise {
  my $Hyperlink         = shift;
  my %args              = @_;
  my $r                 = $args{R};
  $Hyperlink->{HASH}    = {};
  $Hyperlink->{SORTED}  = [];
  $Hyperlink->{Drivers} = NetSoup::XHTML::Widgets::MenuMaker::Drivers->new();
  {
    if ( ! -e $r->dir_config( "FILTER_HYPERLINK_STRINGS" ) ) {
      return( undef );
    } else {
      foreach my $string ( split( m/[\r\n]/, LOAD->immediate( Pathname => $r->dir_config( "FILTER_HYPERLINK_STRINGS" ) ) ) ) {
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




sub staticlink {
  my $Hyperlink = shift;
  my %args      = @_;
  my $r         = $args{R};
  my $content   = $args{Content};
  my $Parser    = NetSoup::XML::Parser->new();
  my $Document  = $Parser->parse( XML => \$content );
  if ( defined $Document ) {
    my $TW = DT->new()->createTreeWalker( CurrentNode              => $Document,
                                          WhatToShow               => undef,
                                          EntityReferenceExpansion => 0,
                                          Filter                   => sub {
                                            my $Node = shift;
                                            if ( ( $Node->nodeType() eq "TEXT_NODE" ) &&
                                                 ( $Node->parentNode()->nodeName() !~ m/^(title|h[0-9]|a|script|style)$/i ) ) {
                                              return(1);
                                            }
                                            return(0);
                                          } );
  RENDER: {
      $TW->walkTree( Node     => $Document,
                     Callback => sub {
                       my $Node = shift;
                       my $Text = $Hyperlink->insert_links( R     => $r,
                                                            Text  => $Node->nodeValue() );
                       $Node->nodeValue( NodeValue => $Text );
                       return(1);
                     } );
    }
    $content = FILE->serialise( Document   => $Document,
                                StrictSGML => 0,
                                Compact    => 1,
                                OmitPI     => 1 );
  } else {
    $content = qq(ERROR: Malformed XML Document ") . $r->filename() . qq("\n);
  }
  return( $content );
}




sub insert_links {
  my $Hyperlink = shift;
  my %args      = @_;
  my $r         = $args{R};
  my $Text      = $args{Text};
  $Text         =~ s/[\t \r\n]+/ /gs;
  my $Image     = ""; #qq(<img src="/Dot" />);
  my $CSS       = $r->dir_config( "CSS" );
 INSERT: foreach my $key ( @{$Hyperlink->{SORTED}} ) {
    next INSERT if( ( ! $key ) || ( ! $Hyperlink->{HASH}->{$key} ) );
    my $target = "_self";
    if ( $Hyperlink->{HASH}->{$key} =~ m:/[^/]+\.pdf:i ) {
      $target = "_blank";
    }
    if ( $Text eq $key ) {
      $Text = qq($Image<a class="$CSS" href="$Hyperlink->{HASH}->{$key}" target="$target">$Text<\/a>);
      last INSERT;
    } else {
      if ( $Text =~ m/^$key([^\w\d<>\/]+)/ ) {
        $Text =~ s/($key)([^\w\d<>\/]+)/$Image<a class="$CSS" href="$Hyperlink->{HASH}->{$key}" target="$target">$1<\/a>$2/gis;
      } elsif ( $Text =~ m/([^\w\d<>\/]+)$key$/ ) {
        $Text =~ s/([^\w\d<>\/]+)($key)/$1$Image<a class="$CSS" href="$Hyperlink->{HASH}->{$key}" target="$target">$2<\/a>/gis;
      } else {
        $Text =~ s/([^\w\d<>\/]+)($key)([^\w\d<>\/]+)/$1$Image<a class="$CSS" href="$Hyperlink->{HASH}->{$key}" target="$target">$2<\/a>$3/gis;
      }
    }
  }
  return( $Text );
}
