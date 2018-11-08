#!/usr/local/bin/perl -w

use NetSoup::HTML::Parser;
use NetSoup::XML::DOM2::Traversal::DocumentTraversal;

my $data = "";
while( <STDIN> ) {
  $data .= $_;
}
my $Parser   = NetSoup::HTML::Parser->new( XML => \$data );
my $Document = $Parser->parse();
my $DT       = NetSoup::XML::DOM2::Traversal::DocumentTraversal->new( );
my $TW       = $DT->createTreeWalker( Root   => $Document,
                                      Filter => sub {
                                        my $Node = shift;
                                        if( $Node->nodeName() =~ m/^(tr|td)$/i ) {
                                          return(1);
                                        }
                                        return(0);
                                      });
my $table = ();
my $idx   = -1;
$TW->walkTree( Node => $Document,
               Callback => sub {
                 my $Node = shift;
                 $idx++ if( $Node->nodeName() =~ m/^(tr)$/i );
                 if( $Node->nodeName() =~ m/^(td)$/i ) {
                   my $Child = $Node->firstChild();
                   $table[$idx] = [] if( ! defined $table[$idx] );
                   push( @{$table[$idx]}, $Child->nodeValue() );
                 }
                 return(1);
               } );
for( my $i = 0 ; $i <= ( @table - 1 ) ; $i++ ) {
  for( my $j = 0 ; $j <= ( @{$table[$i]} - 1 ) ; $j++ ) {
    print( $table[$i]->[$j] . "\t" );
  }
  print( "\n" );
}
exit(0);
