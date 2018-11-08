#include <stdio.h>

int main() {
	char c;
	while(1) {
		c = getc(1);
		printf( "%c", c );
		sleep(1);
	}
	exit(0);
}
