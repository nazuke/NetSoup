#!/usr/local/bin/perl
#
#   NetSoup::Protocol::GTP::t::Client.pl v00.00.01a 12042000
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
#   Description: This Perl 5.0 script exercises the Glossary.pm class.


use NetSoup::Protocol::GTP::Client;
my $gtp  = NetSoup::Protocol::GTP::Client->new();


my %hash = ( "The quick brown fox"     => "The quick brown fox",
             "Jumps over the lazy dog" => "Jumps over the lazy dog" );
$gtp->debug( "Initial Lookup" );
$gtp->lookup( SourceLang => "UK",
              TargetLang => "DE",
              Strings    => \%hash );
foreach ( keys %hash ) { print( "$_\t$hash{$_}\n" ) }





%hash = ( "The quick brown fox"     => "Der schnell brun fox",
          "Jumps over the lazy dog" => "Jumpens oder der schweinhund" );
$gtp->debug( "Second Lookup" );
$gtp->lookup( SourceLang => "UK",
              TargetLang => "DE",
              Strings    => \%hash,
              Overwrite  => 1 );
foreach ( keys %hash ) { print( "$_\t$hash{$_}\n" ) }




%hash = ( "The quick brown fox"     => "The quick brown fox",
          "Jumps over the lazy dog" => "Jumps over the lazy dog" );
$gtp->debug( "Third Lookup" );
$gtp->lookup( SourceLang => "UK",
              TargetLang => "DE",
              Strings    => \%hash );
foreach ( keys %hash ) { print( "$_\t$hash{$_}\n" ) }




exit(0);
