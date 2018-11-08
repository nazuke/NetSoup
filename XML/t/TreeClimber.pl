#!/usr/local/bin/perl -w

use strict;
use XML::DOM;
use NetSoup::XML::TreeClimber;
use NetSoup::Files::Load;


if( $ARGV[0] ) {
  foreach my $pathname ( @ARGV ) {
    my $data = NetSoup::Files::Load->new()->immediate( Pathname => $pathname );
    harness( $data );
  }
} else {
  my $data = join( "", <DATA> );
  harness( $data );
}
exit(0);


sub harness {
  my $data        = shift;
  my $Parser   = XML::DOM::Parser->new();
  my $Document    = $Parser->parse( $data );
  my $TreeClimber = NetSoup::XML::TreeClimber->new( Filter => sub {
                                                      my $Node = shift;
                                                    SWITCH: for( $Node->getNodeTypeName() ) {
                                                        m/^ELEMENT_NODE$/ && do {
                                                          return(1);
                                                        };
                                                      }
                                                      return( undef );
                                                    } );
  $TreeClimber->climb( Node     => $Document,
                       Callback => sub {
                         my $Node = shift;
                         print( $Node->getNodeTypeName() . "  " . $Node->getNodeName() . "\n" );
                       } );
  return(1);
}


__DATA__
<card>
    <details>
        <name>
            <firstname>Armitage</firstname>
            <middlename>the</middlename>
            <lastname>III</lastname>
        </name>
        <address>
            <number>1</number>
            <street>Police Precinct</street>
            <area>Mars Colony</area>
        </address>
    </details>
</card>
