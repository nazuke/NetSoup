#!/usr/local/bin/perl -w
#
#   NetSoup::XML::DOM2::Traversal::t::DOM2.pl v00.00.01a 12042000
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
use NetSoup::XML::DOM2;
use NetSoup::XML::DOM2::Traversal::DocumentTraversal;


my $DOM  = NetSoup::XML::DOM2->new();
my $data = "";
while( <DATA> ) { $data .= $_ }
my $Document          = $DOM->parse( XML => \$data );
my $DocumentTraversal = NetSoup::XML::DOM2::Traversal::DocumentTraversal->new();
my $NodeIterator      = $DocumentTraversal->createNodeIterator( Root                     => $Document->firstChild(),
                                                                WhatToShow               => undef,
                                                                Filter                   => sub {},
                                                                EntityReferenceExpansion => 0 );
my $node = undef;
NODE: while( $node = $NodeIterator->nextNode() ) {
  print( STDERR $node->nodeName() . "\n" );
}
$DOM->debug( "Done" );
exit(0);


__DATA__
<?xml version="1.0" encoding="UTF-8"?>


<!DOCTYPE html
  PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "DTD/xhtml1-strict.dtd">


<html>
  <head>
    <title>Test</title>
    <meta content="Hello"/>
  </head>
  <body>
    <h1>This is a header</h1>
    <img src="/images/file.jpg" alt=">>>First Image<<<"/>
    <!-- < This is a comment > -->
        <p>
            <a href="http://www.jason.holland.dial.pipex.com/" onLoad="alert('It\'s XHTML!')">
              This is a <em>link</em>
          </a>
        </p>
    <table width="100%">
      <tr>
        <td>
          <h3>This "string" is inside a table</h3>
        </td>
      </tr>
      <tr>
        <td>
          <table width="100%">
            <tr>
              <td>
                <p>
                  Here's another in a nested table.
                  With some more text followed by a line break<br/>
                  continuing on for a while.
                </p>
              </td>
            </tr>
            <tr>
              <td>
                <img src="/more/images/table.jpg" alt="A <table> Image"/>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
    <p>
      <strong>
        Strong Body Content...
        with a carriage return.
      </strong>
    </p>
    <h2>Another header</h2>
    <p>This is a <em>"quoted string"</em>.</p>
    <p>
      The following is a CDATA section:
      <![CDATA[
        This is within the CDATA section!
        This is within the CDATA section!
        This is within the CDATA section!
        This is within the CDATA section!
      ]]>
    </p>
    <img src="/images/file.jpg" alt="<><>ALT TEXT><><"/>
    <p>
      Here's an &lt;IMG&gt; tag without an ALT attribute:
      <img src="/images/picture.jpg"/>
    </p>
  </body>
</html>
