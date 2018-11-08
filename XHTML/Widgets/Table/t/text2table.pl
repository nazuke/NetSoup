#!/usr/local/bin/perl -w


use NetSoup::XHTML::Widgets::Table::text2table;


my $text2table = NetSoup::XHTML::Widgets::Table::text2table->new();
my $data       = "";
while( <DATA> ) {
  $data .= $_; 
}
my $Table = $text2table->text2table( Content => $data );
$Table->serialise( Target => \$data );
print( STDERR $data );
exit(0);


__DATA__
row1  column 1  column2  column3  column4
row2  column 1  column2  column3  column4
row3  column 1  column2  column3  column4
row4  column 1  column2  column3  column4
row5  column 1  column2  column3  column4
