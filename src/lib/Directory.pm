#!/usr/local/bin/perl
package src::lib::Directory;
use src::lib::Files;
@src::lib::Directory::ISA = qw( src::lib::Files );
1;
sub descend {
  my $object       = shift;
  my %args         = @_;
  my ( $pathname ) = ( $args{Pathname} =~ m:^(.+)/?$: );
  my $recursive    = $args{Recursive} || undef;
  my $callback     = $args{Callback}  || undef;
  my $sep          = $object->separator();
  my @list         = ();
  return(0) if( ! opendir( DIR, $pathname ) );
  @list = readdir( DIR );
  closedir( DIR );
 SCAN: foreach my $i ( @list ) {
    if( -d "$pathname$sep$i" ) {
      next SCAN if( $i =~ m:^\.\.?$: );
      if( exists $args{Directories} ) {
        &$callback( "$pathname$sep$i" ) if( $args{Directories} == 1 );
      }
      $object->descend( Pathname  => "$pathname$sep$i",
                        Recursive => $recursive,
                        Callback  => $callback ) if( defined $recursive );
    } else {
      &$callback( "$pathname$sep$i" );
    }
  }
  return(1);
}
