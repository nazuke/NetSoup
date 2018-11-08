#!/usr/local/bin/perl
#
#   NetSoup::Packages::HyperGlot::cgi-bin::hGetPut.cgi v00.00.01z 12042000
#
#   Copyright (C) 2000  Jason Holland <jason.holland@dial.pipex.com>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#
#   Description: This Perl 5.0 CGI script fetches a web page from the remote server.
#                In addition, all scripts and events are disabled.
#
#
#   Methods:
#       fetch    -  This function fetches the required Html document and returns it to the web browser
#       extract  -  This function extracts all of the strings from an Html document
#       replace  -  This function performs the reverse of the extract() function


use NetSoup::CGI::Scripts;
use NetSoup::CGI;
use NetSoup::Html::Document::Form;
use NetSoup::Html::Document::Table::text2table;
use NetSoup::Html::Document;
use NetSoup::Parse::Html::JavaScript::Clobber;
use NetSoup::Parse::Html::RipStuff;
use NetSoup::Parse::Url;
use NetSoup::Protocol::HTTP_1;
use NetSoup::Text::CodePage::ascii2url;


my $cgi      = NetSoup::CGI->new();                                 # Create new CGI object
my $function = $cgi->field( Name   => "function",                   # Get URL of required document
							Format => "Ascii" );
my $url      = $cgi->field( Name   => "url",                        # Get URL of required document
							Format => "Ascii" );
my $clobber  = NetSoup::Parse::Html::JavaScript::Clobber->new();    # Get new JavaScript clobberer
SWITCH: for ( $function ) {                                         # Determine runtime function requirement
	m/fetch/   && do { fetch( $cgi, $url ) };                       # Fetch and display Html document
	m/extract/ && do { extract( $cgi, $url ) };                     # Extract Html document strings
	m/replace/ && do { replace( $cgi, $url ) };                     # Replace Html document strings
	m/^$/      && do { exit(1) };                                   # Error
}
exit(0);


sub fetch {
	# This function fetches the required Html document and returns it to the web browser.
	my $cgi    = shift;                                   # Get CGI object
	my $url    = shift;                                   # Get Html document URL
	my $data   = "";                                      # Intialise scalar to hold Html data
	my $http   = NetSoup::Protocol::HTTP_1->new();        # Get new http object
	my $status = $http->get( Url  => $url,                # Fetch document
							 Data => \$data );
	fixbase( $url, \$data );                              # Fix <base> to point at correct linked resources
	$clobber->clobber( \$data );                          # Disable all JavaScripts and event properties
	print( STDOUT "Content-type: text/html\r\n\r\n" );    # Output content-type header
	print( STDOUT $data );                                # Output processed Html document data
	return(1);
}


sub fixbase {
	# This function adjusts the <base> tag to point to the correct base url.
	my $url      = shift;                                    # Get base url
	my $ref      = shift;                                    # Get data reference
	my $parse    = NetSoup::Parse::Url->new();               # Get new url parser
	my $filename = $parse->filename( $url );                 # Parse filename
	$url         =~ s/$filename$//;                          # Chop off filename
	$$ref        =~ s/<head>/<head>\n<base href="$url">/;    # Insert new base url
	return(1);
}


