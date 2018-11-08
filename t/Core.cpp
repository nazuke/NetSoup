#include <string>
#include "Core.hpp"


int main() {
  Core   test;
  string message = "This is a debug message\n";
  test.debug( &message );
  return(0);
}
