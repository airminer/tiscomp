#ifndef NODE_HPP
#define NODE_HPP

#include <stdio.h>
#include <string>
#include <vector>

class Node {
public:
	Node *left, *right, *up, *down;
	virtual bool read(int &dest, Node *reader);
	virtual void step();
	virtual void end();
};

class Proc : public Node {
protected:
	bool write, nwrite, writec;
	Node *wdest, *nwdest, *last;
	int out, nout, acc, bak;
	int pc, instrn;
	void swp();
	bool readFrom(int &dest, Node *source);
	void add(const int i);
	void sub(const int i);
	void jro(const int i);
	void mov(const int i, Node* target);
public:
	Proc(int instrn);
	bool read(int &dest, Node* reader) override;
	void end() override;
};

class Stack : public Node {
	bool write, nwrite;
	int outp, noutp;
	std::vector<int> stack;
public:
	Stack();
	bool read(int &dest, Node* reader) override;
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
	bool read(int &dest, Node* reader) override;
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
