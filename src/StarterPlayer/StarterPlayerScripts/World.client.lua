local replicated_storage = game:GetService('ReplicatedStorage')

local chunk = require(replicated_storage.Chunk)
local mining = require(replicated_storage.Mining)

mining.start()

_G.game_chunks = {}

for x = 0, 1 do
	for z = 0, 1 do
		
		_G.game_chunks[x ..' '.. z] = chunk:generate_chunk(x, z)
		
	end
end

--[[

THIS DOES NOT WORK FOR PREFABS SINCE IT DOES IT ALL ONE BY ONE CHUNK
AND PREFABS DONT ACCOUNT FOR UNGENERATED CHUNKS

for position, chunk_data in _G.game_chunks do
	chunk:apply_surface_blocks(chunk_data, position)
	chunk:make_decorations(chunk_data, position)
	chunk:make_prefabs(chunk_data, position)
	chunk:cull_all_faces()

	local split = string.split(position, ' ')
	chunk:render_in_chunk(_G.game_chunks[position], split[1], split[2])
end
--]]

-- ADD A CLEAR CHUNKS FUNCTION FOR DEBUGGING, WILL ONLY REMOVE 1 BLOCK AND NOT WHOLE
-- CHUNK AT A TIME.

for position, chunk_data in _G.game_chunks do
	chunk:apply_surface_blocks(chunk_data, position)
end

for position, chunk_data in _G.game_chunks do
	chunk:make_decorations(chunk_data, position)
end

for position, chunk_data in _G.game_chunks do
	chunk:make_prefabs(chunk_data, position)
end

for position, chunk_data in _G.game_chunks do
	chunk:cull_all_faces()
end

for position, chunk_data in _G.game_chunks do
	local split = string.split(position, ' ')
	chunk:render_in_chunk(_G.game_chunks[position], split[1], split[2])
end

_G.game_chunks[-1 ..' '.. 0] = chunk:generate_chunk(-1, 0)
chunk:cull_all_faces()
chunk:render_in_chunk(_G.game_chunks[-1 ..' '.. 0], -1, 0)