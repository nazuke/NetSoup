#!/usr/local/bin/perl -w


my $string = shift;
print( makeScript( String => $string ) );
exit(0);


sub makeScript {
  my %args     = @_;
  my @chars    = split( m//, $args{String} );
  for( my $i = 0 ; $i < @chars ; $i++ ) {
    $chars[$i] = ord( $chars[$i] );
  }
  my $encoded = join( ",", @chars );
  my $script  = qq(<script language="JavaScript" type="text/javascript">\n<!--\ndocument.write( "<a href=\\"mailto:" + decodeString( [__EMAIL__] ) + "\\">" + decodeString( [__EMAIL__] ) + "</a>");\n//-->\n</script>\n);
  $script     =~ s/__EMAIL__/$encoded/gs;
  return( $script );
}
