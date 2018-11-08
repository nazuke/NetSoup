#!/usr/bin/perl -w -I/home/jasonh/lib
# This is a TotalHack(tm) for downloading and indexing Autonomy's daily NewsEdge feed.

use strict;
use Socket;
use NetSoup::Protocol::BatchUp;
use NetSoup::Files::Directory;
use NetSoup::Files::Load;
use NetSoup::HTML::HTML2Text;
use NetSoup::XML::Parser;


my $TEMPLATE   = join( "", <DATA> );
my $username   = "anonymous";
my $password   = 'jasonh@autonomy.com';
my $ftpdir     = "/NewsEdgePortal/FTP/autohp1";
my $zipfile    = "autohp1.zip";
my $NOW        = time;
my $WEBSPACE   = "/var/www/html/NewsEdge2";
my %KillList   = ();
my %DUPLICATES = ();
open( KILLFILE, "$WEBSPACE/killfile.txt" );
while( <KILLFILE> ) {
  chomp;
  my $key         = lc( $_ );
  $KillList{$key} = 1;
}
close( KILLFILE );
my $target_dir = join( "", $WEBSPACE, "/", $NOW );
my $Directory  = NetSoup::Files::Directory->new();
my $Load       = NetSoup::Files::Load->new();
my $HTML2Text  = NetSoup::HTML::HTML2Text->new();
my $BatchUp    = NetSoup::Protocol::BatchUp->new( Hostname => "10.1.1.53",
                                                  Port     => 20005,
                                                  QLength  => 100,
                                                  Prefix   => "POST /DREADDDATA?KILLDUPLICATES=_DRETITLE_REFERENCE_DREREFERENCE_\n\n",
                                                  Postfix  => "\n#DREENDDATA_DRETITLE_REFERENCE_\n" );
print( "Downloading $zipfile\n" );
system( "mkdir $target_dir" );
system( "ncftpget -E -u $username -p $password 10.1.1.12 $target_dir $ftpdir/$zipfile" );
print( qq(Unzipping "$zipfile"\n) );
system( "unzip -q-o -d $target_dir $target_dir/$zipfile" );
unlink( "$target_dir/$zipfile" );
print( qq("$target_dir"\n) );
$Directory->descend( Pathname    => $target_dir,
                     Recursive   => 1,
                     Directories => 0,
                     Files       => 1,
                     Callback    => sub {
                       my $pathname = shift;
                       if( $pathname =~ m/\.xml$/i ) {
                         my $target_dir = $NOW;
                         my $filename   = $Load->filename( Pathname => $pathname );
                         my $HTML       = $Load->immediate( Pathname => $pathname );
                         print( qq(Indexing "$pathname"\n) );
                         my ( $title ) = ( $HTML =~ m/<title>\n*([^<>]+)\n*<\/title>/gis );
                         if( ( defined $title ) && ( ! exists $KillList{$title} ) ) {
                           my ( $content )  = ( $HTML =~ m/<block>(.+)<\/block>/gis );
                           if( ! exists( $DUPLICATES{$title} ) ) {
                             my $source    = "";
                             my $summary   = "";
                             $summary      =~ s/[\r\n+]/ /gs;
                             my $fixedpath = $pathname;
                             $fixedpath    =~ s:/var/www/html/NewsEdge2/$NOW/::;
                             $fixedpath    =~ s/\.xml$/\.html/i;
                             my $IDX       = join( "",
                                                   "#DREREFERENCE http://194.200.13.52/NewsEdge2/$target_dir/$fixedpath\n",
                                                   "#DRETITLE $title\n",
                                                   "#DREFIELD source=\"$source\"\n",
                                                   #"#DREFIELD summary=\"$summary\"\n",
                                                   "#DREFIELD image=\"newsedge.com\"\n",
                                                   "#DRECONTENT\n",
                                                   $HTML2Text->html2text( HTML => $HTML ) . "\n",
                                                   "#DREDBNAME NewsEdge\n",
                                                   "#DRESTORECONTENT y\n",
                                                   "#DREDATE ",
                                                   $NOW,
                                                   "\n#DREENDDOC\n" );
                             $BatchUp->add( Data => $IDX );
                             $DUPLICATES{$title} = 1;
                             $pathname           =~ s/\.xml$/\.html/i;
                             if( open( FILE, ">$pathname" ) ) {
                               my $LOC_TEMPLATE = $TEMPLATE;
                               $LOC_TEMPLATE    =~ s/__TITLE__/$title/gis;
                               $LOC_TEMPLATE    =~ s/__CONTENT__/$content/gis;
                               print( FILE $LOC_TEMPLATE );
                               close( FILE );
                             } else {
                               print( "Sod it!\n" );
                               exit(1);
                             }
                           }
                         }
                       }
                     } );
exit(0);
