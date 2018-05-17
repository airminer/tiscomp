
function get_streams()
          --1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39
	ina =  {47, 75, 65, 81, 96, 74, 96, 62, 10, 71, 35, 86, 15, 30, 70, 50, 20, 73, 19, 10, 47, 55, 48, 62, 10, 79, 83, 29, 89, 41, 66, 22, 41, 41, 44, 63, 86, 44, 29}
	inb =  {3, 6, 3, 7, 9, 9, 2, 1, 2, 9, 7, 1, 6, 8, 1, 4, 5, 9, 3, 7, 9, 4, 3, 6, 9, 2, 7, 2, 7, 5, 9, 7, 1, 7, 6, 4, 8, 7, 1}
	
    outq = {}
    outr = {}
    for i = 1,39 do
		outq[i] = math.floor(ina[i] / inb[i])
		outr[i] = ina[i] % inb[i]
	end
    return {
		{ STREAM_INPUT, "IN.A", 1, ina },
		{ STREAM_INPUT, "IN.B", 2, inb },
		{ STREAM_OUTPUT, "OUT.Q", 1, outq },
        { STREAM_OUTPUT, "OUT.R", 2, outr },
	}
end

function get_layout()
    return {TILE_COMPUTE, TILE_COMPUTE, TILE_COMPUTE, TILE_COMPUTE,
            TILE_DAMAGED, TILE_COMPUTE, TILE_COMPUTE, TILE_DAMAGED,
            TILE_COMPUTE, TILE_COMPUTE, TILE_COMPUTE, TILE_COMPUTE}
end

