#!/usr/local/bin/perl -w


package NetSoup::Persistent::TabText;
use NetSoup::Core;
use NetSoup::Encoding::Hex;
@NetSoup::Persistent::TabText::ISA = qw( NetSoup::Core );
my $HEX = NetSoup::Encoding::Hex->new();
1;


sub initialise {
  my $TabText          = shift;
  my %args             = @_;
  $TabText->{Pathname} = $args{Pathname};
  $TabText->{Encode}   = $args{Encode} || 0;
  $TabText->{Lockfile} = $TabText->{Pathname} . ".lock";
  $TabText->{DB}       = {};
  $TabText->{Dirty}    = 0;
  $TabText->{Fields}   = {};
  my $count = 0;
  foreach my $name ( @{$args{Fields}} ) {
    chomp( $name );
    $TabText->{Fields}->{$name} = $count;
    $count++;
  }
  if( $TabText->load() ) {
    $TabText->{OK} = 1;
  } else {
    $TabText->{OK} = 0;
    return( undef );
  }
  return( $TabText );
}


sub load {
  # This method populates the TabText from the disk file.
  my $TabText = shift;
  my $timeout = 60;
  my $flag    = 0;
 TIMEOUT: for( my $i = $timeout ; $i >= 0 ; $i-- ) {
    if( -e $TabText->{Lockfile} ) {
      sleep(1);
    } else {
      $flag = 1;
      last TIMEOUT;
    }
  }
  if( $flag == 1 ) {
    open( LOCKFILE, ">" . $TabText->{Lockfile} );
    print( LOCKFILE "LOCKFILE" );
    close( LOCKFILE );
    if( -e $TabText->{Pathname} ) {
      if( open( FILE, $TabText->{Pathname} ) ) {
        while( <FILE> ) {
          chomp;
          my ( $key, @fields )   = split( /\t/, $_ );
          if( $TabText->{Encode} ) {
            $key = $HEX->hex2bin( Data => $key );
            foreach my $field ( @fields ) {
              $field = $HEX->hex2bin( Data => $field );
            }
          }
          $TabText->{DB}->{$key} = \@fields;
        }
        close( FILE );
      } else {
        return(0);
      }
    } else {
      return(1);
    }
    return(1);
  }
  return(0);
}


sub save {
  # This method writes the TabText to the disk file.
  my $TabText = shift;
  if( $TabText->{Dirty} != 0 ) {
    if( open( FILE, ">$TabText->{Pathname}" ) ) {
      foreach my $key ( keys %{$TabText->{DB}} ) {
        if( defined $key ) {
          my @fields = @{$TabText->{DB}->{$key}};
          if( $TabText->{Encode} ) {
            $key       = $HEX->bin2hex( Data => $key );
            foreach my $field ( @fields ) {
              $field = $HEX->bin2hex( Data => $field );
            }
          }
          my $line = join( "\t", $key, @fields ) . "\n";
          print( FILE $line );
        }
      }
      close( FILE );
    } else {
      unlink( $TabText->{Lockfile} );
      return(0);
    }
  }
  unlink( $TabText->{Lockfile} );
  return(1);
}


sub DESTROY {
  # This method is the object destructor.
  my $TabText = shift;
  $TabText->save() if( $TabText->{OK} == 1 );
  return(1);
}


sub AUTOLOAD {
  # This method sets/gets a field in the TabText object.
  my $TabText   = shift;
  my %args      = @_;
  my $Key       = $args{Key};
  my $Value     = $args{Value} || undef;
  my ( $Field ) = ( $AUTOLOAD =~ m/::([^:]+)$/ );
  my $idx       = $TabText->{Fields}->{$Field};
  if( defined $Value ) {
    $TabText->{DB}->{$Key}->[$idx] = $Value;
    $TabText->{Dirty} = 1;
  }
  return( $TabText->{DB}->{$Key}->[$idx] );
}


sub add {
  # This method adds a new entry to the TabText.
  my $TabText = shift;
  my %args     = @_;
  if( $TabText->available( Key => $args{Key} ) ) {
    $TabText->modify( %args );
    return(1);
  }
  return(0);
}


sub modify {
  # This method updates an entry's details in the TabText.
  my $TabText = shift;
  my %args    = @_;
  my $Key     = $args{Key};
  delete( $args{Key} );
  foreach my $field ( keys %args ) {
    my $idx = $TabText->{Fields}->{$field};
    $TabText->{DB}->{$Key}->[$idx] = $args{$field};
  }
  $TabText->{Dirty} = 1;
  return(1);
}


sub remove {
  # This method removes an entry from the TabText.
  my $TabText = shift;
  my %args    = @_;
  my $Key     = $args{Key};
  my $hash    = $TabText->{DB};
  delete( $$hash{$Key} );
  $TabText->{Dirty} = 1;
  return(1);
}


sub available {
  # This method tests for the availability of a key in the TabText object.
  my $TabText = shift;
  my %args    = @_;
  my $Key     = $args{Key};
  my $hash    = $TabText->{DB};
  return(0) if( defined( $hash->{$Key} ) );
  return(1);
}


sub empty {
  # This method returns true if the TabText object is emtpy.
  my $TabText = shift;
  my %args     = @_;
  if( keys( %{$TabText->{DB}} ) == 0  ) {
    return(1);
  }
  return(0);
}


sub keylist {
  # This method returns an array of the keys in the TabText object.
  my $TabText = shift;
  my %args     = @_;
  return( keys( %{$TabText->{DB}} ) );
}
