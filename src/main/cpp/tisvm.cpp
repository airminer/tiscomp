#include "node.hpp"

int main(int argc, char* argv[]) {
	Stack s;
	Node nil;
	s.up = s.down = s.left = s.right = &nil;
	while (true) {
		int i;
		s.step();
		if (s.read(i)) {
			printf("Read: %d", i);
		} else {
			printf("Read failed\n");
		}
		s.end();
	}
}
