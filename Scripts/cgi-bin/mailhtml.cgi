#!/usr/local/bin/perl -w


use NetSoup::CGI;
use NetSoup::Protocol::Mail;
use NetSoup::XML::DOM2::Core::Document;
use NetSoup::XML::DOM2::Traversal::DocumentTraversal;
use NetSoup::XML::Parser;


my $StyleCouncil = join( "", <DATA> );
my $CGI          = NetSoup::CGI->new();
my $Recipient    = $CGI->field( Name => "RECIPIENT", Format => "ascii" );
my $CC           = $CGI->field( Name => "CC",        Format => "ascii" );
my $From         = $CGI->field( Name => "FROM",      Format => "ascii" );
my $Subject      = $CGI->field( Name => "SUBJECT",   Format => "ascii" );
my $Action       = $CGI->field( Name => "ACTION",    Format => "ascii" );
my @SortOrder    = split( /,[ \t]*/, $CGI->field( Name => "SORTORDER", Format => "ascii" ) );
my $Document     = NetSoup::XML::DOM2::Core::Document->new( DocumentElement => "html" );
if( ! checkdomain() ) {
  print( "Content-type: text/html\r\n\r\n" );
  print( "<h1>Invalid Domain</h1>" );
  exit(0);
}
SWITCH: for( $CGI->field( Name => "DOCTYPE" ) ) {
  m/^plain$/i && do {
    plain( $Document );
    last SWITCH;
  };
  m/^form$/i && do {
    form( $Document );
    last SWITCH;
  };
  m// && do {
    print( "Content-type: text/html\r\n\r\n" );
    print( "<h1>Missing or Invalid DocType Field</h1>" );
    exit(0);
  };
}
$CC         = "" if( ! defined $CC );
my $HTML    = beautify( $Document );
$HTML      .= qq(\nHTTP_USER_AGENT: "$ENV{HTTP_USER_AGENT}"\n);
my $success = NetSoup::Protocol::Mail->mail( To          => $Recipient,
																						 CC          => $CC,
																						 From        => $From,
																						 Subject     => $Subject,
																						 ContentType => "text/html",
																						 Message     => $HTML );
if( $success ) {
  print( "Location: " . $CGI->field( Name   => "SUCCESSURL",
																		 Format => "ascii" ) . "\r\n\r\n" );
} else {
  print( "Location: " . $CGI->field( Name   => "ERRORURL",
																		 Format => "ascii" ) . "\r\n\r\n" );
}
exit(0);


sub checkdomain {
  if( -e "mailhtml.domains" ) {
    my $check   = 0;
    my @domains = ();
    open( DOMAINS, "mailhtml.domains" ) || return(0);
    while( <DOMAINS> ) {
      chomp;
      push( @domains, $_ );
    }
    close( DOMAINS );
    foreach my $domain ( @domains ) {
      $check++ if( $Recipient =~ m/\@$domain$/i );
    }
    return(0) if( ! $check );
    if( ! defined $CC ) {
      $check = 0;
      foreach my $domain ( @domains ) {
				$check++ if( $CC =~ m/\@$domain$/i );
      }
      return(0) if( ! $check );
    }
  }
  return(1);
}


