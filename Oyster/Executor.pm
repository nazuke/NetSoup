#!/usr/local/bin/perl
#
#   NetSoup::Oyster::Executor.pm v00.00.01a 12042000
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
#
#
#   Methods:
#       method  -  description


package NetSoup::Oyster::Executor;
use strict;
use POSIX qw( strftime );
use Digest::MD5;
use NetSoup::Core;
use NetSoup::CGI;
use NetSoup::Files;
use NetSoup::Oyster::Box;
use NetSoup::Oyster::Document;
use NetSoup::Oyster::SSI;
use NetSoup::XML::Parser;
use NetSoup::XML::File;
use NetSoup::XML::DOM2::Traversal::TreeWalker;
use NetSoup::XML::DOM2::Traversal::Serialise;
@NetSoup::Oyster::Executor::ISA = qw( NetSoup::Core );
use constant TREEWALKER => qw( NetSoup::XML::DOM2::Traversal::TreeWalker );
use constant SERIALISE  => qw( NetSoup::XML::DOM2::Traversal::Serialise );
use constant LOGTIME    => strftime( "%a %b %e %H:%M:%S %Y", gmtime );
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    Executor
  #    hash    {
  #              # => #
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Executor  = shift;                                                                # Get object
  my %args      = @_;                                                                   # Get arguments
  my $Box       = NetSoup::Oyster::Box->new();                                          # Oyster Box object
  my $cachepath = "";
  my $MD5       = Digest::MD5->new();
  $MD5->add( $Box->URL() );
  $MD5->add( $ENV{REDIRECT_DOCUMENT_URI} || "" );
  $MD5->add( $ENV{REDIRECT_REDIRECT_DOCUMENT_URI} || "" );
  $MD5->add( $ENV{QUERY_STRING} || "" );
  $MD5->add( $ENV{REDIRECT_QUERY_STRING} || "" );
  $Executor->{Debug}    = $args{Debug}    || 0;                                                 # Debug flag
  $Executor->{Beautify} = $args{Beautify} || 0;                                                 # Beautify flag
  $Executor->{Script}   = $Box->script();                                                       # Pathname of PerlXML script
  $Executor->{Cache}    = $Executor->cachefile( Pathname => $Box->tempdir() . "/PerlXML",
                                                Digest   => $MD5->hexdigest() );
  $Executor->{UseCache} = 1;                                                                    # Default to caching
  if( ( -e $Executor->{Cache} ) && ( open( CACHE, $Executor->{Cache} ) ) ) {                    #
    my @patterns = ();
    my $buf      = "";
  LOAD: while( $buf = <CACHE> ) {
      if( $buf =~ m/<!-- .+ -->/ ) {
        chomp( $buf );
        push( @patterns, $buf );
      } else {
        last LOAD;
      }
    }
    close( CACHE );
    if( scalar @patterns == 0 ) {
      $Executor->{UseCache} = 0;
    } else {
      my ( $dev, $ino, $mode, $nlink, $uid, $gid, $rdev,
           $size, $atime, $mtime, $ctime, $blksize, $blocks ) = stat( $Executor->{Cache} );
      { # Check Source PXML File
        # This does not check modified Perl modules or other linked files.
        my ( $_dev, $_ino, $_mode, $_nlink, $_uid, $_gid, $_rdev,
             $_size, $_atime, $_mtime, $_ctime, $_blksize, $_blocks ) = stat( $Executor->{Script} );  #
        $Executor->{UseCache} = 0 if( $_mtime > $mtime );
      }
      { # Check Registered Source Files
        foreach my $comment ( @patterns ) {
          my ( $pathname ) = ( $comment =~ m/SOURCE: "(.+)"/gs );
          if( -e $pathname ) {
            my ( $_dev, $_ino, $_mode, $_nlink, $_uid, $_gid, $_rdev,
                 $_size, $_atime, $_mtime, $_ctime, $_blksize, $_blocks ) = stat( $pathname );  #
            $Executor->{UseCache} = 0 if( $_mtime > $mtime );
          } else {
            ;
          }
        }
      }
    }
  } else {
    $Executor->{UseCache} = 0;
  }
  return( $Executor );
}


