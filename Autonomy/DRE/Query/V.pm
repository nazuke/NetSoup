#!/usr/local/bin/perl -w


package NetSoup::Autonomy::DRE::Query::V;
use strict;
use NetSoup::Protocol::HTTP;
@NetSoup::Autonomy::DRE::Query::V::ISA = qw( NetSoup::Protocol::HTTP );
1;


sub initialise {
  my $V          = shift;
  my %args       = @_;
  $V->SUPER::initialise( %args );
  $V->{Config}   = {};
  $V->{NumDB}    = undef;
  $V->{Database} = {};
  $V->{Numeric}  = [];
  $V->{Hostname} = $args{Hostname};
  $V->{Port}     = $args{Port};
  $V->{Document} = $V->get( URL => "http://$V->{Hostname}:$V->{Port}/qmethod=V" );
  my %state      = ( Key => 1 );
  my @chars      = split( //, $V->{Document}->body() );
  my $key        = "";
  print( $V->{Document}->body() );
 PARSE: for( my $i = 0 ; $i < @chars ; $i++ ) {
  SWITCH: for( $chars[$i] ) {
      m/:/ && do {
        if( $state{Key} ) {
          $state{Key}   = 0;
          $V->{Conf}->{$key} = "";
        } else {
          $V->{Conf}->{$key} .= $chars[$i];
        }
        last SWITCH;
      };
      m/[\r\n]/ && do {
        $state{Key} = 1;
        if( $key eq "dbinfo" ) {
          last PARSE;
        }
        $key = "";
        last SWITCH;
      };
      m/\*/ && do {
        if( $chars[$i-1] eq "\n" ) {
          last PARSE;
        }
      };
      m/./ && do {
        if( $state{Key} ) {
          $key .= lc $chars[$i];
        } else {
          $V->{Conf}->{$key} .= $chars[$i];
        }
        last SWITCH;
      };
    }
  }
  $V->_parse_databases();
  return( $V );
}


sub _parse_databases {
  my $V           = shift;
  my %args        = @_;
  my $value       = $V->conf_field( Name => "databases" );
  ( $V->{NumDB} ) = ( $value =~ m/^(\d+)\[/ );
  $value          =~ s/^\d+\[(.+),\]$/$1/;
  foreach my $dbs ( split( /,/, $value ) ) {
    my ( $num, $name )      = split( /:/, $dbs );
    $V->{Database}->{$name} = 0;
    $V->{Numeric}->[$num]   = $name;
  }
  $V->_parse_dbinfo();
  return(1);
}


sub _parse_dbinfo {
  my $V     = shift;
  my %args  = @_;
  my $value = $V->conf_field( Name => "dbinfo" );
  $value    =~ s/^\d+\[(.+),\]$/$1/;
  foreach my $dbs ( split( /,/, $value ) ) {
    my ( $num, $docs, $sections )           = ( $dbs =~ m/^(.+):(.+)\((.+)\)$/ );
    $V->{Database}->{$V->{Numeric}->[$num]} = { Num      => $num,
                                                Docs     => $docs,
                                                Sections => $sections };
  }
  return(1);
}


sub numdb {
  my $V    = shift;
  my %args = @_;
  return( $V->{NumDB} );
}


sub conf_fields {
  my $V    = shift;
  my %args = @_;
  return( keys %{$V->{Conf}} );
}


sub conf_field {
  my $V    = shift;
  my %args = @_;
  my $name = $args{Name};
  return( $V->{Conf}->{$name} );
}


sub databases {
  my $V    = shift;
  my %args = @_;
  return( keys %{$V->{Database}} );
}


sub num_docs {
  my $V    = shift;
  my %args = @_;
  my $name = $args{Name};
  return( $V->{Database}->{$name}->{Docs} );
}


sub dre_fields {
  my $V    = shift;
  my %args = @_;
  return( keys %{$V->{Database}} );
}
