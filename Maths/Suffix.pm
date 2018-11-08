#!/usr/local/bin/perl -w

package NetSoup::Maths::Suffix;
use strict;
use NetSoup::Core;
@NetSoup::Maths::Suffix::ISA = qw( NetSoup::Core );
1;

sub append {
  my $Suffix = shift;
  my $value  = shift;
  my $affix  = "";
SWITCH: for ( $value ) {
    m/1$/ && do {
      $affix = "st";
      last SWITCH;
    };
    m/2$/ && do {
      $affix = "nd";
      last SWITCH;
    };
    m/3$/ && do {
      $affix = "rd";
      last SWITCH;
    };
    m/./ && do {
      $affix = "th";
      last SWITCH;
    };
  }
  return( $value . $affix );
}
