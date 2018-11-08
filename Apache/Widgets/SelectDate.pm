#!/usr/local/bin/perl -w -I/usr/local/apache_1.3.22/lib

package NetSoup::Apache::Widgets::SelectDate;
use strict;
use Apache;
use Apache::Constants;
use NetSoup::CGI;
use NetSoup::XML::Parser;
use NetSoup::XML::File;
use NetSoup::Oyster::Component::Calendar;
use constant PARSER => NetSoup::XML::Parser->new();
use constant FILE   => NetSoup::XML::File->new();
1;


sub handler {
  my $r             = shift;
  my $CGI           = NetSoup::CGI->new();
  my $time          = int( NetSoup::CGI->new()->field( Name => "time" ) ) || time;
  my $Calendar      = NetSoup::Oyster::Component::Calendar->new( Time => $time );
  my $Month         = $Calendar->month( Time => $time );
  my ( $mm, $yyyy ) = ( $Calendar->thisMonth( Time => $time ),
                        $Calendar->thisYear( Time => $time ) );
  my $Document      = $Month->DOM( Callback => { TD => sub {
                                                   my %args = @_;
                                                   my $Node = $args{Node};
                                                   $Node->setAttribute( Name => "style", Value => "width:30px;" . $Node->getAttribute( Name => "style" ) );
                                                   if( $Node->firstChild()->nodeValue() ) {
                                                     my $Button = $args{Document}->createElement( TagName => "input" );
                                                     $Button->setAttribute( Name => "type", Value => "button" );
                                                     $Button->setAttribute( Name => "style", Value => "width:26px;" );
                                                     $Button->setAttribute( Name => "value", Value => $Node->firstChild()->nodeValue() );
                                                     $Button->setAttribute( Name => "onClick", Value => "go( " . $Node->firstChild()->nodeValue() . ", $mm, $yyyy )" );
                                                     $Node->appendChild( NewChild => $Button );
                                                     $Node->removeChild( OldChild => $Node->firstChild() );
                                                   }
                                                   return(1);
                                                 } } );
  my $prevmonth = &{ sub{
                       if( $mm == 1 ) {
                         return( $time );
                       } else {
                         return( $Calendar->findStartOfMonth( Index => $mm - 1 ) );
                       }
                     } };
  my $nextmonth = &{ sub{
                       if( $mm == 12 ) {
                         return( $time );
                       } else {
                         return( $Calendar->findStartOfMonth( Index => $mm + 1 ) );
                       }
                     } };
  my $HTML = <<HTML;
  <html>
    <head>
      <title></title>
      <style type="text/css">
        <!--
        body {
          background-color: #444488;
          color:            #FFFFFF;
          font-family:      sans-serif;
          font-weight:      bold;
          font-size:        9pt;
        }
        -->
      </style>
    </head>
    <body id="body">
    </body>
  </html>
HTML
  my $Controls = <<CONTROLS;
  <hr />
  <table>
    <tbody>
      <tr>
        <td><input type="button" value="Prev Month" onClick="window.location='?time=$prevmonth'" /></td>
        <td><input type="button" value="Next Month" onClick="window.location='?time=$nextmonth'" /></td>
      </tr>
    </tbody>
  </table>
  <script language="JavaScript" type="text/javascript">
    <!--
    function go( dd, mm, yyyy ) {
      window.opener.NetSoupSelectDate( dd, mm, yyyy );
      window.close();
    }
    //-->
  </script>
CONTROLS
  my $HTML_Doc = PARSER->parse( XML => \$HTML );
  my $Table    = PARSER->parse( XML => \$Controls );
  $HTML_Doc->getElementById( ID => "body" )->appendChild( NewChild => $Document );
  $Document->firstChild()->appendChild( NewChild => $Table );
  $r->content_type( "text/html" );
  $r->send_http_header();
  $r->print( FILE->serialise( Document => $HTML_Doc ) );
  return( OK );
}
