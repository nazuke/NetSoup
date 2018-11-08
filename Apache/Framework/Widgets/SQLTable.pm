#!/usr/local/bin/perl

package NetSoup::Apache::Framework::Widgets::SQLTable;
use strict;
use Apache;
use Apache::Constants qw( :http :response );
use NetSoup::Apache::Framework;
@NetSoup::Apache::Framework::Widgets::SQLTable::ISA = qw( NetSoup::Apache::Framework );
1;


sub widget {
  my $SQLTable  = shift;
  my $r         = shift;
  my $Node      = shift;
  my $string    = "";
  my $Framework = NetSoup::Apache::Framework->new();
  my $dbh       = $Framework->dbh();
  my $SQL       = $Node->getAttribute( Name => "SQL" );
  if( $SQL ) {


    ;


  } elsif( $Node->getAttribute( Name => "database" ) ) {


    my %callback = ();
    if( $Node->hasChildNodes() ) {
      my $NodeList = $Node->getElementsByTagName( TagName => "sub" );
      for ( my $i = 0 ; $i < $NodeList->nodeListLength ; $i++ ) {
        my $n      = $NodeList->item( Item => $i );
        my $column = $n->getAttribute( Name => "column" );
        my $code   = $n->firstChild()->data();
        $callback{$column} = $code;
      }
    }


    my $database = $Node->getAttribute( Name => "database" );
    my $table    = $Node->getAttribute( Name => "table" );
    my @columns  = split( m/,/, $Node->getAttribute( Name => "columns" ) );
    my @scolumns = ();
    foreach my $col ( @columns ) {
      push( @scolumns, "$database.$table.$col" );
    }
    my $scolumns = join( ",", @scolumns );
    my $sth      = $dbh->prepare( qq(SELECT $scolumns FROM $database.$table;) );
    if( $sth->execute() ) {
      while( my @row = $sth->fetchrow() ) {


        $string .= "<tr>";
        for( my $i = 0 ; $i < @row ; $i++ ) {
          if( exists $callback{$columns[$i]} ) {
            my $FLAG   = 1;             # Set flag to false to hide row
            my $COLUMN = $columns[$i];
            my $DATA   = $row[$i];
            my $code   = $callback{$columns[$i]};
            eval( $code );
            $string .= "<td>$DATA</td>" if( $FLAG );
          } else {
            $string .= "<td>$row[$i]</td>";
          }
        }
        $string .= "</tr>";


      }
    } else {
      $string = "<p>SQL Failed</p>";
    }
    $sth->finish();
  }
  return( $string );
}
