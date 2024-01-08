local generator = {}

local replicated_storage = game:GetService('ReplicatedStorage')

local chunk_settings = require(script.ChunkSettings)
local noise_functions = require(script.NoiseFunctions)
local renderer = require(script.Renderer)
local tags = require(replicated_storage.Blocks.Tags)
local prefabs = require(script.Prefabs)

local chunk_size = chunk_settings.chunk_size
local max_height = chunk_settings.max_height
local min_height = chunk_settings.min_height


function generator:make_decorations(chunk_data, chunk_position)

	local chunk_split = string.split(chunk_position, ' ')
	local offset_x, offset_z = chunk_split[1] * chunk_size, chunk_split[2] * chunk_size

	for position, spawn_block_data in chunk_data do

		local block_name = spawn_block_data[1]

		if not table.find(tags[block_name], 'decoration_spawnable') then continue end

		local split = string.split(position, ' ')
		local x, y, z = split[1], split[2], split[3]
		
		local above_1 = x..' '..(y + 1)..' '..z

		if chunk_data[above_1] then continue end


		-- multiplicator = "frequency"
		local decoration_noise = noise_functions.fBM((x + offset_x) * 128, (z + offset_z) * 128)


		-- currently these values are pretty randomly dispersed, needs to be fine tuned
		if decoration_noise < 0.01 then
			_G.game_chunks[chunk_position][above_1] = {'short_grass', true}
			continue
		end

		if decoration_noise < 0.05 then
			_G.game_chunks[chunk_position][above_1] = {'poppy', true}
			continue
		end	

		if decoration_noise < 0.07 then
			_G.game_chunks[chunk_position][above_1] = {'dandelion', true}
			continue
		end
	end

end

function generator:make_prefabs(chunk_data, chunk_position)

	local chunk_split = string.split(chunk_position, ' ')
	local offset_x, offset_z = chunk_split[1] * chunk_size, chunk_split[2] * chunk_size
	print(offset_x, offset_z)

	for position, spawn_block_data in chunk_data do
		
		local block_name = spawn_block_data[1]

		if not table.find(tags[block_name], 'decoration_spawnable') then continue end

		local split = string.split(position, ' ')
		local x, y, z = split[1], split[2], split[3]

		local prefab_noise = noise_functions.fBM((x + offset_x) * 32, (z + offset_z) * 32)

		local oak_add_list = {}

		-- oak tree

		-- should move on to a better functional system with just being; add_prefab(prefab_info, position, ...)
		if prefab_noise > .4 then
			local oak_tree_prefab = string.split(prefabs['oak_tree'], ';')
			
			for _, block_info in oak_tree_prefab do
				local position_name = string.split(block_info, ':')
				local position_ = string.split(position_name[1], ',')
				local name = position_name[2]

				--local world_block_position = offset_x * chunk_size + position_[1] ..' '.. position_[2] ..' '.. offset_z * chunk_size + position_[3]

				local decided_chunk_x = (position_[1] + x + offset_x - 1) // chunk_size
				local decided_chunk_z = (position_[3] + z + offset_z - 1) // chunk_size
				local decided_chunk = decided_chunk_x ..' '.. decided_chunk_z
				
				if not _G.game_chunks[decided_chunk] then continue end

				local block_x = (position_[1] + x + offset_x - 1) % chunk_size + 1
				local block_z = (position_[3] + z + offset_z - 1) % chunk_size + 1
				
				local chunk_block_position = block_x ..' '.. (position_[2] + y + 1)..' '.. block_z
				local block_at_position = _G.game_chunks[decided_chunk][chunk_block_position]

				if block_at_position then oak_add_list = {}; break end

				oak_add_list[chunk_block_position] = {name, true, {}, decided_chunk}

			end
		end

		for i, v in oak_add_list do
			_G.game_chunks[v[4]][i] = {v[1], v[2], v[3]}
		end

	end
end

function generator:apply_surface_blocks(chunk_data, chunk_position)
	for position, _ in chunk_data do

		if _G.game_chunks[chunk_position][position][1] ~= 'stone' then continue end

		local split = string.split(position, ' ')
		local x, y, z = split[1], split[2], split[3]
		
		local above_1 = x..' '..(y + 1)..' '..z
		local above_2 = x..' '..(y + 2)..' '..z
		local above_3 = x..' '..(y + 3)..' '..z
		
		-- check if the above 3 blocks are filled with something
		if chunk_data[above_1] then continue end
		if chunk_data[above_2] then continue end
		if chunk_data[above_3] then continue end
		
		-- if not, change it to grass
		_G.game_chunks[chunk_position][position] = {'grass_block', true, {}}
		
		-- change bottom 3 blocks to dirt if possible
		
		local below_1 = x..' '..(y - 1)..' '..z
		local below_2 = x..' '..(y - 2)..' '..z
		local below_3 = x..' '..(y - 3)..' '..z
		
		-- add 3 blocks of dirt below
		if below_1 and (y - 1 >= chunk_settings.min_height) then
			_G.game_chunks[chunk_position][below_1] = {'dirt', true, {}}
		end
		
		if below_2 and (y - 2 >= chunk_settings.min_height) then
			_G.game_chunks[chunk_position][below_2] = {'dirt', true, {}}
		end
		
		if below_3 and (y - 3 >= chunk_settings.min_height) then
			_G.game_chunks[chunk_position][below_3] = {'dirt', true, {}}
		end

	end
	
	return chunk_data
end

function generator:generate_chunk(chunk_x, chunk_z)
	
	local chunk_data = {}
	
	for x = 1, chunk_size do
		
		local world_x = chunk_x * chunk_size + x
		
		for z = 1, chunk_size do
			
			local world_z = chunk_z * chunk_size + z
			
			local base_height = math.floor(
				noise_functions.fBM(x, z)
			) * max_height / 2
			
			
			for y = max_height, min_height, -1 do
				
				local density = math.noise(world_x / 20, world_z / 20, y / 20)
				
				local squish = chunk_settings.squish

				-- should y level increase the squish more? not sure, i think so?
				
				local density_modifier = (base_height - y) / squish
				
				density += density_modifier
				
				if density > 0 then
					chunk_data[x..' '..y..' '..z] = {'stone', true, {}}
				end
				
			end
		end
	end
	
	return chunk_data
end

function generator:render_in_chunk(chunk_data, chunk_x, chunk_z)
	renderer:render_chunk(chunk_data, chunk_x, chunk_z)
end

function generator:cull_all_faces()
	renderer:cull_all()
end

return generator