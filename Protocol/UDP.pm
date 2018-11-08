#!/usr/local/bin/perl -w

package NetSoup::Protocol::UDP;
use strict;
use Socket;
use Sys::Hostname;
use NetSoup::Core;
@NetSoup::Protocol::UDP::ISA = qw( NetSoup::Core );
1;


sub initialise {
  my $UDP        = shift;
  my %args       = @_;
  $UDP->{HANDLE} = undef;
  return( $UDP );
}


sub broadcast {
  my $UDP      = shift;
  my %args     = @_;
  my $callback = $args{Callback};
  my $message  = $args{Message};
  my $IP       = $args{IP}       || undef;
  my $hostname = $args{Hostname} || undef;
  my $iaddr    = $IP || gethostbyname( $hostname );


  if( socket( $UDP->{HANDLE}, PF_INET, SOCK_DGRAM, getprotobyname( 'udp' ) ) ) {


    my $sin = sockaddr_in( 8888, $iaddr );
    
    
    if( send( $UDP->{HANDLE}, $message, 0, $sin ) ) {


      print( "OK" );
    } else {


      print( "Send Fail" );
      return( undef );
    }


  } else {
    return( undef );
  }
  return( $UDP );
}


sub receive {
  my $UDP      = shift;
  my %args     = @_;
  my $IP       = $args{IP}       || undef;
  my $hostname = $args{Hostname} || undef;
  my $iaddr    = $IP || gethostbyname( $hostname );
  my $paddr    = sockaddr_in( 8888, $iaddr );
  my $message  = "";
  if( socket( $UDP->{HANDLE}, PF_INET, SOCK_DGRAM, getprotobyname( 'udp' ) ) ) {
    #if( bind( $UDP->{HANDLE}, $paddr ) ) {
      if( recv( $UDP->{HANDLE}, $message, 4, 0 ) ) {
        ;
      } else {
        print( "recv()\n" );
      }
#    } else {
#      print( "bind()\n" );
#    }
  }  else {
    print( "socket()\n" );
    return( undef );
  }
  return( $message );
}
