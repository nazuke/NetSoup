#!/usr/local/bin/perl -w
# This Apache module is an example success handler for NetSoup::Apache::Form::Validate.
# Replace this module with your own.

package NetSoup::Apache::Form::ValidateStub;
use Apache::Constants;
@NetSoup::Apache::Form::ValidateStub::ISA = qw();
1;


sub handler {
  my $r = shift;
  $r->content_type( "text/html" );
  $r->send_http_header();
  $r->print( "<p>Form Validated!</p>" );
  return( OK );
}
