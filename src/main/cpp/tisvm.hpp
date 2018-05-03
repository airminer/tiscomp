#ifndef TISVM_HPP
#define TISVM_HPP
#include "node.hpp"

void init_array();
void insert_node(const int i, Node *n);
void insert_inStream(const int i, InStream *s);
void insert_outStream(const int i, OutStream *s);
void run();

#endif // !TISVM_HPP