sub extract {
	# This function extracts all of the strings from an Html document,
	# constructs a form, and returns it to the web browser.
	my $cgi    = shift;                                                                          # Get CGI object
	my $url    = shift;                                                                          # Get Html document URL
	my $data   = "";                                                                             # Intialise scalar to hold Html data
	my $noStrg = 0;                                                                              # Initialise number of extracted strings
	my %pairs  = ();                                                                             # Initialise hash to hold token/string pairs
	my $http   = NetSoup::Protocol::HTTP_1->new();                                               # Get new http object
	print( STDOUT "Content-type: text/html\r\n\r\n" );                                           # Output content-type header
	$http->get( Url  => $url,                                                   # Unvisit page
				Data => \$data );
	$clobber->clobber( \$data );                                # Disable all JavaScripts and event properties
	my $rip = NetSoup::Parse::Html::RipStuff->new();                                             # Get new ripper object
	$rip->rip( Data   => \$data,                                              # Extract strings
			   Mirror => \%pairs );
	my ( $token ) = ( $rip->seed() =~ m/^([^:]+)::\d+$/ );                                       # Get initial token value
	my $tag       = NetSoup::Html::Document->new();                                              # Get new html object to hold html tags
	my $table     = join( "!~!~!~!~",                                                            # Initialise scalar to hold raw table
						  $tag->h( Content => "Current Text",
								   Level   => 4 ),
						  $tag->h( Content => "New Text",
								   Level   => 4 ) ) . "\n";
	foreach ( sort( keys ( %pairs ) ) ) {                                                        # Build raw table
		my $control = NetSoup::Html::Document::Form->new();                                                # Get new form control
		my $rows    = int( length( $pairs{$_}->[1] ) / 38 );                                     # Calculate optimum number of lines
		$rows       = 4 if( $rows < 4 );                                                         # Set default number of lines
		my $field   = $control->textarea( Cols    => 38,                                         # Build text control
										  Content => \$pairs{$_}->[1],
										  Name    => "!!$_!!",
										  Rows    => $rows,
										  Wrap    => "virtual" );
		$table  .= $pairs{$_}->[1] . "!~!~!~!~$field\n";                                         # Add row to table
	}
	my $control   = NetSoup::Html::Document::Form->new();                                                  # Get new form control
	$table       .= $tag->hr() . "!~!~!~!~" . $tag->hr() . "\n";                                 # Insert row divider
	my $magic     = "";                                                                          # Initialise magic form container
	my $magicText = "";
	foreach ( sort keys %pairs ) {
		$magicText .= $pairs{$_}->[1] . "\t" . $pairs{$_}->[1] . "\n";                           # Fill magic text field
	}
	$control->debug( $magicText );                                                               # DEBUG
	$magic        .= $control->textarea( Name    => "magicText",                                 # Insert magic text area
										 Cols    => 40,
										 Rows    => 4,
										 Wrap    => "nowrap",
										 Content => \$magicText );
	$magic        .= "<br>" . $control->button( Name    => "magicButton",                        # Insert magic button into control
												Value   => "Restore",
												OnClick => "magicRestore()" );
	$table        .= $tag->h( Content => "Magic Box",
							  Level   => 4 ) . "!~!~!~!~$magic\n";         # Add magic box control to table
	my $text2table = NetSoup::Html::Document::Table::text2table->new();                                    # Get new text2table object
	$table         = $text2table->text2table( Content   => $table,      # Format table as html table
											  Separator => "!~!~!~!~" );
	my $html       = "";                                                                         # Initialise document container
	my $document   = NetSoup::Html::Document->new();                                             # Get new Html document object
	$document->css( Href => "http://dial.pipex.com/HyperGlot/htdocs/styles.css" );              # Import stylesheet
	$document->javascript( Src => "http://dial.pipex.com/HyperGlot/JavaScript/store.java" );    # Import storage JavaScript
	$document->h( Content => Editor,                                               # Insert heading
				  Level   => 2 );
	my $this = NetSoup::CGI::Scripts->new();                                                     # Get new scripts object
	my $form = NetSoup::Html::Document::Form->new( Name   => "magicForm",                                  # Get new form object
												   Method => "POST",
												   Action => $this->this() );
	my $completeForm = "";                                                                       # Initialise container for complete form
	$form->hidden( Name  => "function",                                     # Set hidden function field
				   Value => "replace" );
	$form->hidden( Name  => "url",                                        # Set hidden URL field
				   Value => "$url" );
	$form->hidden( Name  => "token",                                      # Set hidden initial token field
				   Value => "$token" );
	$form->insert( Content => \$table );                                                         # Insert table into form
	$form->display( Content => \$completeForm );
	$document->insertBody( Content => \$completeForm );                                          # Build complete form and insert it into document
	$document->display( Content => \$html );                                                     # Build completed document
	print( STDOUT $html );                                                                       # Output html
	return(1);
}


sub replace {
	# This function performs the reverse of the extract() function, it
	# takes new strings as input and inserts them into the Html document.
	my $cgi     = shift;                                                         # Get CGI object
	my $url     = shift;                                                         # Get Html document URL
	my $token   = $cgi->field( Name   => "token",             # Get initial token
							   Format => "Ascii" );
	my $encoder = NetSoup::Text::CodePage::ascii2url->new();                     # Get new url2ascii encoder object
	my %strings = ();                                                            # Initliase hash to hold strings
	my $bang    = "!!";
	my $colons  = "::";
	my $count   = 0;
	$encoder->ascii2url( Data => \$bang );
	$encoder->ascii2url( Data => \$colons );
	TOKENS: {                                                                    # Get tokenised form fields
		my $fieldName = $bang . $token . $colons . $count . $bang;               # Construct partially encoded field name
		my $field     = $cgi->field( Name   => $fieldName,
									 Format => "Ascii" );
		last TOKENS if( ! $field );
		my $name = $fieldName;
		$encoder->url2ascii( Data => \$name );                                   # Decode field name
		$strings{$name} = [ "", $field ];                                        # Store in token/string pair hash
		$count++;
		redo TOKENS;
	}
	my $http = NetSoup::Protocol::HTTP_1->new();                                 # Get new http object
	my $data = "";                                                               # Initialise document container
	$http->get( Url => $url, Data => \$data );                                   # Get document data
	my $rip = NetSoup::Parse::Html::RipStuff->new( Token => $token );            # Create new RipStuff object
	$rip->rip( Data   => \$data,                                   # Tokenise Html document
			   Mirror => {} );
	$rip->stuff( Data   => \$data,                          # Insert new strings into Html document
				 Mirror => \%strings );
	$http->put( Url  => $url,
				Data => \$data );                                   # Put document back on server
	print( STDOUT "Content-type: text/html\r\n\r\n" );                           # Output content-type header
	my $html     = NetSoup::Html::Document->new();                               # Get new Html document object
	my $document = "";
	$html->h( Content => "Document Saved",      # Insert main heading
			  Level   => 2,
			  Align   => "center" );
	$html->h( Content => $url,      # Insert url heading
			  Level   => 4,
			  Align   => "center" );
	$html->display( Content => \$document );
	print( STDOUT $document );
	return(1);
}
