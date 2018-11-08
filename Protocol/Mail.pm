#!/usr/local/bin/perl
#
#   NetSoup::Protocol::Mail.pm v01.01.08b 12042000
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
#   Description: This Perl Class Library contains a set of simple
#                methods for composing and sending electronic mail.
#                Requires UNIX and the 'sendmail' command.
#
#
#   Methods:
#       mail  -  This static method constructs and sends a mail message


package NetSoup::Protocol::Mail;
use strict;
use NetSoup::Core;
@NetSoup::Protocol::Mail::ISA = qw( NetSoup::Core );
1;


sub multimail {
  # This static method mails a message to multiple recipients.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              To          => \@recipients
  #              From        => $from
  #              Subject     => $subject
  #              ContentType => $contentType
  #              Message     => $message
  #              Attach      => \@array of \%hash { Filename => $filename
  #                                                 Content  => \$content
  #                                                 Type     => $mimetype }
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    NetSoup::Protocol::Mail->mail();
  my $package = shift;                        # Get package
  my $class   = $package || ref( $package );  # Derive class
  my %args    = @_;                           # Get arguments
  return(1);
}


sub mail {
  # This static method constructs and sends a mail message.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              To          => $to
  #              From        => $from
  #              CC          => $cc
  #              Subject     => $subject
  #              ContentType => $contentType
  #              Message     => $message
  #              Attach      => \@array of \%hash { Filename => $filename
  #                                                 Content  => \$content
  #                                                 Type     => $mimetype }
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    NetSoup::Protocol::Mail->mail();
  my $package       = shift;                                                    # Get package
  my $class         = $package || ref( $package );                              # Derive class
  my %args          = @_;                                                       # Get arguments
  my %headers       = ( "To:"      => $args{To},
                        "Subject:" => $args{Subject} );                         # Initialise headers
  my $ctype         = $args{ContentType} || "";                                 # Get Content-type
  my $message       = $args{Message}     || "";                                 # Initialise body container
  my @attachments   = ();                                                       # Initialise attachments array
  my $postmail      = 0;                                                        # Indicates success opening mail handle
  $headers{"From:"} = $args{From} if( exists $args{From} );                     # Add line to header
  $headers{"CC:"}   = $args{CC}   if( exists $args{CC} );                       # Add line to header
  if( exists $args{Attach} ) {                                                  # Attach files
    my $term = $class->terminator();                                            # Get new MIME terminator string
    $headers{"Content-Type:"} = qq(multipart/mixed; boundary="$term");          # Configure MIME content type header
    push( @attachments,
          "\r\n--" . $term . "\r\n" .
          qq(Content-type: text/plain\r\n\r\n) .
          $message .
          "\r\n--" . $term . "\r\n" );
    foreach my $part ( @{$args{Attach}} ) {
      my $content = $part->{Content};
      push( @attachments,
            "\r\n\r\n--" . $term . "\r\n" .
            qq(Content-type: $part->{Type};name="$part->{Filename}"\r\n\r\n) .  #
            $$content .
            "\r\n--" . $term );
    }
    push( @attachments, "--\r\n\r\n\r\n" );
  } else {
    $headers{"Content-Type:"} = $ctype if( exists $args{ContentType} );         # Add subject line to header
  }
  $postmail++ if( open( MAIL, "| /usr/sbin/sendmail -oi -t" ) ||                # Attempt to use UNIX 'sendmail' command
                  open( MAIL, "| mail $args{To}" ) );                           # Attempt to open pipe to UNIX 'mail' command
  if( $postmail ) {
    foreach my $key ( keys %headers ) {                                         # Output headers
      print( MAIL "$key$headers{$key}\r\n" );
    }
    print( MAIL "\r\n" );
    if( exists $args{Attach} ) {
      print( MAIL "This is a multi-part message in MIME format.\r\n\r\n" );
      print( MAIL join( "", @attachments ) )
    } else {
      print( MAIL "$message\r\n" );                                             # Output message body
    }
    close( MAIL );
  } else {
    $class->debug( "$args{To}\t$args{Subject}" );                               # Bail out and write error message
    return(0);
  }
  return(1);
}


sub terminator {
  # This method returns a unique string based upon the
  # current date. It may be used as a reasonably random
  # value for a multipart MIME document terminator string.
  # Calls:
  #    none
  # Parameters Required:
  #    none
  # Result Returned:
  #    scalar
  # Example:
  #    my $term = $object->terminator();
  my( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime( time );
  return( "term$sec$min$hour$mday$mon$year" );
}
