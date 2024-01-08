local renderer = {}

local replicated_storage = game:GetService('ReplicatedStorage')

local chunk_settings = require(script.Parent.ChunkSettings)
local tags = require(replicated_storage.Blocks.Tags)

local chunk_size = chunk_settings.chunk_size
local blocks = replicated_storage.Blocks

--[[local vector_directions = {
	[Vector3.new(1, 0, 0)] = 'Right',
	[Vector3.new(-1, 0, 0)] = 'Left',
	[Vector3.new(0, 0, 1)] = 'Back',
	[Vector3.new(0, 0, -1)] = 'Front',
	[Vector3.new(0, 1, 0)] = 'Top',
	[Vector3.new(0, -1, 0)] = 'Bottom'
}]]

local timer_n = 0
local function timer()
	timer_n+=1
	if timer_n > 25000 then timer_n = 0; task.wait() end
end

function renderer:cull_all()
	for chunk_position, chunks in _G.game_chunks do

		-- put this up here so it doesn't get it for every single block
		local split_chunk = string.split(chunk_position, ' ')
		local chunk_x, chunk_z = split_chunk[1], split_chunk[2]

		for block_position, block_data in chunks do
			timer()

			if table.find(tags[block_data[1]], 'no_cull') then continue end

			
			local split = string.split(block_position, ' ')
			local x, y, z = split[1], split[2], split[3]
			
			-- chunk offsets
			
			-- real world positions, y is already real world
			x = (chunk_x * chunk_size + x)
			z = (chunk_z * chunk_size + z)
			
			local adjacent_blocks = {
				[Vector3.new(x+1, y, z)] = 'Right',
				[Vector3.new(x-1, y, z)] = 'Left',
				[Vector3.new(x, y, z+1)] = 'Back',
				[Vector3.new(x, y, z-1)] = 'Front',
				[Vector3.new(x, y+1, z)] = 'Top',
				[Vector3.new(x, y-1, z)] = 'Bottom'
			}

			local occupied_faces = {}

			-- loop thru all the sorrounding positions that might contain blocks
			for adjacent_position, face in adjacent_blocks do

				local adj_chunk_x = (adjacent_position.X - 1) // chunk_size
				local adj_chunk_z = (adjacent_position.Z - 1) // chunk_size
				local chunk = adj_chunk_x ..' '.. adj_chunk_z

				-- can't find the actual chunk? -> continue (happens if the chunk next to it isn't there YET)
				if not _G.game_chunks[chunk] then continue end


				local block_x = (adjacent_position.X - 1) % chunk_size + 1
				local block_z = (adjacent_position.Z - 1) % chunk_size + 1
				local chunk_block_position = block_x ..' '..(adjacent_position.Y)..' '.. block_z
				
				local block_at_position = _G.game_chunks[chunk][chunk_block_position]

				if block_at_position then
					if table.find(tags[block_at_position[1]], 'no_cull') then continue end
					table.insert(occupied_faces, face)
				end

			end
			
			local total_occupied_faces = 0
			
			for _, face in occupied_faces do
				
				-- insert result into the table of hidden faces
				table.insert(_G.game_chunks[chunk_position][block_position][3], face)
				total_occupied_faces += 1
			end
			
			-- make it not even appear
			if total_occupied_faces == 6 then
				_G.game_chunks[chunk_position][block_position][2] = false -- is displayed? -> false
				_G.game_chunks[chunk_position][block_position][3] = {} -- clear up memory
			end
			
		end
	end
end

function renderer:render_chunk(chunk_data, chunk_x, chunk_z)
	
	-- init chunk
	local chunk_offset = Vector3.new(chunk_x, 0, chunk_z) * chunk_size
	
	local chunk_folder = Instance.new('Folder')
	chunk_folder.Name = chunk_x.. ' ' ..chunk_z
	
	for position, block_data in chunk_data do
		
		-- if you can't see it -> continue
		if not block_data[2] then continue end
		
		local split = string.split(position, ' ')
		local x, y, z = split[1], split[2], split[3]
		
		-- clone and init block
		local block_model = blocks:FindFirstChild(block_data[1]):Clone()
		block_model.Position = (Vector3.new(x, y, z) + chunk_offset) * 3
		block_model.Name = block_model.Name ..'@'.. x ..' '.. y ..' '.. z

		if table.find(tags[block_data[1]], 'not_full') then
			--should maybe offset by -(half_block_size - half_object_size?)
			block_model.Position = block_model.Position - (Vector3.new(0, 1.5 - block_model.Size.Y / 2, 0))
		end
		
		-- if there is no occluded faces table -> continue
		if not block_data[3] then block_model.Parent = chunk_folder; continue end

		for _, face in block_data[3] do
			if not block_model:FindFirstChild(face) then continue end
			block_model[face]:Destroy()
		end

		block_model.Parent = chunk_folder
		
	end
	
	
	chunk_folder.Parent = workspace.Chunks
	
end


return renderer