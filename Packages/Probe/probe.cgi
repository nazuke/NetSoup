#!/usr/local/bin/perl
#
#   NetSoup::Packages::Probe::probe.cgi v00.00.01z 12042000
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
#   Description: This Perl 5.0 class provides object methods for.


use NetSoup::CGI;
use NetSoup::Packages::Grab::Core;


$|           = 1;
my $cgi      = NetSoup::CGI->new();
my $function = $cgi->field( Name => "function" );
print( STDOUT "Content-type: text/html\r\n\r\n" );
SWITCH: for( $function ) {
	m/(^$|form)/ && do {
		form( "--form--" );
		last SWITCH;
	};
	m/help/ && do {
		form( "--help--" );
		last SWITCH;
	};
	m/process/ && do {
		process( $cgi );
		last SWITCH;
	};
}
exit(0);


sub form {
	# This function displays an Html document.
	my $type = shift;                                                  # Get form type to display
	while( <DATA> ) { last if( m/$type/ ) }                            # Read until token reached
	while( <DATA> ) {                                                  # Output Html document
		last if( m/^\.$/ );                                            # Stop on period
		s-!!ADDRESS!!-http://$ENV{SERVER_NAME}$ENV{SCRIPT_NAME}-gi;    # Insert this hostname and script pathname
		print( STDOUT );
	}
	return(1);
}


sub process {
	# This function executes the download process.
	my $cgi      = shift;                                              # Get CGI object
	my $url      = $cgi->field( Name => "url", Format => "ascii" );    # Or default to public tmp directory
	my $pathname = $cgi->field( Name   => "storage",                   # Determine storage pathname
								Format => "ascii" ) || '/usr/tmp';     # Or default to public tmp directory
	$cgi->debug( "GRAB\t$url" );                                       # DEBUG
	$cgi->debug( "GRAB\t$pathname" );                                  # DEBUG
	my $grab = NetSoup::Packages::Grab::Core->new();                   # Get new Core object
	if( $grab->grab( Url => $url, Pathname => $pathname ) ) {          # Download files
		$cgi->debug( "GRAB\tSuccess" );                                # DEBUG
	} else {
		$cgi->debug( "GRAB\tFail" );                                   # DEBUG
	}
	return(1);
}


# The forms are generated from the following data, each line is
# read until a line containing a single period is encountered.


__DATA__


--form--


