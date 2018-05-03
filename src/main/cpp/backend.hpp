#ifndef BACKEND_HPP
#define BACKEND_HPP

#include "puzzle.hpp"
#include "save.hpp"

void fpga_backend(const Puzzle &puzzle, const std::vector<Core*> &renum, const Core *stack);
void software_backend(const Puzzle &puzzle, const std::vector<Core*> &renum, const Core *stack);

#endif // !BACKEND_HPP
