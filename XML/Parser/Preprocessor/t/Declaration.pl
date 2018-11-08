#!/usr/local/bin/perl -w
use NetSoup::XML::Parser::Preprocessor::Declaration;
my @lines = <DATA>;
my $Declaration = NetSoup::XML::Parser::Preprocessor::Declaration->new();
foreach my $line ( @lines ) {
  chomp( $line );
  my @chars = split( //, $line );
  $Declaration->_spElement( Chars => \@chars );
}
exit(0);


__DATA__
book ((title,author)|description))
title (#PCDATA)
author (authorname+)
authorname (#PCDATA)
description (#PCDATA)
reviews (rating, synopsis?, comments+)*
rating ((tutorial|reference)*,overall)
any ANY