<html>
	<head>
		<title>W3Probe</title>
		<style type="text/css">
			body {
				background: orange;
			}
			h1, h2, h3, h4, h5, h6, h7 {
				font-family: Helvetica, Lucida, Arial, sans-serif;
				color:       white;
			}
			p {
				font-family: Helvetica, Lucida, Arial, sans-serif;
				font-size:   10pt;
				font-style:  bold;
				color:       white;
			}
			tr.dark {
				background: darkorange;
			}
			span.white {
				font-family: Helvetica, Lucida, Arial, sans-serif;
				font-style:  bold;
				color:       white;
			}
		</style>
	</head>
	<body>
		<center>
			<table border="0" width="99%" cellpadding="0" cellspacing="0">
				<tr class="dark">
					<td width="2%">&nbsp;</td>
					<td width="48%" align="left" valign="center">
						<h1>W3Probe</h1>
					</td>
					<td width="50%" align="right" valign="center">
						<form method="POST" action="!!ADDRESS!!">
							<input type="hidden" name="function" value="help">
							<input type="submit" value="W3Probe Help">
						</form>
					</td>
				</tr>
			</table>
			<form method="POST" action="!!ADDRESS!!">
				<!-- START HIDDEN FIELDS -->
				<input type="hidden" name="function" value="process">
				<input type="hidden" name="sort" value="countWords,identifyLanguages,countJpeg,countGif,analyseGif,identifyLinkedMedia,identifyScripts,identifyApplets,identifyPlugins,identifyCgiLinks,findEmail">
				<!-- END HIDDEN FIELDS -->
				<table border="0" cellpadding="4" cellspacing="0">
					<!-- Address -->
					<tr class="dark" valign="top">
						<td colspan="2">
								<h4>Location</h4>
						</td>
					</tr>
					<tr valign="top">
						<td align="right" valign="center">
								<p>HTTP Address</p>
						</td>
						<td align="left" valign="center">
							<input type="text" name="address" size="46" maxlength="512">
						</td>
					</tr>
					<!-- Authorisation -->
					<tr class="dark" valign="top">
						<td colspan="2">
							<h4>Authorisation</h4>
						</td>
					</tr>
					<tr valign="top">
						<td colspan="2" align="center" valign="center">
							<p>
								Username
								<input type="text" name="username" size="12" maxlength="128">
								&nbsp;
								Password
								<input type="text" name="password" size="12" maxlength="128">
							</p>
						</td>
					</tr>
					<!-- START SERVER OPTIONS -->
					<tr class="dark" valign="top">
						<td colspan="2">
								<h4>Server Options</h4>
						</td>
					</tr>
					<tr valign="top">
						<td colspan="2">
							<table border="0" width="100%" cellpadding="0" cellspacing="0">
								<tr>
									<!-- Stay On Same Server -->
									<td width="20%" align="right">
										<input type="checkbox" name="sameServer" checked>
									</td>
									<td width="30%" align="left">
											<p>Stay On Same Server</p>
									</td>
									<!-- Follow CGI Links -->
									<td width="20%" align="right">
										<input type="checkbox" name="followCgi">
									</td>
									<td width="30%" align="left">
											<p>Follow CGI Links</p>
									</td>
								</tr>
							</table>
						</td>
					</tr>
					<!-- END SERVER OPTIONS -->
					<!-- START RECURSION OPTIONS -->
					<tr class="dark" valign="top">
						<td colspan="2">
								<h4>Link Options</h4>
						</td>
					</tr>
					<tr valign="top">
						<td colspan="2">
							<table border="0" width="100%" cellpadding="0" cellspacing="0">
								<tr>
									<!-- Recursion -->
									<td width="20%" align="right">
										<input type="checkbox" name="recursion" checked>
									</td>
									<td width="30%" align="left">
											<p>Follow Links</p>
									</td>
									<!-- Recursion Depth -->
									<td width="20%" align="right">
										<input type="text" name="recursionDepth" size="8" maxlength="4">
									</td>
									<td width="30%" align="left">
											<p>Link Depth</p>
									</td>
								</tr>
							</table>
						</td>
					</tr>
					<!-- END RECURSION OPTIONS -->
					<!-- START ANALYSIS OPTIONS -->
					<tr class="dark" valign="top">
						<td colspan="2">
								<h4>Analysis Options</h4>
						</td>
					</tr>
					<tr valign="top">
						<td colspan="2">
							<table border="0" width="100%" cellpadding="0" cellspacing="0">
								<tr>
									<!-- Count Words -->
									<td width="20%" align="right">
										<input type="checkbox" name="countWords" checked>
									</td>
									<td width="30%" align="left">
											<p>Count Words</p>
									</td>
									<!-- Identify Languages -->
									<td width="20%" align="right">
										<input type="checkbox" name="identifyLanguages" checked>
									</td>
									<td width="30%" align="left">
											<p>Identify Languages</p>
									</td>
								</tr>
								<tr>
									<!-- Count JPEG Images -->
									<td width="20%" align="right">
										<input type="checkbox" name="countJpeg" checked>
									</td>
									<td width="30%" align="left">
											<p>Count JPEG Images</p>
									</td>
									<!-- Count GIF Images -->
									<td width="20%" align="right">
										<input type="checkbox" name="countGif" checked>
									</td>
									<td width="30%" align="left">
											<p>Count GIF Images</p>
									</td>
								</tr>
								<tr>
									<!-- Identify Linked Media -->
									<td width="20%" align="right">
										<input type="checkbox" name="identifyLinkedMedia" checked>
									</td>
									<td width="30%" align="left">
											<p>Identify Linked Media</p>
									</td>
									<!-- Count GIF Images -->
									<td width="20%" align="right">
										<input type="checkbox" name="identifyScripts" checked>
									</td>
									<td width="30%" align="left">
											<p>Identify Scripts</p>
									</td>
								</tr>
								<tr>
									<!-- Identify Scripts -->
									<td width="20%" align="right">
										<input type="checkbox" name="identifyScripts" checked>
									</td>
									<td width="30%" align="left">
											<p>Identify Scripts</p>
									</td>
									<!-- Identify Applets -->
									<td width="20%" align="right">
										<input type="checkbox" name="identifyApplets" checked>
									</td>
									<td width="30%" align="left">
											<p>Identify Applets</p>
									</td>
								</tr>
								<tr>
									<!-- Identify Plug-Ins -->
									<td width="20%" align="right">
										<input type="checkbox" name="identifyPlugins" checked>
									</td>
									<td width="30%" align="left">
											<p>Identify Plug-Ins</p>
									</td>
									<!-- Identify CGI Links -->
									<td width="20%" align="right">
										<input type="checkbox" name="identifyCgiLinks" checked>
									</td>
									<td width="30%" align="left">
											<p>Identify CGI Links</p>
									</td>
								</tr>
								<tr>
									<!-- Find E-Mail Addresses -->
									<td width="20%" align="right">
										<input type="checkbox" name="findEmail" checked>
									</td>
									<td width="30%" align="left">
											<p>Find E-Mail Addresses</p>
									</td>
									<!-- NULL -->
									<td width="20%" align="right">
										&nbsp;
									</td>
									<td width="30%" align="left">
										&nbsp;
									</td>
								</tr>
							</table>
						</td>
					</tr>
					<tr class="dark" valign="top">
						<td colspan="2">
								<h4>Special Language Options</h4>
						</td>
					</tr>
					<tr valign="top">
						<td colspan="2">
							<table border="0" width="100%" cellpadding="0" cellspacing="0">
								<tr>
									<!-- Include Languages -->
									<td rowspan="2" align="right">
										<select name="languageList" multiple>
											<option selected>Brazilian Portugeuse
												<option selected>Danish</option>
												<option selected>Dutch</option>
												<option selected>English</option>
												<option selected>Finnish</option>
												<option selected>French</option>
												<option selected>German</option>
												<option selected>Italian</option>
												<option selected>Norwegian</option>
												<option selected>Spanish</option>
												<option selected>Swedish</option>
										</select>
									</td>
									<td align="right" valign="bottom">
										&nbsp;
									</td>
									<td align="left" valign="top">
											<p>Include Languages</p>
									</td>
								</tr>
								<tr>
									<!-- Include Indeterminate Languages -->
									<td align="right" valign="center">
										<input type="checkbox" name="includeIndeterminate" checked>
									</td>
									<td align="left" valign="center">
											<p>Include Indeterminate Languages</p>
									</td>
								</tr>
							</table>
						</td>
					</tr>
					<!-- END ANALYSIS OPTIONS -->
					<!-- BEGIN REPORT OPTIONS -->
					<tr class="dark" valign="top">
						<td colspan="2">
								<h4>Report Options</h4>
						</td>
					</tr>
					<tr valign="top">
						<td colspan="2">
							<table border="0" width="100%" cellpadding="0" cellspacing="0">
								<tr>
									<!-- Text Report -->
									<td width="20%" align="right">
										<input type="checkbox" name="textReport" checked>
									</td>
									<td width="30%" align="left">
											<p>Text Report</p>
									</td>
									<!-- Html Report -->
									<td width="20%" align="right">
										<input type="checkbox" name="htmlReport" checked>
									</td>
									<td width="30%" align="left">
											<p>Html Report</p>
									</td>
								</tr>
								<tr>
							</table>
						</td>
					</tr>
					<!-- END REPORT OPTIONS -->
					<!-- BEGIN MAILING OPTIONS -->
					<tr class="dark" valign="top">
						<td colspan="2">
								<h4>Mailing Options</h4>
						</td>
					</tr>
					<tr valign="top">
						<td colspan="2">
							<table border="0" width="100%" cellpadding="0" cellspacing="4">
								<tr>
									<!-- E-Mail Report File -->
									<td align="right">
										<input type="checkbox" name="emailReport" checked>
									</td>
									<td align="left" valign="center">
											<p>E-Mail Report File</p>
									</td>
								</tr>
								<tr>
									<!-- E-Mail Address Field -->
									<td align="right">
										<input type="text" name="emailAddress" value="" size="40" maxlength="128">
									</td>
									<td align="left" valign="center">
											<p>E-Mail Address</p>
									</td>
								</tr>
							</table>
						</td>
					</tr>
					<!-- END MAILING OPTIONS -->
					<!-- BEGIN OTHER OPTIONS -->
					<tr class="dark" valign="top">
						<td colspan="2">
								<h4>Other Options</h4>
						</td>
					</tr>
					<tr valign="top">
						<td colspan="2">
							<table border="0" width="100%" cellpadding="0" cellspacing="0">
								<tr>
									<!-- Use Disk Storage -->
									<td width="20%" align="right">
										<input type="checkbox" name="useDisk">
									</td>
									<td width="30%" align="left">
											<p>Use Disk Storage</p>
									</td>
									<!-- NULL -->
									<td width="20%" align="right">
										&nbsp;
									</td>
									<td width="30%" align="left">
										&nbsp;
									</td>
								</tr>
							</table>
						</td>
					</tr>
					<!-- END OTHER OPTIONS -->
					<tr class="dark">
						<!-- Submit/Reset Buttons -->
						<td>&nbsp;</td>
						<td align="right" valign="center">
							<input type="reset" value="Reset&nbsp;Form">
							<input type="submit" name="submit" value="Begin&nbsp;Analysis">
						</td>
					</tr>
				</table>
				<br>
			</form>
			<table border="0" width="99%" cellpadding="4" cellspacing="0">
				<tr>
					<td align="right" valign="top">
						<span class="white">W3Grab is Copyright (C) 2000 <a href="mailto:jason.holland@dial.pipex.com" subject="W3Grab">Jason&nbsp;Holland</a>.</span><br>
						<span class="white">W3Grab is distributed under the terms of the GNU General Public Licence.</span><br>
					</td>
				</tr>
			</table>
		</center>
	</body>
