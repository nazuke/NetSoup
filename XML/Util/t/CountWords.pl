#!/usr/local/bin/perl -w


use strict;
use NetSoup::XML::Util::CountWords;
my $XML      = join( "", <DATA> );
my $CountWords = NetSoup::XML::Util::CountWords->new();
print( "COUNT\t" . $CountWords->countxml( XML => \$XML ) . "\n" );
exit(0);


__DATA__
<?xml version="1.0" encoding="UTF-8"?>


<!DOCTYPE html
  PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "DTD/xhtml1-strict.dtd">


<html>
  <head>
    <title>Test</title>
    <meta content="Hello"/>
    <NetSoup:Test>
      <NetSoup:p>
        Namespace string
      </NetSoup:p>
    </NetSoup:Test>
  </head>
  <body>
    <h1>This is a header</h1>
    <img src="/images/file.jpg" alt="First Image"/>
    <!-- < This is a comment > -->
    <p>
      <a href="http://www.jason.holland.dial.pipex.com/" onLoad="alert('It\'s XHTML!')">
        This is a <em>link</em>
      </a>
    </p>
    <table width="100%">
      <tr>
        <td>
          <h3>This "string" is inside a table</h3>
        </td>
      </tr>
      <tr>
        <td>
          <table width="100%">
            <tr>
              <td>
                <p>
                  Here's another in a nested table.
                  With some more text followed by a line break<br/>
                  continuing on for a while.
                </p>
              </td>
            </tr>
            <tr>
              <td>
                <img src="/more/images/table.jpg" alt="A &quot;table&quot; Image"/>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
    <p>
      <strong>
        Strong Body Content...
        with a carriage return.
      </strong>
    </p>
    <h2>Another header</h2>
    <p>This is a <em>"quoted string"</em>.</p>
    <p>
      The following is a CDATA section:
      <![CDATA[
        This is within the CDATA section!
        This is within the CDATA section!
        This is within the CDATA section!
        This is within the CDATA section!
      ]]>
    </p>
    <img src="/images/file.jpg" alt="ALT TEXT"/>
    <p>
      Here's an &lt;IMG&gt; tag without an ALT attribute:
      <img src="/images/picture.jpg"/>
    </p>
  </body>
</html>
