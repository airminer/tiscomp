#ifndef NODE_HPP
#define NODE_HPP

#include <stdio.h>
#include <string>
#include <vector>

class Node {
public:
	Node *left, *right, *up, *down;
	virtual bool read(int &dest);
	virtual void step();
	virtual void end();
};

class Core : public Node {
	bool write, nwrite;
	int out, nout;
public:
	Core();
	bool read(int &dest) override;
	void end() override;
};

class Stack : public Node {
	bool write, nwrite;
	int outp, noutp;
	std::vector<int> stack;
public:
	Stack();
	bool read(int &dest) override;
	void step() override;
	void end() override;
};

class StreamNode : public Node {
protected:
	FILE *file;
	StreamNode(FILE *file);
};

class InStream : public StreamNode {
public:
	InStream(FILE *file);
	bool read(int &dest) override;
};

class OutStream : public StreamNode {
	int in, exp;
	bool eof;
public:
	int errors;
	bool complete;
	OutStream(FILE *file);
	void step() override;
};

#endif // !NODE_HPP
