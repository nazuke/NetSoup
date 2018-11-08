#!/usr/local/bin/perl -w


use NetSoup::Files::Directory;
use NetSoup::Persistent::TabText;


my $FIELDSCFG = $Box->directory() . "/fields.cfg"; # Database field names
my $DBSORTCFG = $Box->directory() . "/dbsort.cfg"; # Multiple database files sort order
my $DBWRAPCFG = 5;


open( CFG, $FIELDSCFG );                                                             # Open fields config file
my @Fields      = map { $_ =~ m/^(.+)$/ } <CFG>;
my $NumFields   = scalar( @Fields ) + 2;
my $DB          = $CGI->field( Name => "database", Format => "ascii" ) || "Sample";  # Default to sample database
my $DB_Handle   = qq(<input type="hidden" name="database" value="$DB" />);
my $FormHandler = $Box->URI();                                                       # Handler used in forms
my $Redirect    = $Box->URI() . "?database=$DB";                                     # Handler used for redirects
my $Pathname    = $Box->directory() . "/$DB.db";
my $Directory   = NetSoup::Files::Directory->new();
my $TabText     = NetSoup::Persistent::TabText->new( Pathname => $Pathname,
                                                     Fields   => \@Fields );
close( CFG );
$Document->registerSource( Source => $Pathname );                                    # Register source file dependency
if ( ! defined $TabText ) {
  print( STDERR qq(ERROR: Failed to attach to database "$Pathname"\n) );
  $Document->out( qq(<p style="color:red;">ERROR: Failed to attach to database "$Pathname"</p>) );
} else {
  my $mode = $CGI->field( Name => "function", Format => "ascii" );
  $Document->out( qq(<table class="lightborder" border="0" cellpadding="4" cellspacing="0"><tr>) );
  $Document->out( qq(
                     <td class="dark" valign="top">
                     <form method="GET" action="$FormHandler">
                     $DB_Handle
                     <input class="smallbutton" type="submit" value="Main Screen" />
                     </form></td>
                     <td class="dark" valign="top">
                     <form method="GET" action="$FormHandler?database=$DB">
                     $DB_Handle
                     <input type="hidden" name="function" value="new" />
                     <input class="smallbutton" type="submit" value="Add New Entry" />
                     </form></td>
                     <td class="dark" valign="top">
                     <form method="GET" action="$FormHandler?database=$DB">
                     $DB_Handle
                     <input type="hidden" name="function" value="export" />
                     <input class="smallbutton" type="submit" value="Export" />
                     </form></td>
                    ) );
  $Document->out( qq(</tr></table>) );
  if ( -e $DBSORTCFG ) {
    open( DBSORT, $DBSORTCFG );
    my @DB_SortOrder = map { $_ =~ m/^(.+)\.db$/ } <DBSORT>;
    close( DBSORT );
    my $wrap = 1;
    $Document->out( qq(<hr /><table class="darkborder" border="0" cellpadding="4" cellspacing="0"><tr>) );
    foreach my $db ( @DB_SortOrder ) {
      $Document->out( qq(<td class="light" valign="top">
                         <form method="GET" action="$FormHandler">
                         <input type="hidden" name="database" value="$db" />
                         <input class="smallbutton" type="submit" value="$db" />
                         </form></td>) );
      if ( $wrap >= $DBWRAPCFG ) {
        $Document->out( qq(</tr><tr>) );
        $wrap = 1;
      } else {
        $wrap++;
      }
    }
    if ( $wrap < $DBWRAPCFG ) {
      for ( my $i = $wrap ; $i <= $DBWRAPCFG ; $i++ ) {
        $Document->out( qq(<td class="light">&nbsp;</td>) );
      }
    }
    $Document->out( qq(</tr></table><hr />) );
  } else {
    $Document->out( qq(<hr /><table class="darkborder" border="0" cellpadding="4" cellspacing="0"><tr>) );
    $Directory->descend( Pathname    => $Box->directory(),
                         Extensions  => ["db"],
                         Recursive   => 0,
                         Files       => 1,
                         Directories => 0,
                         Sort        => 1,
                         Callback    => sub {
                           my ( $db ) = ( $Directory->filename( Pathname => (shift) ) =~ m/^([^\.]+)\./ );
                           $Document->out( qq(<td class="light" valign="top">
                                              <form method="GET" action="$FormHandler">
                                              <input type="hidden" name="database" value="$db" />
                                              <input class="smallbutton" type="submit" value="$db" />
                                              </form></td>) );
                           return(1);
                         } );
    $Document->out( qq(</tr></table><hr />) );
  }
 MODE: for( $mode ) {


    # NEW ENTRY FORM
    ( defined $mode ) && m/^new$/i && do {
      $Document->out( qq(<form method="GET" action="$FormHandler">
                         $DB_Handle
                         <input type="hidden" name="function" value="add" />) );
      $Document->out( qq(<div class="rule"><table border="0" cellpadding="4" cellspacing="0">\n) );
      $Document->out( qq(<tr><td class="dark" colspan="2">
                         <strong>Add New Entry</strong>
                         </td></tr>) );
      foreach my $field ( @Fields ) {
        $Document->out( qq(<tr><td class="dark">$field</td>
                           <td class="light">
                           <input type="text" name="$field" value="" size="40" maxlength="128" />
                           </td></tr>) );
      }
      $Document->out( qq(<tr><td class="dark">\&nbsp;</td>
                         <td class="dark" align="right">
                         <input class="smallbutton" type="submit" value="Submit" />
                         <input class="smallbutton" type="button" value="Cancel" onClick="window.location='$FormHandler?database=$DB'" />
                         </td></tr>) );
      $Document->out( qq(</table></div>\n) );
      $Document->out( qq(</form>\n) );
      last MODE;
    };


    # ADD NEW ENTRY
    ( defined $mode ) && m/^add$/i && do {
      my $Key = $CGI->field( Name => $Fields[0], Format => "ascii" );
      $Key   .= time if( ! $TabText->available( Key => $Key ) );
      foreach my $field ( @Fields ) {
        $TabText->$field( Key   => $Key,
                          Value => $CGI->field( Name   => $field,
                                                Format => "ascii" ) );
      }
      $Document->nocache();
      $Document->location( URL => $Redirect );
      last MODE;
    };


    # DELETE ENTRY
    ( defined $mode ) && m/^delete$/i && do {
      $TabText->remove( Key => $CGI->field( Name => "KEY", Format => "ascii" ) );
      $Document->nocache();
      $Document->location( URL => $Redirect );
      last MODE;
    };


    # EDIT ENTRY
    ( defined $mode ) && m/^edit$/i && do {
      my $Key  = $CGI->field( Name => "KEY", Format => "ascii" );
      my $name = $TabText->Name( Key => $Key );
      $Document->out( qq(<form method="GET" action="$FormHandler">
                         $DB_Handle
                         <input type="hidden" name="function" value="update" />
                         <input type="hidden" name="KEY" value="$Key" />
                         <div class="rule">
                         <table border="0" cellpadding="4" cellspacing="0">
                         <tr><td class="dark" colspan="2">
                         <strong>Edit entry for "$name"</strong>
                         </td></tr>) );
      foreach my $field ( @Fields ) {
        my $value = $TabText->$field( Key => $Key );
        $Document->out( qq(<tr>
                           <td class="dark">$field</td>
                           <td class="light">
                           <input type="text" name="$field" value="$value" size="40" />
                           </td>
                           </tr>) );
      }
      $Document->out( qq(<tr><td class="dark">\&nbsp;</td>
                         <td class="dark" align="right">
                         <input class="smallbutton" type="submit" value="Submit" />
                         <input class="smallbutton" type="button" value="Cancel" onClick="window.location='$FormHandler?database=$DB'" />
                         </td></tr></table></div>
                         </form>) );
      $Document->nocache();
      last MODE;
    };


    # UPDATE ENTRY
    ( defined $mode ) && m/^update$/i && do {
      my $Key = $CGI->field( Name => "KEY", Format => "ascii" );
      foreach my $field ( @Fields ) {
        $TabText->$field( Key   => $Key,
                          Value => $CGI->field( Name   => $field,
                                                Format => "ascii" ) );
      }
      $Document->nocache();
      $Document->location( URL => $Redirect );
      last MODE;
    };


    # EXPORT
    ( defined $mode ) && m/^export$/i && do {
      my $Key  = $CGI->field( Name => "KEY", Format => "ascii" );
      my $name = $TabText->Name( Key => $Key );
      $Document->out( qq(<table border="0" cellpadding="4" cellspacing="0">
                         <tr><td class="dark"><form><textarea cols="78" rows="20">) );
      $Document->out( join( "\t", @Fields ) . "\n" );
      foreach my $Key ( sort $TabText->keylist() ) {
        my @values = ();
        foreach my $field ( @Fields ) {
          push( @values, $TabText->$field( Key => $Key ) );
        }
        $Document->out( join( "\t", @values ) . "\n" );
      }
      $Document->out( qq(</textarea></form></td></tr></table></td></tr>) );
      $Document->nocache();
      last MODE;
    };


    # DISPLAY
    ( ! defined $mode ) && do {
      $Document->out( qq(<div class="rule"><table class="darkborder" border="0" width="98\%" cellpadding="4" cellspacing="0">\n) );
      $Document->out( "<tr>" );
      foreach my $field ( @Fields ) {
        $Document->out( qq(<td class="dark"><strong>$field</strong></td>) );
      }
      $Document->out( qq(<td class="dark" align="center"><strong>Edit</strong></td>) );
      $Document->out( qq(<td class="dark" align="center"><strong>Del</strong></td>) );
      $Document->out( "</tr>" );
      if ( ! $TabText->empty() ) {
        my $colour = "light";
        foreach my $Key ( sort $TabText->keylist() ) {
          $Document->out( "<tr>" );
          foreach my $field ( @Fields ) {
            my $value = $TabText->$field( Key => $Key );

            if ( $value =~ m/\@/ ) {
              $value = qq(<a href="mailto:$value" class="$colour">$value</a>);
            } else {
              #$value =~ s/ /\&nbsp;/gs;
            }
            $value = '&nbsp;' if( length( $value ) == 0 );
            $Document->out( qq(<td class="$colour" valign="top">$value</td>) );
          }
          $Document->out( qq(<td class="$colour" valign="top">
                             <form method="GET" action="$FormHandler">
                             $DB_Handle
                             <input type="hidden" name="function" value="edit" />
                             <input type="hidden" name="KEY" value="$Key" />
                             <input class="smallbutton" type="submit" value="Edit" />
                             </form>
                             </td>) );
          $Document->out( qq(<td class="$colour" valign="top">
                             <form method="GET" action="$FormHandler">
                             $DB_Handle
                             <input type="hidden" name="function" value="delete" />
                             <input type="hidden" name="KEY" value="$Key" />
                             <input class="smallbutton" type="submit" value="Delete" />
                             </form>
                             </td>) );
          $Document->out( "</tr>\n" );
          if ( $colour eq "light" ) {
            $colour = "dark";
          } else {
            $colour = "light";
          }
        }
      } else {
        $Document->out( qq(<tr><td class="light" colspan="$NumFields">Empty Database</td></tr>\n) );
      }
      $Document->out( qq(</table></div>\n) );
    };


  }
}


1;
