#!/usr/local/bin/perl
package src::lib::Core;
use UNIVERSAL;
@src::lib::Core::ISA = qw( UNIVERSAL );
1;
sub new {
  my $package = shift;
  my $class   = ref( $package ) || $package;
  my $object  = {};
  bless( $object, $class );
  $object->initialise( @_ );
  return( $object );
}
sub initialise {
  my $object = shift;
  return(1);
}
sub debug {
  my $package  = shift;
  my $class    = $package || ref( $package );
  my $message  = shift;
  my $level    = shift || undef;
  my $pathname = $0;
  $pathname    =~ s/\.[^\.]+$//;
  my $output   = 0;
  if( defined $level ) {
    $output++ if( $class->{__DDebugLevel__} >= $level );
  } else {
    $output++;
  }
  return(1) if( ! $output );
  chomp( $message );
  if( $^O =~ m/^mac/ ) {
    $message =~ s/\t/    /gs;
    $message =~ s/\x0A/\n/gs;
  }
  print( STDERR ref($class) . "\t\%$$\t$message\n" );
  return(1) if( ! $class->{__DLogging__} );
  if( open( FILE, ">>$pathname.log" ) ) {
    print( FILE "$class:$$\t$message\n" );
    close( FILE );
  }
  return(1);
}
sub debugLevel {
  my $object                 = shift;
  my $level                  = shift || undef;
  $object->{__DDebugLevel__} = $level if( $level );
  return( $object->{__DDebugLevel__} || undef );
}
sub startLog {
  my $object              = shift;
  $object->{__DLogging__} = 1;
  return( $object->{__DLogging__} || undef );
}
sub stopLog {
  my $object              = shift;
  $object->{__DLogging__} = 0;
  return(1);
}
sub dumpArgs {
  my $object  = shift;
  my $hashref = shift;
  print( STDERR "\n\n" );
  foreach ( keys( %$hashref ) ) {
    print( STDERR ref( $object ) . "\t$_\t$$hashref{$_}\n" );
  }
  print( STDERR "\n\n" );
  return(1);
}
