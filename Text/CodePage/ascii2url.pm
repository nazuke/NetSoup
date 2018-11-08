#!/usr/local/bin/perl
#
#   NetSoup::Text::CodePage::ascii2url.pm v00.00.01a 12042000
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
#       initialise  -  This method is the object initialiser
#       ascii2url   -  This method encodes ascii strings using url escapes
#       url2ascii   -  This method converts url-encoded strings to plain ascii data


package NetSoup::Text::CodePage::ascii2url;
use NetSoup::Text::CodePage;
@NetSoup::Text::CodePage::ascii2url::ISA = qw( NetSoup::Text::CodePage );
1;


sub initialise {
  # This method is the object initialiser.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    boolean
  # Example:
  #    $object->initialise();
  my $object           = shift;              # Get object
  $object->{Url2ascii} = {};                 # Initialise character set hash reference
  foreach my $i ( 0   .. 47,                 # Iterate over reserved character ranges
                  58  .. 64,
                  91  .. 96,
                  123 .. 255 ) {
    my $char = pack( "C1", $i );             # Pack value into byte
    my @char = unpack( "H2", $char );        # Unpack into hex format string
    my $key  = '%';                          # Initialise new hash key
    foreach ( @char ) { $key .= uc( $_ ) }   # Build hash key
    $object->{Url2ascii}->{$key} = chr($i);  # Insert new key/pair into hash
  }
  return( $object );
}


sub ascii2url {
  # This method encodes ascii strings using url escapes.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Data => \$data
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $object->ascii2url( Data => \$data );
  my $object = shift;                                  # Get object
  my %args   = @_;                                     # Get arguments
  my $data   = $args{Data};                            # Get unencoded data
  my @chars  = split( //, $$data );                    # Split into characters
  $$data     = "";
  foreach my $i ( @chars ) {                           # Iterate over raw characters
    my $c = "";                                        # Character buffer
    foreach my $j ( keys %{$object->{Url2ascii}} ) {   # Find code in hash
      $c = $j if( $object->{Url2ascii}->{$j} eq $i );  # Obtain encoded character from hash
    }
    $$data .= ( $c || $i );
  }
  return(1);
}


sub url2ascii {
  # This method converts url-encoded strings to plain ascii data.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Data => \$data
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $object->url2ascii( Data => \$data );
  my $object = shift;                                       # Get object
  my %args   = @_;                                          # Get arguments
  my $data   = $args{Data};                                 # Get unencoded data
  foreach my $search ( keys %{$object->{Url2ascii}} ) {     # Iterate over translation table
    $$data =~ s/$seach/$object->{Url2ascii}->{$search}/gi;  # Perform string substitution
  }
  return(1);
}
