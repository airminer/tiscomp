#include <vector>
#include "node.hpp"

bool Node::read(int  &dest, Node* reader) {
	return false;
}

void Node::step() {}

void Node::end() {}

Node *any = new Node();

Proc::Proc(int instrn) : write(false), nwrite(false), writec(false),
	last(NULL), acc(0), bak(0), pc(0), instrn(instrn) {}

void Proc::swp() {
	int i = acc;
	acc = bak;
	bak = i;
}

bool Proc::readFrom(int &dest, Node *source) {
	if (source == any) {
		if (left->read(dest, this)) {
			last = left;
			return true;
		} else if (right->read(dest, this)) {
			last = right;
			return true;
		}
		else if(up->read(dest, this)) {
			last = up;
			return true;
		}
		else if(down->read(dest, this)) {
			last = down;
			return true;
		}
		return false;
	} else if (source == NULL) {
		dest = 0;
		return true;
	} else {
		return source->read(dest, this);
	}
}

void Proc::add(const int i) {
	acc = acc + i;
	if (acc > 999) acc = 999;
	else if (acc < -999) acc = -999;
}

void Proc::sub(const int i) {
	acc = acc - i;
	if (acc > 999) acc = 999;
	else if (acc < -999) acc = -999;
}

void Proc::jro(const int i) {
	pc = pc + i;
	if (pc > instrn - 1) pc = instrn - 1;
	else if (pc < 0) pc = 0;
}

void Proc::mov(const int i, Node* target) {
	nout = i;
	nwdest = target;
	nwrite = true;
}

bool Proc::read(int &dest, Node* reader) {
	if (write && (reader == wdest || wdest == any)) {
		if (wdest == any) last = reader;
		write = false;
		writec = true;
		dest = out;
		return true;
	}
	return false;
}

void Proc::end() {
	if (nwrite) {
		if (nwdest == NULL) {
			writec = true;
		} else {
			write = true;
			out = nout;
			wdest = nwdest;
		}
		nwrite = false;
	}
	if (writec) {
		pc = (pc + 1) % instrn;
		writec = false;
	}
}

Stack::Stack() : write(false) {}

bool Stack::read(int &dest, Node* reader) {
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
	if (stack.size() < 15 && left->read(i, this)) stack.push_back(i);
	if (stack.size() < 15 && right->read(i, this)) stack.push_back(i);
	if (stack.size() < 15 && up->read(i, this)) stack.push_back(i);
	if (stack.size() < 15 && down->read(i, this)) stack.push_back(i);
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

bool InStream::read(int &dest, Node* reader) {
	return fscanf(file, "%d", &dest) == 1;
}

OutStream::OutStream(FILE *file) :
	StreamNode(file),
	eof(fscanf(file, "%d", &exp) != 1),
	errors(0), complete(false) {}

void OutStream::step() {
	if (!eof && up->read(in, this)) {
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
