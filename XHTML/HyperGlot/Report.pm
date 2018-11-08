#!/usr/local/bin/perl
#
#   NetSoup::XHTML::HyperGlot::Report.pm v00.00.01z 12042000
#
#   Copyright (C) 2000  Jason Holland <jason.holland@dial.pipex.com>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#
#   Description: This Perl 5.0 class provides object methods for.
#
#
#   Methods:
#       report  -  This method generates a report data chunk


package NetSoup::XHTML::HyperGlot::Report;
use strict;
no  strict qw( refs );
use NetSoup::Core;
use NetSoup::Text::CodePage::ascii2hex;
@NetSoup::XHTML::HyperGlot::Report::ISA = qw( NetSoup::Core );
my $ASCII2HEX = NetSoup::Text::CodePage::ascii2hex->new();
1;


sub report {
  # This method generates a report data chunk suitable for writing to a text file.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Report => \$report
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Report = shift;                                           # Get object
  my %args   = @_;                                              # Get arguments
  my $report = $args{Report};                                   # Get scalar reference for report
  my $source = $Report->{SourceLang};
  my $target = $Report->{TargetLang};
  $$report   = join( "\t",                                      # Compose record header
                     "ID",
                     "Source: $source",
                     "Target: $target",
                     "Hint" ) . "\n";
  foreach my $id ( sort( keys( %{$Report->{IDField}} ) ) ) {    #
    my $left  = $Report->{IDField}->{$id};
    my $right = $Report->{Pairs}->{$Report->{IDField}->{$id}};  #
    my $hint  = $Report->{Hints}->{$Report->{IDField}->{$id}};  #
    $ASCII2HEX->hex2ascii( Data => \$left );
    $ASCII2HEX->hex2ascii( Data => \$right );
    $$report .= join( "\t",                                     # Compose record header
                      $id,
                      $left,
                      $right,
                      $hint ) . "\n";
  }
  return(1);
}


sub _unreport {
  # This private method parse a report data chunk back into a record object member.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Report => \$report
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $Report->_unreport( Report => \$report );
  my $Report                          = shift;                                # Get object
  my %args                            = @_;                                   # Get arguments
  my $report                          = $args{Report};                        # Get scalar reference for report
  my @records                         = split( /\n/, $$report );              # Split on newline
  my $header                          = shift( @records );                    # Get header
  my ( $id, $source, $target, $hint ) = split( /\t/, $header );               #
  my ( $sourceLang )                  = ( $source =~ m/^Source: (.+)$/i );    # Get source language code
  my ( $targetLang )                  = ( $source =~ m/^Target: (.+)$/i );    # Get target language code
  foreach my $record ( @records ) {                                           # Parse out each record
    my ( $id,                                                               # Get record components
         $location,
         $source,
         $target,
         $hint ) = split( /\t/, $record );
    $Report->{Pairs}->{$id} = { Location    => $location,                   # Construct report record
                                $sourceLang => $source,
                                $targetLang => $target,
                                Hint        => $hint };
  }
  return(1);
}
