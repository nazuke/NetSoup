#!/usr/local/bin/perl -w

package NetSoup::Apache::Hyperlink::Profiles::Public;
use strict;
use Apache;
use Apache::Constants qw( :http :response );
use DBI;
use Apache::URI;
use NetSoup::Autonomy::DRE::Query::HTTP;
use NetSoup::Apache::Cookies;
use NetSoup::Util::Arrays;
use NetSoup::Apache::Framework;
use constant ARRAYS => NetSoup::Util::Arrays->new();
@NetSoup::Apache::Hyperlink::Profiles::Public::ISA = qw();
1;


sub handler {
  my $r        = shift;
  my $img      = $r->dir_config( "LOGO" );
  my $alt_text = $r->dir_config( "ALT_TEXT" );
  my $uri      = backref($r);
  my $query    = query( $r );
  my $DRE      = NetSoup::Autonomy::DRE::Query::HTTP->new( Caching  => $r->dir_config( "CACHING" ),
                                                           Period   => $r->dir_config( "PERIOD" ),
                                                           Hostname => $r->dir_config( "HOSTNAME" ),
                                                           Port     => $r->dir_config( "PORT" ) );
  if( defined $query ) {
    $DRE->query( QMethod   => "s",
                 QueryText => $query,
                 QNum      => $r->dir_config( "NUMHITS" ),
                 Database  => $r->dir_config( "DATABASE" ),
                 XOptions  => "useurl" );
  }
  $r->send_http_header( "text/html" );
  $r->print( qq(<table class="Sidebar" border="0" width="180" cellpadding="4" cellspacing="0">
                <tr class="header">
                <td class="header" height="24">) );
  $r->print( $r->dir_config( "TITLE" ) );
  $r->print( qq(</td><td class="header" height="24" align="right" valign="center">
                <img src="$img" alt="$alt_text">
                </td></tr>) );
  if( $DRE->numhits() != 0 ) {
  RENDER: for( my $i = 1 ; $i <= $DRE->numhits() ; $i++ ) {
      my $url    = $DRE->field( Index => $i, Field => "doc_name" );
      my $title  = $DRE->field( Index => $i, Field => "url_title" );
      my $weight = $DRE->field( Index => $i, Field => "doc_weight" );
      my $icon   = $DRE->field( Index => $i, Field => $r->dir_config( "IMAGE" ) ) || $img;
      chomp( $weight ) if ( $weight );
      next RENDER if( ( ! $url )    ||
                      ( ! $title )  ||
                      ( ! $weight ) ||
                      ( $url eq $uri ) );
      $r->print( qq(<tr><td height="24" colspan="2" class="SidebarItem">
                    <img src="$icon" />
                    <a class="Sidebar" href="$url">$title</a>
                    </td></tr>\n) );
    }
  } else {
    $r->print( qq(<tr><td colspan="2" height="24" class="SidebarItem">
                  <p>Your profile is empty</p>
                  </td></tr>\n) );
  }
  $r->print( qq(</table>) );
  return( OK );
}


sub query {
  my $r       = shift;
  my $uri     = backref($r);
  my $Cookies = NetSoup::Apache::Cookies->new( Request => $r );
  my $query   = "";
  my $value   = $Cookies->getCookie( Key => $r->dir_config( "COOKIE_KEY" ) );
  if( $value ) {
    my $dbh = NetSoup::Apache::Framework->new()->dbh();
    $value  = $dbh->quote( $value );
    my $sth = $dbh->prepare( qq( SELECT urls FROM profiles.cookies WHERE pcookie=$value ) );
    $sth->execute();
    if( $sth->rows() ) {
      $query = join( "+", split( m/\n/s, $sth->fetchrow() ) );
    }
    $sth->finish();
  } else {
    $r->warn( "ERROR, NO COOKIE" );
  }
  return( $query );
}


sub update {
  my $r = shift;
  if( $r->is_main() ) {
    my $uri     = backref($r);
    my $Cookies = NetSoup::Apache::Cookies->new( Request => $r );
    my $value   = $Cookies->getCookie( Key => $r->dir_config( "COOKIE_KEY" ) );
    my $registered = $Cookies->getCookie( Key => $r->dir_config( "REGISTRATION_KEY" ) ) || ""; # Downloads registration cookie
    my @urls    = ();
    if( $value ) {
      my $dbh = NetSoup::Apache::Framework->new()->dbh();
      $value  = $dbh->quote( $value );
      my $sth = $dbh->prepare( qq( SELECT urls FROM profiles.cookies WHERE pcookie=$value ) );
      $sth->execute();
      if( $registered ) {
        $registered = $dbh->quote( $registered );
      } else {
        $registered = qq('');
      }
      if( $sth->rows() ) {
        ####################
        #  Update Profile  #
        ####################
        @urls = split( m/\n/s, $sth->fetchrow() );
        shift( @urls ) if( @urls > $r->dir_config( "PROFILE_SIZE" ) );
        push( @urls, $uri );
        my $urls   = $dbh->quote( join( "\n", ARRAYS->collapse( Array => \@urls ) ) );
        my $update = $dbh->prepare( qq( UPDATE profiles.cookies SET urls=$urls,dcookie=$registered WHERE pcookie=$value ) );
        $update->execute();
        $update->finish();
      } else {
        ####################
        #  Insert Profile  #
        ####################
        push( @urls, $uri );
        my $urls   = $dbh->quote( join( "\n", ARRAYS->collapse( Array => \@urls ) ) );
        my $insert = $dbh->prepare( qq( INSERT INTO profiles.cookies (urls,pcookie,dcookie) VALUES ($urls,$value,$registered) ) );
        $insert->execute();
        $insert->finish();
      }
      $sth->finish();
    } else {
      $r->warn( "ERROR, NO COOKIE" );
    }
    return( OK );
  }
  return( DECLINED );
}


sub backref {
  my $r      = shift;
  my $uri    = "";
  my $back_r = $r;
 BACK_REF: while( defined $back_r ) {
    $uri    = $back_r->uri();
    $back_r = $back_r->main() || undef;
  }
  $uri =~ s/^(.+)\..?html(.*)$/$1$2/;
  $uri =~ s:/index$:/:;
  return( $uri );
}
