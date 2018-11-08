#include "Time.hpp"

int Time::minutes( int minutes ) {
  int total = 60 * minutes;
  return( total );
}

int Time::hours( int hours ) {
  int total = 60 * minutes(1);
  return( hours * total );
}

int Time::days( int days ) {
  int total = 24 * hours(1);
  return( days * total );
}

int Time::weeks( int weeks ) {
  int total = 7 * days(1);
  return( weeks * total );
}

int Time::months( int months ) {
  int total = 31 * days(1);
  return( months * total );
}

int Time::years( int years ) {
  int total = 365 * days(1);
  return( years * total );
}
