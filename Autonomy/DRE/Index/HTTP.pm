#!/usr/local/bin/perl
#
#   NetSoup::Autonomy::DRE::Index::HTTP.pm v00.00.01a 12042000
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
#       method  -  description


package NetSoup::Autonomy::DRE::Index::HTTP;
use strict;
use NetSoup::Core;
use NetSoup::Protocol::BatchUp;
@NetSoup::Autonomy::DRE::Index::HTTP::ISA = qw( NetSoup::Core );
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Hostname       => $hostname
  #              Port           => 0 .. 65535
  #              BatchSize      => 1 .. 4096
  #              KillDuplicates => "_DREREFERENCE_DREREFERENCE_DRETITLE_"
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Query                = shift;                   # Get DRE Query object
  my %args                 = @_;                      # Get arguments
  $Query->{Hostname}       = $args{Hostname};         # DRE Hostname/IP Address
  $Query->{Port}           = $args{Port};             # DRE Port Number
  $Query->{BatchSize}      = $args{BatchSize};             #
  $Query->{KillDuplicates} = $args{KillDuplicates} || "_DREREFERENCE_DREREFERENCE_DRETITLE_";             #
  $Query->{BatchUp}        = NetSoup::Protocol::BatchUp->new( Hostname => $Query->{Hostname},
                                                              Port     => $Query->{Port},
                                                              QLength  => $Query->{BatchSize},
                                                              Prefix   => "POST /DREADDDATA?KILLDUPLICATES=$Query->{KillDuplicates}\n\n",
                                                              Postfix  => "\n#DREENDDATA_DRETITLE_REFERENCE_\n" );
  return( $Query );
}


sub idx {
  # This method adds an IDX entry to the BatchUp object.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              DREREFERENCE => $DREREFERENCE
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Query           = shift;                   # Get DRE Query object
  my %args            = @_;                      # Get arguments
  my $DREREFERENCE    = $args{DREREFERENCE};
  my $DRETITLE        = $args{DRETITLE};
  my $Fields          = $args{Fields} || {};
  my $DRECONTENT      = $args{DRECONTENT};
  my $DREDBNAME       = $args{DREDBNAME};
  my $DRESTORECONTENT = $args{DRESTORECONTENT} || "n";
  my $DREDATE         = $args{DREDATE} || time;
  my $IDX             = join( "",
                              "#DREREFERENCE $DREREFERENCE\n",
                              "#DRETITLE $DRETITLE\n",
                              &{ sub {
                                   my $fields = "";
                                   foreach my $key ( keys %{$Fields} ) {
                                     $fields .= "#DREFIELD $key=\"$Fields->{$key}\"\n",
                                   }
                                   return( $fields );
                                 } },
                              "#DRECONTENT\n$DRECONTENT\n",
                              "#DREDBNAME $DREDBNAME\n",
                              "#DRESTORECONTENT $DRESTORECONTENT\n",
                              "#DREDATE $DREDATE\n",
                              "#DREENDDOC\n" );
  $Query->{BatchUp}->add( Data => $IDX );
  return(1);
}
