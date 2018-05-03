#include <vector>
#include "node.hpp"
#include "tisvm.hpp"

Node *nil;
Node *array[20];

std::vector<Node*> nodes;
std::vector<OutStream*> outStreams;

void init_array() {
	nil = new Node();
	for (int i = 0; i < 20; i++) {
		array[i] = nil;
	}
}

void insert_node(const int i, Node *n) {
	array[i + 4] = n;
	if (i % 4 == 0) {
		n->left = nil;
	} else {
		n->left = array[i + 3];
		if (array[i + 3] != nil) {
			array[i + 3]->right = n;
		}
	}
	if (i % 4 == 3) {
		n->right = nil;
	} else {
		n->right = array[i + 5];
		if (array[i + 5] != nil) {
			array[i + 5]->left = n;
		}
	}
	n->up = array[i];
	if (array[i] != nil) {
		array[i]->down = n;
	}
	n->down = array[i + 8];
	if (array[i + 8] != nil) {
		array[i + 8]->up = n;
	}
	nodes.push_back(n);
}

void insert_inStream(const int i, InStream *s) {
	array[i] = s;
	s->down = array[i + 4];
	if (array[i + 4] != nil) {
		array[i + 4]->up = s;
	}
}

void insert_outStream(const int i, OutStream *s) {
	array[i + 16] = s;
	s->up = array[i + 12];
	if (array[i + 12] != nil) {
		array[i + 12]->down = s;
	}
	outStreams.push_back(s);
}

void run() {
	while (outStreams.size() > 0) {
		for (Node *n : nodes) {
			n->step();
		}
		std::vector<OutStream*>::iterator s = outStreams.begin();
		while (s != outStreams.end()) {
			(*s)->step();
			if ((*s)->complete) {
				s = outStreams.erase(s);
			} else {
				s++;
			}
		}
		if (outStreams.size() > 0) {
			for (Node *n : nodes) {
				n->end();
			}
		}
	}
}
