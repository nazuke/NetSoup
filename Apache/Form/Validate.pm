#!/usr/local/bin/perl -w
# This Apache module validates a form against an XML specification file.
# It is intended that this module merely provides validation, a secondary
# module is required to actually perform an action once validation is proven.

package NetSoup::Apache::Form::Validate;
use Apache::Constants;
use NetSoup::Files::Load;
use NetSoup::XML::File;
use NetSoup::CGI;
use constant LOAD => NetSoup::Files::Load->new();
@NetSoup::Apache::Form::Validate::ISA = qw();
1;


sub handler {
  my $r          = shift;                                                             # Get the Request object
  my $XML_CONFIG = $r->document_root() . $r->dir_config( "XML_CONFIG" );              # Path to XML Config file
  if( -e $XML_CONFIG ) {                                                              # Check that the config file actually exists
    my $CGI        = NetSoup::CGI->new();                                             # Get a CGI object
    my $XML_Config = NetSoup::XML::File->new()->load( Pathname => $XML_CONFIG );      # Load the config file
    my $NodeList   = $XML_Config->getElementsByTagName( TagName => "field" );         # Get "field" elements
    my %Cache      = ();                                                              # Stores cache of form name/value pairs
  CACHE: for( my $i = 0 ; $i < $NodeList->nodeListLength() ; $i++ ) {                 # Load cache of name/value pairs from form
      my $name      = $NodeList->item( Item => $i )->getAttribute( Name => "name" );
      $Cache{$name} = $CGI->field( Name => $name, Format => "html" ) || "";
    }
  CHECK: for( my $i = 0 ; $i < $NodeList->nodeListLength() ; $i++ ) {                 # Check each form input control against field element rules
      my $name  = $NodeList->item( Item => $i )->getAttribute( Name => "name" );
      my $type  = $NodeList->item( Item => $i )->getAttribute( Name => "type" );
      my $value = $CGI->field( Name => $name, Format => "ascii" );
    SWITCH: for( $type ) {



        
        m/^string$/ && do {
          # The Field is validated if it is mandatory
          if( $NodeList->item( Item => $i )->getAttribute( Name => "mandatory" ) ) {
            # The field contains no value
            if( ( ! defined $value ) || ( $value eq "" ) ) {
              report_error( R       => $r,
                            Cache   => \%Cache,
                            Message => $NodeList->item( Item => $i )->getElementsByTagName( TagName => "general" )->item( Item => 0 )->firstChild()->data() );
              return( DONE );
            }
          }
          if( defined $value ) {
            # The field is too short
            if( length( $value ) < $NodeList->item( Item => $i )->getAttribute( Name => "minlength" ) ) {
              report_error( R       => $r,
                            Cache   => \%Cache,
                            Message => $NodeList->item( Item => $i )->getElementsByTagName( TagName => "short" )->item( Item => 0 )->firstChild()->data() );
              return( DONE );
            }
            # The field is too long
            if( length( $value ) > $NodeList->item( Item => $i )->getAttribute( Name => "maxlength" ) ) {
              report_error( R       => $r,
                            Cache   => \%Cache,
                            Message => $NodeList->item( Item => $i )->getElementsByTagName( TagName => "long" )->item( Item => 0 )->firstChild()->data() );
              return( DONE );
            }
          }
          last SWITCH;
        };




        m/^text$/ && do {
          #$r->server()->warn( qq(<p>$i STRING $name</p>) );
          last SWITCH;
        };




        m/^int$/ && do {
          # The Field is validated if it is mandatory
          my $min = $NodeList->item( Item => $i )->getAttribute( Name => "min" ) || 0;
          my $max = $NodeList->item( Item => $i )->getAttribute( Name => "max" ) || 0;
          if( $NodeList->item( Item => $i )->getAttribute( Name => "mandatory" ) ) {
            # The field contains no value
            if( ( ! defined $value ) || ( $value eq 0 ) ) {
              report_error( R       => $r,
                            Cache   => \%Cache,
                            Message => $NodeList->item( Item => $i )->getElementsByTagName( TagName => "general" )->item( Item => 0 )->firstChild()->data() );
              return( DONE );
            }
          }
          if( defined $value ) {
            # The field value is invalid
            if( $value =~ m/[^0-9]/ ) {
              report_error( R       => $r,
                            Cache   => \%Cache,
                            Message => $NodeList->item( Item => $i )->getElementsByTagName( TagName => "invalid" )->item( Item => 0 )->firstChild()->data() );
              return( DONE );
            }
            # The field value is too small
            if( $value < $min ) {
              report_error( R       => $r,
                            Cache   => \%Cache,
                            Message => $NodeList->item( Item => $i )->getElementsByTagName( TagName => "min" )->item( Item => 0 )->firstChild()->data() );
              return( DONE );
            }
            # The field value is too big
            if( $value > $max ) {
              report_error( R       => $r,
                            Cache   => \%Cache,
                            Message => $NodeList->item( Item => $i )->getElementsByTagName( TagName => "max" )->item( Item => 0 )->firstChild()->data() );
              return( DONE );
            }
          }
          last SWITCH;
        };




        m/^float$/ && do {
          my $min = $NodeList->item( Item => $i )->getAttribute( Name => "min" ) || 0;
          my $max = $NodeList->item( Item => $i )->getAttribute( Name => "max" ) || 0;
          if( $NodeList->item( Item => $i )->getAttribute( Name => "mandatory" ) ) {
            # The field contains no value
            if( ( ! defined $value ) || ( $value eq 0 ) ) {
              report_error( R       => $r,
                            Cache   => \%Cache,
                            Message => $NodeList->item( Item => $i )->getElementsByTagName( TagName => "general" )->item( Item => 0 )->firstChild()->data() );
              return( DONE );
            }
          }
          if( defined $value ) {
            # The field value is invalid
            if( $value !~ m/^([0-9]+\.[0-9]+)|([0-9]+)$/ ) {
              report_error( R       => $r,
                            Cache   => \%Cache,
                            Message => $NodeList->item( Item => $i )->getElementsByTagName( TagName => "invalid" )->item( Item => 0 )->firstChild()->data() );
              return( DONE );
            }
            # The field value is too small
            if( $value < $min ) {
              report_error( R       => $r,
                            Cache   => \%Cache,
                            Message => $NodeList->item( Item => $i )->getElementsByTagName( TagName => "min" )->item( Item => 0 )->firstChild()->data() );
              return( DONE );
            }
            # The field value is too big
            if( $value > $max ) {
              report_error( R       => $r,
                            Cache   => \%Cache,
                            Message => $NodeList->item( Item => $i )->getElementsByTagName( TagName => "max" )->item( Item => 0 )->firstChild()->data() );
              return( DONE );
            }
          }
          last SWITCH;
        };




        m/^list$/ && do {
          #$r->server()->warn( qq(<p>$i LIST $name</p>) );
          last SWITCH;
        };




        m/^multiple$/ && do {
          #$r->server()->warn( qq(<p>$i MULTIPLE $name</p>) );
          last SWITCH;
        };




        m/^email$/ && do {
          #$r->server()->warn( qq(<p>$i MULTIPLE $name</p>) );
          # The Field is validated if it is mandatory
          if( $NodeList->item( Item => $i )->getAttribute( Name => "mandatory" ) ) {
            # The field contains no value
            if( ( ! defined $value ) || ( $value eq "" ) ) {
              report_error( R       => $r,
                            Cache   => \%Cache,
                            Message => $NodeList->item( Item => $i )->getElementsByTagName( TagName => "general" )->item( Item => 0 )->firstChild()->data() );
              return( DONE );
            }
          }
          if( defined $value ) {
            # The field is invalid
            if( $value !~ m/^[^\@]+\@[^\@]+\.[^\@]+$/i ) { # Allow single or multiple domains after @ symbol
              report_error( R       => $r,
                            Cache   => \%Cache,
                            Message => $NodeList->item( Item => $i )->getElementsByTagName( TagName => "invalid" )->item( Item => 0 )->firstChild()->data() );
              return( DONE );
            }
          }
          last SWITCH;
        };



        
        m/./ && do {
          $r->server()->warn( qq(DEFAULT $name) );
          last SWITCH;
        };




      }
    }
  } else {
    # This needs to redirect to a descriptive error page
    $r->server()->log_error( qq(Error: "$XML_CONFIG" not found) );
  }
  return( OK );
}


sub report_error {
  my %args     = @_;
  my $r        = $args{R};
  my %Cache    = %{$args{Cache}};
  my $Form_Doc = NetSoup::XML::File->new()->load( Pathname => $r->document_root() . $r->dir_config( "HTML_FORM" ) );
  my $NodeList = $Form_Doc->getElementsByTagName( TagName => "input" );
 UNCACHE: for( my $i = 0 ; $i < $NodeList->nodeListLength() ; $i++ ) {
    my $name = $NodeList->item( Item => $i )->getAttribute( Name => "name" );
    if( exists $Cache{$name} ) {
      $NodeList->item( Item => $i )->setAttribute( Name  => "value",
                                                   Value => $Cache{$name} );
    }
  }
  my $XML = NetSoup::XML::File->new()->serialise( Document => $Form_Doc );
  $XML    =~ s/<!--MESSAGE-->/$args{Message}/gs;
  $r->content_type( "text/html" );
  $r->send_http_header();
  $r->print( $XML );
  return(1);
}