sub plain {
  my $Document = shift;
  my $HTML     = $Document->createElement( TagName => "html" );
  my $Head     = $Document->createElement( TagName => "head" );
  my $Style    = $Document->createElement( TagName => "style" );
  my $Body     = $Document->createElement( TagName => "body" );
  my $Table    = $Document->createElement( TagName => "table" );
  $Document->appendChild( NewChild => $HTML );
  $HTML->appendChild( NewChild => $Head );
  $Head->appendChild( NewChild => $Style );
  $Style->appendChild( NewChild => $Document->createTextNode( Data => $StyleCouncil ) );
  $HTML->appendChild( NewChild => $Body );
  $Body->appendChild( NewChild => $Table );
  $Table->setAttribute( Name => "border", Value => "0" );
  my $HeadTr = $Document->createElement( TagName => "tr" );
  my $HeadTd = $Document->createElement( TagName => "td" );
  $Table->appendChild( NewChild => $HeadTr );
  $HeadTr->appendChild( NewChild => $HeadTd );
  $HeadTd->appendChild( NewChild => $Document->createTextNode( Data => $Subject ) );
  $HeadTd->setAttribute( Name => "class", Value => "head" );
  $HeadTd->setAttribute( Name => "colspan", Value => "2" );
  foreach my $field ( @SortOrder ) {
    my $value  = $CGI->field( Name => $field, Format => "ascii" );
    my $Tr     = $Document->createElement( TagName => "tr" );
    my $ColOne = $Document->createElement( TagName => "td" );
    my $ColTwo = $Document->createElement( TagName => "td" );
    $Table->appendChild( NewChild => $Tr );
    $Tr->appendChild( NewChild => $ColOne );
    $Tr->appendChild( NewChild => $ColTwo );
    $ColOne->appendChild( NewChild => $Document->createTextNode( Data => $field ) );
    $ColOne->setAttribute( Name => "class", Value => "dark" );
    $ColTwo->appendChild( NewChild => $Document->createTextNode( Data => $value ) );
    $ColTwo->setAttribute( Name => "class", Value => "light" );
  }
  return(1);
}


