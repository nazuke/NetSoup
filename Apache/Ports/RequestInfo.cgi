#!/usr/local/bin/perl -w -I/usr/local/apache/lib

use strict;
use NetSoup::CGI;
use NetSoup::Files::Load;
use NetSoup::Encoding::Hex;
use NetSoup::Protocol::Mail;
use NetSoup::XML::DOM2::Core::Document;
use NetSoup::XML::DOM2::Traversal::DocumentTraversal;
use NetSoup::XML::Parser;

my $CGI       = NetSoup::CGI->new();
my $Records   = "/usr/local/apache/records/Contact/";
my $Recipient = 'eileenm@autonomy.com';
my $From      = 'maildroid@autonomy.com';
my $Subject   = "Autonomy Contact Form Feedback";
my $Action    = "https://intranetuk.autonomy.co.uk/intranet/leads4/ModifyLead.asp";
my @SortOrder = split( /,[ \t]*/, $CGI->field( Name => "SORTORDER", Format => "ascii" ) );
my $HTDOC     = NetSoup::XML::DOM2::Core::Document->new( DocumentElement => "html" );
my $Load      = NetSoup::Files::Load->new();
SWITCH: for( $CGI->field( Name => "Country", Format => "ascii" ) ) {
	m/^(United States|Canada)$/i && do {
		$Recipient = 'stephaniep@us.autonomy.com';
		last SWITCH;
	};
	m/^.+$/i && do {
		$Recipient = 'eileenm@autonomy.com';
		#$Recipient = 'krisc@autonomy.com';
		last SWITCH;
	};
}
print( STDOUT "Content-type: text/html\r\n\r\n" );
if ( ! checkdomain( $Recipient ) ) {
	print( STDOUT "<h1>Invalid Domain</h1>" );
} else {
	form( $HTDOC, $Action, \@SortOrder, $Subject );
	my $HTML    = beautify( $HTDOC );
	my $success = NetSoup::Protocol::Mail->mail( To          => $Recipient,
																							 From        => $From,
																							 Subject     => $Subject,
																							 ContentType => "text/html",
																							 Message     => $HTML );
	if ( $success ) {
		my $output = "";
		if( -e "$ENV{DOCUMENT_ROOT}/autonomy_v3/Content/Forms/RequestInfo/success.html" ) {
			$Load->load( Pathname => "$ENV{DOCUMENT_ROOT}/autonomy_v3/Content/Forms/RequestInfo/success.html",
									 Data     => \$output );
			print( STDOUT $output );
		} else {
			print( STDERR "error\n" );
		}
		my $Hex      = NetSoup::Encoding::Hex->new();
		my $pathname = $Records . $Hex->bin2hex( Data => $CGI->field( Name => "EMail", Format => "ascii" ) ) . ".xml";
		if ( open( XML, ">$pathname" ) ) {
			print( XML $HTML );
			close( XML );
			my $lockfile  = $Records . "lockfile";
			my $countfile = $Records . "counter";
			my $timeout   = 60;
			my $flag      = 0;
		TIMEOUT: for( my $i = $timeout ; $i >= 0 ; $i-- ) {
				if ( -e $lockfile ) {
					sleep(1);
				} else {
					if ( open( LOCKFILE, ">$lockfile" ) ) {
						print( LOCKFILE "LOCKFILE" );
						close( LOCKFILE );
					} else {
						exit(0);
					}
					$flag = 1;
					last TIMEOUT;
				}
			}
			if ( $flag == 1 ) {
				my $counter = 0;
				if ( ( -e $countfile ) && ( open( COUNTER, $countfile ) ) ) {
					$counter = <COUNTER>;
					chomp $counter;
					close( COUNTER );
				}
				open( COUNTER, ">$countfile" );
				$counter++;
				print( COUNTER "$counter\n" );
				close( COUNTER );
				unlink( $lockfile );
			}
		} else {
			print( STDERR qq(Failed to open "$pathname"\n) );
		}
	} else {
		my $output = "";
		if( -e "$ENV{DOCUMENT_ROOT}/autonomy_v3/Content/Forms/RequestInfo/error.html" ) {
			$Load->load( Pathname => "$ENV{DOCUMENT_ROOT}/autonomy_v3/Content/Forms/RequestInfo/error.html",
									 Data     => \$output );
			print( STDOUT $output );
		} else {
			print( STDERR "error\n" );
		}
	}
}
exit(0);


sub checkdomain {
	my $Recipient = shift;
	if ( -e "mailhtml.domains" ) {
		my $check   = 0;
		my @domains = ();
		open( DOMAINS, "mailhtml.domains" ) || return(0);
		while ( <DOMAINS> ) {
			chomp;
			push( @domains, $_ );
		}
		close( DOMAINS );
		foreach my $domain ( @domains ) {
			$check++ if( $Recipient =~ m/\@$domain$/i );
		}
		return(0) if( ! $check );
	}
	return(1);
}