sub execute {
  # This method executes the Perl code in the XML document.
  # Calls:
  #    none
  # Parameters Required:
  #    Executor
  #    hash    {
  #              XML => $XML
  #            }
  # Objects Available:
  #    NetSoup::Oyster::Box
  #    NetSoup::Oyster::Document
  #    NetSoup::CGI
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $_Executor = shift;                                                    # Get object
  my %_args     = @_;                                                       # Get arguments
  my $Box       = NetSoup::Oyster::Box->new();                              # Oyster Box object
  my $Document  = NetSoup::Oyster::Document->new();                         # Oyster Document object
  my $CGI       = NetSoup::CGI->new();                                      # CGI interface object
  my $LoadXML   = NetSoup::XML::File->new( Debug => $_Executor->{Debug} );  # XML file format loader object
  if( $_Executor->{UseCache} == 1 ) {                                       # Cache control
    my $Cached = "";
    my $_dummy = "";
    open( CACHE, $_Executor->{Cache} );
    $Cached = join( "", <CACHE> );
    close( CACHE );
    $Document->target( Target => \$_dummy );
    $Document->result( Result => $Cached . "\n<!--Cached-->" );             # Commit rendered XML to Document object    
    return( $Document );
  }
  my $_HTML     = "";
  my $_Parser   = NetSoup::XML::Parser->new();
  my $_DOM      = $_Parser->parse( XML => $_args{XML} );
  if( $_Parser->flag( Flag => "Error" ) ) {
    foreach my $error ( $_Parser->errors() ) {
      $Document->out( qq(<p style="color:red;">$error</p>) );
      $Document->nocache();
      print( STDERR LOGTIME . "\t$error\n" );
    }
    return( undef );
  }
  my $_TreeWalker = TREEWALKER->new( Root        => $_DOM,
                                     Filter      => sub { return(1) },
                                     CurrentNode => $_DOM );
  $_TreeWalker->walkTree( Node     => $_DOM,
                          Callback => sub {
                            my $_Node = shift;
                          SWITCH: for( $_Node->nodeName() ) {
                              m/^script$/i &&
                                ( $_Node->getAttribute( Name => "language" ) =~ m/^PerlXML$/i ) &&
                                  ( $_Node->getAttribute( Name => "src" ) =~ m/^.+$/i ) &&
                                    do {
                                      my $_Parent = $_Node->parentNode();
                                      my $_Script = "";
                                      my $_Src    = $Box->directory() . "/" . $_Node->getAttribute( Name => "src" );
                                      if( -e $_Src ) {
                                        open( SCRIPT, $_Src );
                                        $_Script = join( "", <SCRIPT> );
                                        close( SCRIPT );
                                        my $_target   = "";
                                        $Document->target( Target => \$_target );
                                        if( ! defined eval( $_Script ) ) {
                                          my $message = "";
                                          if( $@ ) {
                                            $message = $@;
                                          } else {
                                            $message = qq(The code fragment "$_Src" needs to return "true" to prevent this message);
                                          }
                                          $Document->out( qq(<p style="color:red;">$message</p>) );
                                          $Document->nocache();
                                        }
                                        my $_Text = $_DOM->createTextNode( Data          => $_target,
                                                                           OwnerDocument => $_DOM );
                                        $_Parent->replaceChild( OldChild => $_Node,
                                                                NewChild => $_Text );
                                      } else {
                                        print( STDERR LOGTIME . qq(\t The Perl source file "$_Src" could not be found\n) ); # DEBUG
                                        my $_Text = $_DOM->createTextNode( Data          => qq(<p style="color:red;">The Perl source file "$_Src" could not be found</p>),
                                                                           
                                                                           OwnerDocument => $_DOM );
                                        $_Parent->replaceChild( OldChild => $_Node,
                                                                NewChild => $_Text );
                                      }
                                      last SWITCH;
                                    };
                              m/^script$/i &&
                                ( $_Node->getAttribute( Name => "language" ) =~ m/^PerlXML$/i ) &&
                                  do {
                                    my $_target = "";
                                    my $_Parent = $_Node->parentNode();
                                    my $_Child  = $_Node->firstChild();
                                    $Document->target( Target => \$_target );
                                    if( ! defined eval( $_Child->nodeValue() ) ) {
                                      $Document->out( qq(<p style="color:red;">Error \$\@: "$@"  at line $.</p>) );
                                      $Document->out( qq(<p style="color:red;">Error \$!:  "$!"  at line $.</p>) );
                                      $Document->out( qq(<p style="color:red;">Error \$^E: "$^E" at line $.</p>) );
                                      $Document->out( qq(<p style="color:red;">Error \$?:  "$?"  at line $.</p>) );
                                      #$Document->out( "<pre>" . $_Child->nodeValue() . "</pre>" );
                                      $Document->nocache();
                                    }
                                    my $_Text = $_DOM->createTextNode( Data          => $_target,
                                                                       OwnerDocument => $_DOM );
                                    $_Parent->replaceChild( OldChild => $_Node,
                                                            NewChild => $_Text );
                                    last SWITCH;
                                  };
                              return(1);
                            }
                          } );
  { # Register Source Documents
    foreach my $source ( $Document->_sources() ) { # Attach registered source file comments
      $_DOM->insertBefore( RefChild => $_DOM->firstChild(),
                           NewChild => $_DOM->createComment( Data => qq( SOURCE: "$source" ) ) );
    }
  }
  my $_Serialise = SERIALISE->new( Filter      => sub { return(1) },
                                   CurrentNode => $_DOM,
                                   StrictSGML  => 1 );
  $_Serialise->serialise( Node => $_DOM, Target => \$_HTML );
  { # Beautify XML
    if( $_Executor->{Beautify} == 1 ) {
      $_DOM = $_Parser->parse( XML => \$_HTML );
      $_Serialise->serialise( Node       => $_DOM,
                              Target     => \$_HTML,
                              StrictSGML => 1 );
    }
  }
  { # Process SSI Directives
    if( $Document->_ssi() ) {
      $_HTML = NetSoup::Oyster::SSI->new()->execute( HTML => $_HTML );
    }
  }
  $Document->result( Result => $_HTML );                              # Commit rendered XML to Document object
  { # Update Cache
    $_Executor->{UseCache} = $Document->cache();
    if( $_Executor->{UseCache} ) {
      NetSoup::Files->new()->buildTree( Pathname => $_Executor->{Cache} );
      if( open( CACHE, ">$_Executor->{Cache}" ) ) {
        print( CACHE $Document->result() );
        close( CACHE );
        chmod( 0666, $_Executor->{Cache} );
      } else {
        $Document->out( qq(<p style="color:red;">WARN: Could not write cache file "$_Executor->{Cache}".</p>) );
      }
    }
  }
  return( $Document );
}


sub cachefile {
  my $Executor = shift;                                                                # Get object
  my %args     = @_;                                                                   # Get arguments
  my $pathname = $args{Pathname};
  my @chars    = split( //, $args{Digest} );
  while( @chars ) {
    $pathname .= "/" . shift( @chars ) . shift( @chars );
  }
  return( $pathname . "/cache.xml" );
}
