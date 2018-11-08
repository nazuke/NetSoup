#!/usr/local/bin/perl -w


use strict;
use NetSoup::XML::DOM2;
use NetSoup::XML::Parser;
use NetSoup::XML::DOM2::Core::Document;
use NetSoup::XML::DOM2::Traversal::Serialise;


warn( "STARTING" );
{
  my $Document     = NetSoup::XML::DOM2::Core::Document->new( Debug => 1 );  # Create new empty Document object
  my $Serialise    = NetSoup::XML::DOM2::Traversal::Serialise->new( StrictSGML => 1 );        # Create new Serialise object
  my $Businesscard = $Document->createElement( TagName => "BusinessCard" );  # Add main element
  my %fields       = ( FirstName  => "Armitage",
                       SecondName => "III",
                       Job        => "Police Officer",
                       Location   => "Mars Colony" );
  $Document->appendChild( NewChild => $Businesscard );                       # Attach Businesscard to Document
  foreach my $field ( keys %fields ) {
    my $Field = $Document->createElement( TagName => $field );               # Create sub-element...
    my $Text  = $Document->createTextNode( Data => $fields{$field} );        # ...and a Text element
    $Field->setAttribute( Name => "type", Value => "text" );
    $Field->appendChild( NewChild => $Text );                                # Put Text element inside sub-element...
    $Businesscard->appendChild( NewChild => $Field );                        # ...put sub-element inside main element
  }
  my $target = "";                                                           # Will contain serialised XML document
  $Serialise->serialise( Node   => $Document,                                # Serialise DOM into XML data stream
                         Target => \$target );
  print( STDERR $target );                                                   # Display XML data
  my $Parser = NetSoup::XML::Parser->new();                                  # Create new Parser object
  my $Parsed = $Parser->parse( XML        => \$target,                       # Parse serialise XML into DOM2 Document object
                               Whitespace => "compact" );
  $target    = "";                                                           # Clear target scalar
  $Serialise->serialise( Node   => $Parsed,                                  # Serialise compiled DOM into XML data stream
                         Target => \$target );
  print( STDERR "\n" x 4 . $target );                                        # Display XML data
  $Document->DESTROY();
}
print( STDERR "\n" );
warn( "EXIT" );
exit(0);