sub form {
	my $HTDOC     = shift;
	my $Action    = shift;
	my $SortOrder = shift;
	my @SortOrder = @{$SortOrder};
	my $Subject   = shift;
	my $HTML      = $HTDOC->createElement( TagName => "html" );
	my $Head      = $HTDOC->createElement( TagName => "head" );
	my $Style     = $HTDOC->createElement( TagName => "link" );
	my $Body      = $HTDOC->createElement( TagName => "body" );
	my $Form      = $HTDOC->createElement( TagName => "form" );
	my $Sig       = $HTDOC->createElement( TagName => "input" ); # SMS Signature for this application
	my $Table     = $HTDOC->createElement( TagName => "table" );
	$HTDOC->appendChild( NewChild => $HTML );
	$HTML->appendChild( NewChild => $Head );
	$Head->appendChild( NewChild => $Style );
	$HTML->appendChild( NewChild => $Body );
	$Body->appendChild( NewChild => $Form );
	$Form->appendChild( NewChild => $Sig );
	$Form->appendChild( NewChild => $Table );
	$Style->setAttribute( Name => "rel", Value => "Stylesheet" );
	$Style->setAttribute( Name => "type", Value => "text/css" );
	$Style->setAttribute( Name => "href", Value => "http://www.autonomy.com/autonomy_v3/Content/Forms/RequestInfo/Mail.css" );
	$Form->setAttribute( Name => "method", Value => "POST" );
	$Form->setAttribute( Name => "action", Value => $Action );
	$Sig->setAttribute( Name => "type", Value  => "hidden" );
	$Sig->setAttribute( Name => "name", Value  => "MeansOfContact" );
	$Sig->setAttribute( Name => "value", Value => "From Website" );
	$Table->setAttribute( Name => "border", Value => "0" );
	$Table->setAttribute( Name => "cellpadding", Value => "2" );
	$Table->setAttribute( Name => "cellspacing", Value => "0" );
	my $HeadTr = $HTDOC->createElement( TagName => "tr" );
	my $HeadTd = $HTDOC->createElement( TagName => "td" );
	$Table->appendChild( NewChild => $HeadTr );
	$HeadTr->appendChild( NewChild => $HeadTd );
	$HeadTd->appendChild( NewChild => $HTDOC->createTextNode( Data => $Subject ) );
	$HeadTd->setAttribute( Name => "class", Value => "head" );
	$HeadTd->setAttribute( Name => "colspan", Value => "2" );
	foreach my $field ( @SortOrder ) {
		my $fieldname = $field;
		my $value     = $CGI->field( Name => $field, Format => "ascii" ) || '&nbsp;';
		my $Tr        = $HTDOC->createElement( TagName => "tr" );
		my $ColOne    = $HTDOC->createElement( TagName => "td" );
		my $ColTwo    = $HTDOC->createElement( TagName => "td" );
		$fieldname    =~ s/\./ /g;
		$Table->appendChild( NewChild => $Tr );
		$Tr->appendChild( NewChild => $ColOne );
		$Tr->appendChild( NewChild => $ColTwo );
		$ColOne->appendChild( NewChild => $HTDOC->createTextNode( Data => $fieldname ) );
		$ColOne->setAttribute( Name => "class", Value => "dark" );
		$ColTwo->setAttribute( Name => "class", Value => "light" );
	COMPOUND: for( $value ) {
			$value =~ s/\\</</gs;
			$value =~ s/\\>/>/gs;
			$value =~ s/\\\|/|/gs;
			$value =~ s/\\\"/\"/gs;
			$value =~ s/\\\'/\'/gs;
			

			m/^<SELECT>/i && do {			# Popup menu
				$value =~ s/^<SELECT>//i;
				my $Select = $HTDOC->createElement( TagName => "select" );
				$Select->setAttribute( Name => "name", Value => $fieldname );
				foreach my $entry ( split( /\|/, $value ) ) {
					my $Option = $HTDOC->createElement( TagName => "option" );
					$Option->appendChild( NewChild => $HTDOC->createTextNode( Data => $entry ) );
					$Select->appendChild( NewChild => $Option );
				}
				$ColTwo->appendChild( NewChild => $Select );
				last COMPOUND;
			};


			m/^<CHECKBOX>/i && do {		# Checkbox
				$value =~ s/^<CHECKBOX>//i;
				my $Select = $HTDOC->createElement( TagName => "select" );
				$Select->setAttribute( Name => "name", Value => $fieldname );
				foreach my $entry ( sort( split( /\|/, $value ) ) ) {
					my $Option = $HTDOC->createElement( TagName => "option" );
					$Option->appendChild( NewChild => $HTDOC->createTextNode( Data => $entry ) );
					$Select->appendChild( NewChild => $Option );
				}
				$ColTwo->appendChild( NewChild => $Select );
				last COMPOUND;
			};


			m/^<RADIO>/i && do {			# Radio button group
				$value =~ s/^<RADIO>//i;
				foreach my $entry ( split( /\|/, $value ) ) {
					my $Radio = $HTDOC->createElement( TagName => "input" );
					$Radio->setAttribute( Name => "type", Value => "radio" );
					$Radio->setAttribute( Name => "name", Value => $fieldname );
					$Radio->setAttribute( Name => "value", Value => $entry );
					$ColTwo->appendChild( NewChild => $Radio );
					$ColTwo->appendChild( NewChild => $HTDOC->createTextNode( Data => $entry ) );
				}
				last COMPOUND;
			};


			m/^<HIDDEN>/i && do {			# Hidden field
				$value =~ s/^<HIDDEN>//i;
				my $Hidden = $HTDOC->createElement( TagName => "input" );
				$Hidden->setAttribute( Name => "type",  Value => "hidden" );
				$Hidden->setAttribute( Name => "name",  Value => $fieldname );
				$Hidden->setAttribute( Name => "value", Value => $value );
				$ColTwo->appendChild( NewChild => $Hidden );
				$ColTwo->appendChild( NewChild => $HTDOC->createTextNode( Data => $value ) );
				last COMPOUND;
			};


			m/.+/i && do {						# Plain text field
				my $Input = $HTDOC->createElement( TagName => "textarea" );
				$value    = "" if( $value eq "[void]" );
				if ( $field eq "Comments" ) {
					$value .= "\n\n";
					$value .= "Inquiry_Regarding = "     . ( $CGI->field( Name => "Inquiry_Regarding",     Format => "ascii" ) || "" ) . "\n";
					$value .= "Referral_Type = "         . ( $CGI->field( Name => "Referral_Type",         Format => "ascii" ) || "" ) . "\n";
					$value .= "Planning_Applications = " . ( $CGI->field( Name => "Planning_Applications", Format => "ascii" ) || "" ) . "\n";
					$value .= "Project_Start = "         . ( $CGI->field( Name => "Project_Start",         Format => "ascii" ) || "" ) . "\n";
				}
				$Input->setAttribute( Name => "name", Value => $fieldname );
				$Input->setAttribute( Name => "wrap", Value => "virtual" );
				$Input->setAttribute( Name => "cols", Value => 40 );
				$Input->setAttribute( Name => "rows", Value => 4 );
				$Input->appendChild( NewChild => $HTDOC->createTextNode( Data => $value ) );
				$ColTwo->appendChild( NewChild => $Input );
				last COMPOUND;
			};
		

		}
	}
	my $ButtonsTr = $HTDOC->createElement( TagName => "tr" );
	$Table->appendChild( NewChild => $ButtonsTr );
	my $ButtonsTd = $HTDOC->createElement( TagName => "td" );
	$ButtonsTd->setAttribute( Name => "class", Value => "head" );
	$ButtonsTd->setAttribute( Name => "colspan", Value => "2" );
	$ButtonsTr->appendChild( NewChild => $ButtonsTd );
	my $ResetBut = $HTDOC->createElement( TagName => "input" );
	$ResetBut->setAttribute( Name => "type", Value => "reset" );
	$ResetBut->setAttribute( Name => "value", Value => "Reset" );
	my $SubmitBut = $HTDOC->createElement( TagName => "input" );
	$SubmitBut->setAttribute( Name => "type", Value => "submit" );
	$SubmitBut->setAttribute( Name => "value", Value => "Submit" );
	$ButtonsTd->appendChild( NewChild => $ResetBut );
	$ButtonsTd->appendChild( NewChild => $SubmitBut );
	return(1);
}

sub beautify {
	my $HTDOC     = shift;
	my $Target    = "";
	my $Parser    = NetSoup::XML::Parser->new();
	my $DT        = NetSoup::XML::DOM2::Traversal::DocumentTraversal->new();
	my $Serialise = $DT->createSerialise( Root => $HTDOC, StrictSGML => 1 );
	$Serialise->serialise( Node => $HTDOC, Target => \$Target );
	$Target .= "\n<!--\n\n";
	foreach my $key ( sort keys %ENV ) {
		$Target .= qq($key "$ENV{$key}"\n);
	}
	$Target .= "\n-->\n";
	return( $Target );
}