</html>
.


--help--


<html>
	<head>
		<title>W3Probe</title>
		<style type="text/css">
			body {
				background: orange;
			}
			h1, h2, h3, h4, h5, h6, h7 {
				font-family: Helvetica, Lucida, Arial, sans-serif;
				color:       white;
			}
			p {
				font-family: Helvetica, Lucida, Arial, sans-serif;
				font-size:   12pt;
				font-style:  bold;
				line-height: 16pt;
				color:       white;
			}
			tr.dark {
				background: darkorange;
			}
			span.white {
				font-family: Helvetica, Lucida, Arial, sans-serif;
				font-style:  bold;
				color:       white;
			}
		</style>
	</head>
	<body>
		<center>
				<table border="0" width="99%" cellpadding="0" cellspacing="0">
					<tr class="dark">
						<td width="2%">&nbsp;</td>
						<td width="48%" align="left" valign="center">
							<h1>W3Probe</h1>
						</td>
						<td width="50%" align="right" valign="center">
							<form method="POST" action="!!ADDRESS!!">
								<input type="submit" value="W3Probe Form">
							</form>
						</td>
					</tr>
				</table>
		</center>
		<!-- Default Settings Notes -->
		<h4>Default Settings</h4>
		<p>The default form settings should be sufficient for most web site analyses, in most cases you will simply have to enter the correct address and submit the form. The e-mail address entered last time will always be restored the next time the form is requested.</p>
		<p>Please note that analyses have a much better chance of completing properly if the report can be sent to an e-mail account. Some browsers have difficulty waiting a long time to receive a document, often timing out after several minutes. Getting the report via e-mail will almost always work properly. However, analysing a very small web site will be quicker if the report is returned directly to the browser window.</p>
		<!-- Location -->
		<hr width="98%">
		<h4>Location</h4>
		<h4>HTTP Address</h4>
		<p>Enter a web site address in the <strong>HTTP Address</strong> field, it should be entered as a regular URL in the form of <em>http://hostname/pathname.</em> Currently you <strong>must</strong> include the name of at least the root document in the pathname, alternatively you may include a full pathname to a specific directory and file.</p>
		<p>If you are unsure of the filename of the root document, first go to the web site in question and find out. It will often be named something like <em>index.html</em> or <em>index.htm</em>. However there may be a large differentiation in naming schemes, especially on non-UNIX based hosts.</p>
		<!-- Server Options -->
		<hr width="98%">
		<h4>Server Options</h4>
		<p>These options determine the application's behaviour when communicating with the remote server.</p>
		<h4>Stay On Same Server</h4>
		<p>It is recommended that this option be left switched on, otherwise the application may very well attempt to analyse the entire Internet. This option should only be switched off if you are sure that the web site does not link to other web servers.</p>
		<h4>Follow CGI Links</h4>
		<p>Some pages are generated automatically by server-side CGI scripts. This option should be enabled if dynamic pages are to be included in the analysis. Incidentally, disabling this option will not affect the result of <strong>Identify CGI/Database Links</strong> below.</p>
		<!-- Link Options -->
		<hr width="98%">
		<h4>Link Options</h4>
		<p>These options determine how the application follows links.</p>
		<h4>Follow Links</h4>
		<p>Enabling this option will cause the application to follow links on all pages. All links to Html pages will be followed, links to other file formats will generally be ignored.</p>
		<h4>To A Depth Of</h4>
		<p>A numeric value should be entered into this field. This value determines the number of consecutive links that are followed in a direct path from the parent page, it <strong>does not</strong> dictate the total number of pages that should be analysed. You may leave this field blank, in which case the application will use a default of infinity.</p>
		<!-- Analysis Options -->
		<hr width="98%">
		<h4>Analysis Options</h4>
		<p>These options form the core of the application, they determine the exact analysis performed on the web site in question.</p>
		<h4>Count Words</h4>
		<p>Enabling this option will cause a word count to be carried out on each page. The word count includes only translatable text, it does not currently include text resources inside tags, nor does it include text in linked media such as graphics or word processor files.</p>
		<h4>Identify Languages</h4>
		<p>With this option enabled, the application will perform a best-guess analysis of each page's text in an attempt to determine which language it has been written in.</p>
		<h4>Include Languages</h4>
		<p>Choose the languages to be included in the final report, you may select multiple languages to be included. It should be noted that this does not accelerate the analysis process as each page still needs to be downloaded before it can be analysed, it simply	filters out unwanted languages from the report.</p>
		<p>Checking the Include Indeterminate Languages checkbox will cause documents whose language could not be determined to be included in the report.</p>
		<h4>Count JPEG Images</h4>
		<p>Enabling this option will cause the application to count the number of JPEG images used on each page. Please note that several pages may actually use the same image. It is not currently possible to test for image duplication, however this may be implemented in the future.</p>
		<h4>Count GIF Images</h4>
		<p>Enabling this option will cause the application to count the number of GIF images used on each page. Please note that several pages may actually use the same image. It is not currently possible to test for image duplication, however this may be implemented in the future.</p>
		<h4>Identify Linked Media</h4>
		<p>Enabling this option will cause the application to attempt to determine the number of linked media files in each document that are not either regular Html files, GIF or JPEG images, or CGI links. Examples of linked media include any files such as Microsoft Word documents, sound files or unknown graphics formats.</p>
		<p>Of course, it is beyond the scope of this application to attempt to analyse unknown media types. They will need to be analysed through other means once they have been identified.</p>
		<h4>Identify Scripts</h4>
		<p>With this option enabled the application will attempt to locate any scripting languages used in each Html document. Currently the only two languages expected to be found are either JavaScript or VBScript and possibly Tcl/Tk. Additional scripting languages may appear in the future.</p>
		<h4>Identify Applets</h4>
		<p>Enabling this option will cause the application to count the number of Applets used by the page. Applets are mainly written in the Java programming language, however there may be rare cases where some other programming language has been used so this should not automatically be assumed.</p>
		<h4>Identify Plug-Ins</h4>
		<p>Enabling this option will cause the application to count the number of Plug-In tags used by the page. Plug-Ins can include a large number of media types, several hundred, so it is not practical at the moment to attempt to analyse them all.</p>
		<h4>Identify CGI/Database Links</h4>
		<p>With this option enabled the application will count the number of CGI and Database Query links made by the page. Counting these links will give an indication of the dependency of the web site on CGI scripts and external database applications.</p>
		<h4>Find E-Mail Addresses</h4>
		<p>Enabling this option causes the application to attempt to search for and extract any e-mail addresses in each document.</p>
		<!-- Report Options -->
		<hr width="98%">
		<h4>Report Options</h4>
		<p>There are now two report formats to choose from, you must pick at least one or you will receive nothing at all. More than one report can be returned via e-mail, they will arrive as multiple attachments.</p>
		<h4>Text Report</h4>
		<p>This report format is a tab delimited text block, suitable for loading into a word processor or spreadsheet.</p>
		<h4>Html Report</h4>
		<p>This report format is a regular Html file, suitable for human reading. The header contains a summary of all data gathered, along with a block for each document found.</p>
		<!-- Mailing Options -->
		<hr width="98%">
		<h4>Mailing Options</h4>
		<p>The mailing options determine if the report is to be e-mailed to a recipient or not. When the application looks for an e-mail address entered by the user it first looks in the text field and uses that, if the text field is empty it will then examine the menu and use the address selected there. If both text field and menu are empty then the application will send the report to the user's browser instead.</p>
		<p>The server will attempt to set a cookie when the form is submitted. This cookie is used to restore the e-mail address that the user entered when they return to the form again. Obviously in order for this mechanism to work the browser must be cookie-aware and have cookies switched on.</p>
		<h4>E-Mail Report File</h4>
		<p>Enabling this option will cause the application to send the report via e-mail to the specified user, instead of sending it to their web browser. This option is preferable if the web site being analysed is quite large, it also has the advantage that the web browser is released for further work. The application will continue to execute on the web server without further user intervention.</p>
		<h4>E-Mail Address</h4>
		<p>The user should enter their e-mail address into this field if they are using the form for the first time, if they have used this form before then they should be able to pick their address from the menu below instead. Even better, if a cookie has been set, the address field should already be filled in.</p>
		<p>Please enter the address carefully as no error checking is performed at present.</p>
		<h4>Or Choose Address</h4>
		<p>This menu will only appear once someone has already used the form and entered an e-mail address, the information is written into a file on the server for later re-use. The user may pick their e-mail address from this menu instead of entering it into the text field each time.</p>
		<!-- Other Options -->
		<hr width="98%">
		<h4>Other Options</h4>
		<p>The following options specify miscellaneous settings that control the behaviour of data returned.</p>
		<h4>Use Disk Storage</h4>
		<p>Enabling this option makes the program store document data on disk instead of in memory. This may be necessary when analysing very large web sites, but it also has a serious detrimental effect on performance. This option is <strong>not recommended</strong> unless absolutely necessary.</p>
		<!-- Starting The Analysis -->
		<hr width="98%">
		<h4>Starting The Analysis</h4>
		<p>Clicking the <strong>Reset Form</strong> button will clear any details that you have entered and return the form to its default settings.</p>
		<p>Once you have entered all of the necessary details, click the <strong>Begin Analysis</strong> button to begin. You will need to be very patient as the analysis may take <strong>A VERY LONG TIME</strong>.</p>
		<!-- Credits -->
		<hr width="98%">
		<center>
			<table border="0" width="99%" cellpadding="4" cellspacing="0">
				<tr>
					<td align="right" valign="top">
						<span class="white">W3Grab is Copyright (C) 2000 <a href="mailto:jason.holland@dial.pipex.com" subject="W3Grab">Jason&nbsp;Holland</a>.</span><br>
						<span class="white">W3Grab is distributed under the terms of the GNU General Public Licence.</span><br>
					</td>
				</tr>
			</table>
		</center>
	</body>
</html>
.
