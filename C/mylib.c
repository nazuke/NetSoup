#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "mylib.h"


SV* p_getpid() {
  pid_t pid = getpid();
  SV* sPid  = newSViv( pid );
  return( sPid );
}


AV* create_array() {
  int i = 0;
  AV* theArray = newAV();
  for( i = 1 ; i <= 10 ; i++ ) {
    SV* theString = newSViv( i );
    av_push( theArray, theString );
  }
  return( theArray );
}
