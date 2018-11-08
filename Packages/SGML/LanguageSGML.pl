#!/usr/local/bin/perl -w
#
#   NetSoup::Packages::XML::LanguageXML.pl v00.00.01a 12042000
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
#   Description: This Perl 5.0 script exercises the XML DOM class.


use strict;
use Getopt::Std;
use NetSoup::Files::Directory;
use NetSoup::Files::Load;
use NetSoup::Text::Language;
use NetSoup::XML::Parser::Preprocessor;
use NetSoup::XML::Util;


my %OPTIONS = ();
my $NoFiles = 0;
my %Totals  = ();
getopts( "dhlv", \%OPTIONS );
if( $OPTIONS{h} ) {
  print( join( "", <DATA> ) );
  exit(0);
}
open( LOGFILE, ">LanguageXML.log" ) if( $OPTIONS{l} );
foreach my $pathname ( @ARGV ) {
  if( -d $pathname ) {
    my $Directory = NetSoup::Files::Directory->new();
    $Directory->descend( Pathname    => $pathname,
                         Recursive   => 1,
                         Directories => 0,
                         Extensions  => NetSoup::XML::Util->accepts(),
                         Callback    => sub {
                           my $pathname = shift;
                           file( $pathname );
                         } );
  } else {
    file( $pathname );
  }
}
print( STDOUT "\nTotal No. Files\t$NoFiles\n\n" ) if( $OPTIONS{v} );
print( LOGFILE "\nTotal No. Files\t$NoFiles\n\n" ) if( $OPTIONS{l} );
foreach my $key ( sort keys %Totals ) {
  my $value   = $Totals{$key};
  my $percent = ( 100 / $NoFiles ) * $value;
  print( STDOUT "\t$key\t$value\t$percent\%\n" ) if( $OPTIONS{v} );
  print( LOGFILE "\t$key\t$value\t$percent\%\n" ) if( $OPTIONS{l} );
}
close( LOGFILE ) if( $OPTIONS{l} );
exit(0);


sub file {
  my $pathname    = shift;
  my $data        = "";
  my $Load        = NetSoup::Files::Load->new();
  $Load->load( Pathname => $pathname, Data => \$data );
  my $lang        = language( $pathname, \$data );
  $NoFiles       += 1;
  $Totals{$lang} += 1;
  print( STDOUT "$pathname\t$lang\n" ) if( $OPTIONS{v} );
  print( LOGFILE "$pathname\t$lang\n" ) if( $OPTIONS{l} );
  return( $lang );
}


sub language {
  my $pathname     = shift;
  my $XML          = shift;
  my $Text         = "";
  my $lang         = "ERROR";
  my $Language     = NetSoup::Text::Language->new();
  my $PP           = NetSoup::XML::Parser::Preprocessor->new( Debug => $OPTIONS{d} );
   my $preprocessed = $PP->preprocessor( XML        => $XML,
                                        Whitespace => "compact" );
  if( ! defined $preprocessed ) {
    print( STDERR "\n$pathname\n" ) if( $OPTIONS{v} );
    print( LOGFILE "\n$pathname\n" ) if( $OPTIONS{l} );
    foreach my $error ( $PP->errors() ) {
      print( STDERR $error ) if( $OPTIONS{v} );
      print( LOGFILE $error ) if( $OPTIONS{l} );
    }
    return( $lang );
  } else {
    foreach my $Symbol ( @{$PP->symbols()} ) {
      $Text .= $Symbol->nodeValue() . "\n";
    }
  }
  $lang = $Language->identify( Text => \$Text ) || "UNKNOWN";
  return( $lang );
}


__DATA__


LanguageSGML.pl - Identifies the written language of an SGML document.

Usage:

    LanguageSGML.pl [-dhlv] dir1 [dir2...] file1 [file2...]

    -d  Display debugging messages

    -h  Display this help

    -l  Record log file to CheckXML.log

    -v  Verbose mode

Copyright (C) 2000  Jason Holland <jason.holland@dial.pipex.com>


