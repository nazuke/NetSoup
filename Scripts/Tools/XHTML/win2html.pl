#!/usr/local/bin/perl
#
#   NetSoup::Scripts::Tools::Html::win2html.pl v00.00.01a 12042000
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
#   Description: This Perl 5.0 script scans a directory tree of Html files
#                and converts all Microsoft Windows encoded characters to
#                their equivalent Html Entity Tag encodings.
#
#
#         Usage: ripHtml.pl pathname [ pathname ... ]
#                A tilde character at the end of the pathname informs
#                the program that a 'stuff' action should occur.
#                A pathname with no tilde will cause a rip action.


use NetSoup::Text::CodePage::html2win;
use NetSoup::Files::Directory;
use NetSoup::Files::Load;
use NetSoup::Files::Save;
use NetSoup::Parse::Html::Eval::Test;


foreach ( @ARGV ) {                                                                  # Iterate over pathname arguments
  my $pathname  = $_;                                                              # Store pathname argument
  $pathname     =~ s:/$::;                                                         # Chop off trailing slash
  my $directory = NetSoup::Files::Directory->new();                      # Get new directory object
  my $test      = NetSoup::Parse::Html::Eval::Test->new();
  my $html2win  = NetSoup::Text::CodePage::html2win->new();
  my $load      = NetSoup::Files::Load->new();
  my $save      = NetSoup::Files::Save->new();
  my $callback  = sub {
    my $pathname = shift;
    my $data     = "";
    return(1) if( ! $test->isHtml( Pathname => $pathname, Data => \$data ) );    # Text for valid Html
    print( STDERR "Processing\t$pathname\n" );
    $load->load( Pathname => $pathname, Data => \$data );                        # Load Html data
    $html2win->html2win( Data => \$data );                                       # Convert entity tags to Win encodings
    $html2win->win2html( Data => \$data );                                       # Convert Win encodings to entity tags
    $save->save( Pathname => $pathname,                                          # Save out merged data
                 Data     => \$data,
                 Mode     => ">" );
    return(1);
  };
  $directory->descend( Pathname    => $pathname,                                   # Descend directory
                       Recursive   => 1,
                       Callback    => $callback,
                       Directories => 0 );
}
exit(0);
