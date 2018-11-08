#!/usr/local/bin/perl
#
#   NetSoup::XHTML::HyperGlot.pm v00.00.01z 12042000
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
#   Description: This Perl 5.0 class provides an object oriented
#                interface to web based language glossaries.
#
#
#   Methods:
#       initialise  -  This method is the object initialiser for this class
#       configure   -  This method configures an existing object


package NetSoup::XHTML::HyperGlot;
use strict;
use NetSoup::Text::Glossary;
use NetSoup::XHTML::HyperGlot::Extract;
use NetSoup::XHTML::HyperGlot::Restore;
use NetSoup::XHTML::HyperGlot::Report;
use NetSoup::XHTML::HyperGlot::Tree;
@NetSoup::XHTML::HyperGlot::ISA = qw( NetSoup::XHTML::HyperGlot::Extract
                                      NetSoup::XHTML::HyperGlot::Restore
                                      NetSoup::XHTML::HyperGlot::Report
                                      NetSoup::XHTML::HyperGlot::Tree );
1;


=pod

  DESCRIPTION
  
  This is generally designed to be a much improved version of the
  RipStuff classes.
  
  What I am aiming for is a set of classes that will take any arbitrary
  XML, XHTML or similar format document and provide a consistent set of
  methods for language translation.
  
  Options available will include specifying the source and target
  languages, multiple language support, translator hints, translation
  glossaries etc.
  
  PROCESS
  
  1. Take a chunk of XML format data.
  
  2. Parse it down into a DOM2.
  
  3. Traverse the DOM2, comparing each string against those already
     in the translation glossary database.
  
  4. Suggest translation for each string found.

  TODO

=cut


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash {
  #           SourceLang => $sourceLang
  #           TargetLang => $targetLang
  #         }
  # Result Returned:
  #    boolean
  # Example:
  #    my $HyperGlot = NetSoup::XHTML::HyperGlot->new();
  my $HyperGlot            = shift;              # Get object
  my %args                 = @_;                 # Get arguments
  $HyperGlot->{UsingI18N}  = 0;                  # Flags private use of the I18N XHTML widget
  $HyperGlot->{SourceLang} = $args{SourceLang};  # Source language code
  $HyperGlot->{TargetLang} = $args{TargetLang};  # Target language code
  $HyperGlot->{ID}         = 0;                  # Counter for unique ID field
  $HyperGlot->{IDField}    = {};                 # Holds unique ID/source string pairs
  $HyperGlot->{Pairs}      = {};                 # Holds source/target language pairs
  $HyperGlot->{Hints}      = {};                 # Holds source language descriptive hints
  return(1);
}


sub configure {
  # This method configures an existing object.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash {
  #           SourceLang => $sourceLang
  #           TargetLang => $targetLang
  #         }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $HyperGlot            = shift;              # Get object
  my %args                 = @_;                 # Get arguments
  $HyperGlot->{SourceLang} = $args{SourceLang};  # Source language code
  $HyperGlot->{TargetLang} = $args{TargetLang};  # Target language code
  return(1);
}
