#include <iostream>
#include "Time.hpp"

using namespace std;

int main() {
  Time test;
  cout << "Minutes\t" << test.minutes(10) << "\n";
  cout << "Hours\t"   << test.hours(10)   << "\n";
  cout << "Days\t"    << test.days(10)    << "\n";
  cout << "Weeks\t"   << test.weeks(10)   << "\n";
  cout << "Months\t"  << test.months(10)  << "\n";
  cout << "Years\t"   << test.years(10)   << "\n";
  return(0);
}
