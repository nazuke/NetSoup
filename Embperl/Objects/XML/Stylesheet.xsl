<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/TR/WD-xsl">

  <html>
    <head></head>
    <body>
      <ol>
        <xsl:for-each select="item">
          <li><xsl:process select="item"/></li>
        </xsl:for-each>
      </ol>
    </body>
  </html>
    

</xsl:stylesheet>
