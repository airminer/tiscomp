#include <vector>
#include "node.hpp"

bool Node::read(int  &dest) {
	return false;
}

void Node::step() {}

void Node::end() {}

Core::Core() : write(false), nwrite(false) {}

bool Core::read(int &dest) {
	if (write) {
		write = false;
		dest = out;
		return true;
	}
	return false;
}

void Core::end() {
	write = nwrite;
	nwrite = false;
	out = nout;
}

Stack::Stack() : write(false) {}

bool Stack::read(int &dest) {
	if (write) {
		write = false;
		dest = stack[outp];
		stack.erase(stack.begin() + outp);
		noutp--;
		return true;
	}
	return false;
}

void Stack::step() {
	int i;
	if (stack.size() < 15 && left->read(i)) stack.push_back(i);
	if (stack.size() < 15 && right->read(i)) stack.push_back(i);
	if (stack.size() < 15 && up->read(i)) stack.push_back(i);
	if (stack.size() < 15 && down->read(i)) stack.push_back(i);
	if (stack.size() > 0) {
		nwrite = true;
		noutp = stack.size() - 1;
	} else {
		nwrite = false;
	}
}

void Stack::end() {
	write = nwrite;
	outp = noutp;
}

StreamNode::StreamNode(FILE *file) : file(file) {}

InStream::InStream(FILE *file) : StreamNode(file) {}

bool InStream::read(int &dest) {
	return fscanf(file, "%d", &dest) == 1;
}

OutStream::OutStream(FILE *file) :
	StreamNode(file),
	eof(fscanf(file, "%d", &exp) != 1),
	errors(0), complete(false) {}

void OutStream::step() {
	if (!eof && up->read(in)) {
		if (exp == in) {
			printf("%d\n", in);
		}
		else {
			fprintf(stderr, "ERROR: %d -- expected %d\n", in, exp);
			errors++;
		}
		eof = fscanf(file, "%d", &exp) != 1;
	}
	//complete = eof && errors == 0;
	complete = eof;
}
