#ifndef PUZZLE_HPP
#define PUZZLE_HPP

#include <vector>

enum TIS_TILE {
	TILE_COMPUTE = 1000,
	TILE_MEMORY = 1001,
	TILE_DAMAGED = 1002,
	TILE_JOURNAL = 1003
};

enum TIS_STREAM {
	STREAM_INPUT = 2000,
	STREAM_OUTPUT = 2001,
	STREAM_IMAGE = 2002
};

struct Stream {
	int type;
	std::vector<int> data;
	Stream(const int);
};

struct Puzzle {
	std::vector<int> compute;
	std::vector<int> memory;
	std::vector<Stream> inStreams;
	std::vector<Stream> outStreams;
	Puzzle();
};

Puzzle puzzle_parser(const char* file);

#endif // !PUZZLE_HPP
