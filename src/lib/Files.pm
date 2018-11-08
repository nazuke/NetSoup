#!/usr/local/bin/perl
package src::lib::Files;
use src::lib::Core;
@src::lib::Files::ISA = qw( src::lib::Core );
1;
sub separator {
  my $object    = shift;
  my $separator = "/";
 SWITCH: for( $^O ) {
    m/mac/i && do { $separator = ":"  ; last SWITCH };
    m/win/i && do { $separator = "\\" ; last SWITCH };
  }
  return( $separator );
}
sub buildTree {
  my $object    = shift;
  my %args      = @_;
  my $perms     = $args{Perms} || 0755;
  my $bare      = $args{Bare}  || 0;
  my $sep       = $object->separator();
  my $root      = $sep if( $args{Pathname} =~ m/^\Q$sep\E/ ) || "";
  my @tree      = split( /$sep/, $args{Pathname} );
  my $buildTree = "";
  my $filename  = "";
  $filename     = pop @tree if( ! $bare );
  return(1) if( ! @tree );
  $tree[0] .= $sep if( $root );
  foreach my $dir ( @tree ) {
    next if( ! $dir );
    $buildTree .= $dir . $sep;
    $buildTree  =~ s/\Q$sep\E+/$sep/g;
    unless( -e $buildTree ) {
      mkdir( $buildTree, $perms ) || return undef;
    }
  }
  return( "$buildTree$filename" );
}
sub copy {
  my $object = shift;
  my %args   = @_;
  $object->buildTree( Pathname => $args{To} ) if( $args{Build} );
  open( FROM, $args{From} ) || return undef;
  open( TO, ">$args{To}" )  || return undef;
  print( TO $_ ) while( <FROM> );
  close( TO );
  close( FROM );
  return(1);
}
