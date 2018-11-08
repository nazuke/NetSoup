#!/usr/local/bin/perl
#
#   NetSoup::Text::Glossary::Written::Latin.pm v00.00.01a 12042000
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
#       lLookup  -  This method performs a looks up an array of strings in the database
#       lFetch   -  This method fetches a string value from the database
#       lStore   -  This method stores an array of string values in the database


package NetSoup::Text::Glossary::Written::Latin;
use strict;
@NetSoup::Text::Glossary::ISA = qw( NetSoup::Text::Glossary );
1;


sub lLookup {
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
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $object = shift;                                                               # Get object
  my %args   = @_;                                                                  # Get arguments
  foreach my $source ( keys ( %{$args{Strings}} ) ) {                               # Iterate over hash of strings
    if( $source =~ m/[!\(\)\{\}\[\]:;\"\'|\\`\<,\>\.\/\?]+/gs ) {                   # Attempt to split into logical blocks
      my @fragments = split( /[!\(\)\{\}\[\]:;\"\'|\\`\<,\>\.\/\?]+/gs, $source );  # Stores sentence fragments
      my %hash      = ();                                                           # Hash of string fragments
      foreach ( @fragments ) { $hash{$_} = $_ }                                     # Populate hash
      foreach my $frag ( @fragments ) {                                             # Look up each fragment in the glossary
        $object->( SourceLang => $args{SourceLang},                                 # Thunk down
                   TargetLang => $args{TargetLang},
                   Strings    => \%hash );
      }
      foreach my $key ( keys ( %hash ) ) {
        $args{Strings}->{$source} =~ s/\Q$key\E/$hash{$key}/gs;                     # Replace sub-strings in main hash
      }
    } else {
      $object->( SourceLang => $args{SourceLang},
                 TargetLang => $args{TargetLang},
                 Strings    => $args{Strings} );
    }
  }
  return(1);
}


sub lFetch {
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
  my $object = shift;                  # Get object
  my %args   = @_;                     # Get arguments
  my $db     = $object->_db( %args );  # Get hash reference to glossary database
  my $string = $args{String};
  if( exists $$db{$string} ) {         # Look for existing string in database
    $$string = $$db{$string};          # Update with string in database
  } else {
    return(0);                         # Return 0 on string not found
  }
  return(1);
}


sub lStore {
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
  my $object = shift;                                # Get object
  my %args   = @_;                                   # Get arguments
  my $db     = $object->_db( %args );                # Get hash reference to glossary database
  my $string = $args{String};
  my $target = "";
  if( exists $$db{$string} ) {                       # Look for existing string in database
    $target = $$db{$string} if( $args{Overwrite} );  # Overwrite existing database string
  } else {
    $target = $$db{$string};                         # Insert new database string
  }
  return( $target );
}
