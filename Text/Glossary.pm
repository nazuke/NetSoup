#!/usr/local/bin/perl
#
#   NetSoup::Text::Glossary.pm v00.00.01a 12042000
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
#   Description: This Perl 5.0 class provides an object oriented interface
#                to text based language glossary databases.
#
#
#   Methods:
#       initialise  -  This method is the object initialiser for this class
#       lookup      -  This method performs a looks up an array of strings in the database
#       fetch       -  This method fetches a string value from the database
#       store       -  This method stores an array of string values in the database


package NetSoup::Text::Glossary;
use strict;
use NetSoup::Core;
use NetSoup::Persistent::Store;
@NetSoup::Text::Glossary::ISA = qw( NetSoup::Core );
1;


sub lookup {
  # This method performs a looks up an array of strings in the database,
  # returning translations if any exist and storing any new text if not
  # previously translated.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              SourceLang => $sourceLang
  #              TargetLang => $targetLang
  #              Strings    => \%hash
  #              Overwrite  => 0 | 1
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Glossary  = shift;                                    # Get object
  my %args      = @_;                                       # Get arguments
  my $db        = $Glossary->_db( %args );                  # Get hash reference to glossary database
  my $strings   = $args{Strings};                           # Get strings hash reference
  my $overwrite = $args{Overwrite} || 0;                    # Get entry overwrite flag
  foreach my $source ( keys %$strings ) {                   # Iterate over hash of strings
    if( exists( $$db{$source} ) ) {
      $$db{$source} = $$strings{$source} if( $overwrite );  # Overwrite database entry
    } else {
      $$db{$source} = $$strings{$source};
    }
    $$strings{$source} = $$db{$source};                     # Update Strings hash
  }
  return(1);
}


sub fetch {
  # This method fetches a string value from the database.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              SourceLang => $sourceLang
  #              TargetLang => $targetLang
  #              String     => \$string
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Glossary = shift;                    # Get object
  my %args     = @_;                       # Get arguments
  my $db       = $Glossary->_db( %args );  # Get hash reference to glossary database
  my $string   = $args{String};
  if( exists $$db{$$string} ) {            # Look for existing string in database
    $$string = $$db{$$string};             # Update with string in database
  } else {
    return(0);                             # Return 0 on string not found
  }
  return(1);
}


sub store {
  # This method stores an array of string values in the database.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              SourceLang => $sourceLang
  #              TargetLang => $targetLang
  #              String     => \$string
  #              Overwrite  => 0 | 1
  #            }
  # Result Returned:
  #    scalar
  # Example:
  #    method call
  my $Glossary  = shift;                        # Get object
  my %args      = @_;                           # Get arguments
  my $db        = $Glossary->_db( %args );      # Get hash reference to glossary database
  my $string    = $args{String};
  my $overwrite = $args{Overwrite} || 0;
  my $target    = "";
  if( exists $$db{$$string} ) {                 # Look for existing string in database
    $target = $$db{$$string} if( $overwrite );  # Overwrite existing database string
  } else {
    $target = $$db{$$string};                   # Insert new database string
  }
  return( $target );
}


sub _db {
  # This private method returns a reference to a glossary database hash.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              SourceLang => $sourceLang
  #              TargetLang => $targetLang
  #            }
  # Result Returned:
  #    \%hash
  # Example:
  #    method call
  my $Glossary = shift;                                          # Get object
  my %args     = @_;                                             # Get arguments
  my %db       = ();                                             # Prepare hash for database
  my $pathname = $Glossary->getConfig( Key => "GlotDBPath" );    # Get glossary database path
  $pathname   .= "/$args{SourceLang}2$args{TargetLang}";         # Set glossary database access pathname
  tie %db, "NetSoup::Persistent::Store", Pathname => $pathname;  # Tie hash to glossary database
  return( \%db );
}