sub form {
  my $Document = shift;
  my $HTML     = $Document->createElement( TagName => "html" );
  my $Head     = $Document->createElement( TagName => "head" );
  my $Style    = $Document->createElement( TagName => "style" );
  my $Body     = $Document->createElement( TagName => "body" );
  my $Form     = $Document->createElement( TagName => "form" );
  my $Table    = $Document->createElement( TagName => "table" );
  $Document->appendChild( NewChild => $HTML );
  $HTML->appendChild( NewChild => $Head );
  $Head->appendChild( NewChild => $Style );
  $Style->appendChild( NewChild => $Document->createTextNode( Data => $StyleCouncil ) );
  $HTML->appendChild( NewChild => $Body );
  $Body->appendChild( NewChild => $Form );
  $Form->appendChild( NewChild => $Table );
  $Form->setAttribute( Name => "method", Value => "POST" );
  $Form->setAttribute( Name => "action", Value => $Action );
  $Table->setAttribute( Name => "border", Value => "0" );
  $Table->setAttribute( Name => "border", Value => "0" );
  my $HeadTr = $Document->createElement( TagName => "tr" );
  my $HeadTd = $Document->createElement( TagName => "td" );
  $Table->appendChild( NewChild => $HeadTr );
  $HeadTr->appendChild( NewChild => $HeadTd );
  $HeadTd->appendChild( NewChild => $Document->createTextNode( Data => $Subject ) );
  $HeadTd->setAttribute( Name => "class", Value => "head" );
  $HeadTd->setAttribute( Name => "colspan", Value => "2" );
  foreach my $field ( @SortOrder ) {
    my $value  = $CGI->field( Name => $field, Format => "ascii" );
    my $Tr     = $Document->createElement( TagName => "tr" );
    my $ColOne = $Document->createElement( TagName => "td" );
    my $ColTwo = $Document->createElement( TagName => "td" );
    $Table->appendChild( NewChild => $Tr );
    $Tr->appendChild( NewChild => $ColOne );
    $Tr->appendChild( NewChild => $ColTwo );
    $ColOne->appendChild( NewChild => $Document->createTextNode( Data => $field ) );
    $ColOne->setAttribute( Name => "class", Value => "dark" );
    $ColTwo->setAttribute( Name => "class", Value => "light" );
  COMPOUND: for( $value ) {			# Popup menu
      m/^<SELECT>/i && do {
				$value =~ s/^<SELECT>//i;
				my $Select = $Document->createElement( TagName => "select" );
				$Select->setAttribute( Name => "name", Value => $field );
				foreach my $entry ( split( /\|/, $value ) ) {
					my $Option = $Document->createElement( TagName => "option" );
					$Option->appendChild( NewChild => $Document->createTextNode( Data => $entry ) );
					$Select->appendChild( NewChild => $Option );
				}
				$ColTwo->appendChild( NewChild => $Select );
				last COMPOUND;
      };
      m/^<CHECKBOX>/i && do {		# Checkbox
				$value =~ s/^<CHECKBOX>//i;
				my $Select = $Document->createElement( TagName => "select" );
				$Select->setAttribute( Name => "name", Value => $field );
				foreach my $entry ( sort( split( /\|/, $value ) ) ) {
					my $Option = $Document->createElement( TagName => "option" );
					$Option->appendChild( NewChild => $Document->createTextNode( Data => $entry ) );
					$Select->appendChild( NewChild => $Option );
				}
				$ColTwo->appendChild( NewChild => $Select );
				last COMPOUND;
      };
      m/^<RADIO>/i && do {			# Radio button group
				$value =~ s/^<RADIO>//i;
				foreach my $entry ( split( /\|/, $value ) ) {
					my $Radio = $Document->createElement( TagName => "input" );
					$Radio->setAttribute( Name => "type", Value => "radio" );
					$Radio->setAttribute( Name => "name", Value => $field );
					$Radio->setAttribute( Name => "value", Value => $entry );
					$ColTwo->appendChild( NewChild => $Radio );
					$ColTwo->appendChild( NewChild => $Document->createTextNode( Data => $entry ) );
				}
				last COMPOUND;
      };
      m/.+/i && do {						# Plain text field
				my $Input = $Document->createElement( TagName => "input" );
				$value = "" if( ! defined $value );
				$size  = length( $value ) + 4;
				$size  = 10 if( $size < 10 );
				$Input->setAttribute( Name => "type", Value => "text" );
				$Input->setAttribute( Name => "name", Value => $field );
				$Input->setAttribute( Name => "size", Value => $size );
				$Input->setAttribute( Name => "value", Value => $value );
				$ColTwo->appendChild( NewChild => $Input );
				last COMPOUND;
      };
    }
  }
  my $ButtonsTr = $Document->createElement( TagName => "tr" );
  $Table->appendChild( NewChild => $ButtonsTr );
  my $ButtonsTd = $Document->createElement( TagName => "td" );
  $ButtonsTd->setAttribute( Name => "class", Value => "head" );
  $ButtonsTd->setAttribute( Name => "colspan", Value => "2" );
  $ButtonsTr->appendChild( NewChild => $ButtonsTd );
  my $ResetBut = $Document->createElement( TagName => "input" );
  $ResetBut->setAttribute( Name => "type", Value => "reset" );
  $ResetBut->setAttribute( Name => "value", Value => "Reset" );
  my $SubmitBut = $Document->createElement( TagName => "input" );
  $SubmitBut->setAttribute( Name => "type", Value => "submit" );
  $SubmitBut->setAttribute( Name => "value", Value => "Submit" );
  $ButtonsTd->appendChild( NewChild => $ResetBut );
  $ButtonsTd->appendChild( NewChild => $SubmitBut );
  return(1);
}


sub beautify {
  my $Document  = shift;
  my $Target    = "";
  my $HTML      = "";
  my $Parser    = NetSoup::XML::Parser->new();
  my $DT        = NetSoup::XML::DOM2::Traversal::DocumentTraversal->new();
  my $Serialise = $DT->createSerialise( Root       => $Document,
																				StrictSGML => 1 );
  $Serialise->serialise( Node => $Document, Target => \$Target );
  my $Doc = $Parser->parse( XML => \$Target );
  $Serialise->serialise( Node => $Doc, Target => \$HTML );
  return( $HTML );
}


__DATA__

body {
  background-color: white;
  font-family:      Helvetica, Arial;
  color:            darkblue;
}

td.head {
  background-color: darkblue;
  color:            white;
  text-indent:      4px;
  font-size:        12pt;
  font-weight:      bold;
}

td.dark {
  background-color: steelblue;
  color:            white;
  text-indent:      4px;
  font-size:        10pt;
  font-weight:      bold;
  padding-left:     4px;
  padding-right:    4px;
}

td.light {
  background-color: lightsteelblue;
  color:            darkblue;
  text-indent:      4px;
  font-size:        10pt;
  font-weight:      bold;
  padding-left:     4px;
  padding-right:    4px;
}
