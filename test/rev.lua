
function get_streams()
            --1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39
	input =  {1, 2, 3, 4, 0, 5, 6, 7, 8, 9, 0, 7, 0, 8, 9, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 3, 0, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0}
	output = {4, 3, 2, 1, 0, 9, 8, 7, 6, 5, 0, 7, 0, 9, 8, 0, 0, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0, 3, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0}
    return {
		{ STREAM_INPUT, "IN.A", 1, input },
		{ STREAM_OUTPUT, "OUT.A", 2, output },
	}
end

function get_layout()
    return {TILE_COMPUTE, TILE_COMPUTE, TILE_COMPUTE, TILE_COMPUTE,
            TILE_MEMORY, TILE_COMPUTE, TILE_COMPUTE, TILE_COMPUTE,
            TILE_COMPUTE, TILE_COMPUTE, TILE_COMPUTE, TILE_COMPUTE}
end

