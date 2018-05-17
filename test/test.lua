--[[local s=""
for k,v in pairs(_G) do
  s = s..k.."\n"
end
print(s)]]

function get_layout()
    return {TILE_COMPUTE, TILE_COMPUTE, TILE_DAMAGED, TILE_JOURNAL,
            TILE_COMPUTE, TILE_COMPUTE, TILE_COMPUTE, TILE_COMPUTE,
            TILE_COMPUTE, TILE_COMPUTE, TILE_COMPUTE, TILE_COMPUTE}
end

