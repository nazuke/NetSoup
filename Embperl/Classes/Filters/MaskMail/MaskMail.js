function encodeString( s ) {
  // This function takes a plain text string and encodes
  // it as Unicode characters into an Array object.
  var theString = new String( s );
  var aEncoded  = new Array;
  for( i = 0 ; i < theString.length ; i++ ) {
    aEncoded.push( theString.charCodeAt(i) );
  }
  return( aEncoded );
}

function decodeString( aEncoded ) {
  // This function takes an Array of Unicode values
  // and constructs a plain text string.
  var sDecoded = "";
  for( i = 0 ; i < aEncoded.length ; i++ ) {
    sDecoded += String.fromCharCode( aEncoded[i] );
  }
  return( sDecoded );
}
