#!/usr/local/bin/perl
#
#   NetSoup::Packages::XML::CountXHTML.pl v00.00.01a 12042000
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
#   Description: This Perl 5.0 script counts words in XHTML files.
#
#
#         Usage: CountXHTML.pl file [file1] [file2] ...


use NetSoup::Files::Directory;
use NetSoup::Files::Load;
use NetSoup::XHTML::Util::CountWords;


my $supreme  = 0;                                                    # Initialise supreme total
my $multiple = -1;                                                   # Initialise multiple arguments counter
foreach my $infile ( @ARGV ) {                                       # Loop over filename arguments
  my $total = 0;                                                     # Initialise grand total
  if( -d $infile ) {                                                 # Descend if directory
    line( "Descending: $infile", $infile );
    $Directory = NetSoup::Files::Directory->new();                   # Get new directory object
    $Directory->descend( Pathname  => $infile,                       # Descend directory
                         Recursive => 1,                             # Descend sub-directories
                         Callback  => sub { doFile( (shift),         # Run callback on each file found
                                                    \$total,
                                                    $infile ) } );
  } elsif( -f $infile ) {                                            # Evaluate if regular file
    doFile( $infile, \$total, $infile );
  } else {                                                           # Skip if not file or directory
    line( "ERROR Unknown File Type: $infile", $infile );
  }
  $supreme += $total;                                                # Increment supreme total
  $multiple++;                                                       # Increment multiple arguments counter
}
line( "\n$supreme\tSupreme Total Words", $infile ) if( $multiple );  # Output supreme total if multiple arguments
exit(0);


sub doFile {
  # This function counts the words in an XHTML file, other file types are skipped.
  my $pathname   = shift;                                     # Get pathname of file
  my $total      = shift;                                     # Get reference to total
  my $infile     = shift;
  my $CountWords = NetSoup::XHTML::Util::CountWords->new();   # Get new Words object
  my $Load       = NetSoup::Files::Load->new();
  my $XML        = "";                                        # Initialise XML container
  return(1) if( $pathname !~ m/\..*x?(ht|sg|x)ml?$/i );       # Return if not an XHTML file
  $Load->load( Pathname => $pathname,                         # Load XML data
               Data     => \$XML );
  my $count = $CountWords->xml( XML => \$XML );               # Count words in XHTML
  if( defined $count ) {
    $$total += $count;                                        # Increment grand total
    line( qq($count\tTotal Words in "$pathname"), $infile );  # Output total for this file group
  } else {
    line( qq(Error in "$pathname"), $infile );                # Output error message
  }
  return(1);
}


sub line {
  # This function sends output to STDOUT
  my $message  = shift;
  my $pathname = shift;
  if( $^O =~ m/mac/i ) {
    open( FILE, ">>$pathname~" );
    print( FILE "$message\n" );
    close( FILE );
  }
  print( STDOUT "$message\n" );
}
