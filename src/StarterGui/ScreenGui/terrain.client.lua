--local image = Instance.new('EditableImage', script.Parent.ImageLabel)
--[[
local iris = require(game.ReplicatedStorage.Iris).Init()

local chunks = {}

local chunk_size = 16
local world_size = 512
local max_height = 85
local min_height = 1

local amplitude = 0
local frequency = 0
local octaves = 0
local lacunarity = 0
local persistance = 0
local y_multiplier = 1

local generating = false

local seed = 1

local function noise(x, y, chunk_position)
	x += chunk_position.X * chunk_size
	y += chunk_position.Y * chunk_size
	
	x /= world_size
	y /= world_size

	local noise = 0
	local amplitude = amplitude
	local frequency = frequency

	for octave = 1, octaves do
		local octave_noise = math.noise(
			x * frequency,
			y * frequency,
			seed)

		noise += octave_noise * amplitude
		frequency *= lacunarity
		amplitude *= persistance
	end

	noise = math.abs(noise)

	return noise
end

local function cull_faces(chunk)
	for _, block in chunk do
		
		local instance = block.instance
		
		local block_cframe = instance.CFrame
		
		local neighbor_results = {
			Top = workspace:Raycast(block_cframe.Position, block_cframe.UpVector * 4),
			Bottom = workspace:Raycast(block_cframe.Position, -block_cframe.UpVector * 4),
			Left = workspace:Raycast(block_cframe.Position, -block_cframe.RightVector * 4),
			Right = workspace:Raycast(block_cframe.Position, block_cframe.RightVector * 4),
			Front = workspace:Raycast(block_cframe.Position, block_cframe.LookVector * 4),
			Back = workspace:Raycast(block_cframe.Position, -block_cframe.LookVector * 4)
		}
		
		for direction, ray_result in ray_results do
			
			if ray_result then
				if not instance:FindFirstChild(direction) then continue end
				
				instance[direction].Transparency = 1
			else
				if not instance:FindFirstChild(direction) then continue end
				
				instance[direction].Transparency = 0
			end
		end
		
		
	end
end

local function generate_chunk(chunk_position)
	local id = chunk_position.X..':'..chunk_position.Y
	
	local skipper = 0
	
	local new_chunk = {}
	
	local block_id_tracker = 0
	
	for i = 1, chunk_size^2 do
		
		if not generating then break end

		if skipper > 500 then
			task.wait()
			skipper = 0
		end

		skipper +=1

		local x = ((i - 1) % chunk_size) + 1
		local y = math.floor((i - 1) / chunk_size) + 1

		local noise_value = noise(x, y, chunk_position)
		
		for y = max_height, min_height, -1 do
			
			local density = math.noise(x, y, noise_value / 20)
			local squish_factor = 30
			
			local density_modifier = (noise_value - y) / squish_factor
			
			
			density += density_modifier
			
			if density > 0 then
				local chunk_offset = Vector3.new(chunk_position.X * chunk_size, 0, chunk_position.Y * chunk_size) * 3
				
				local block = game.ReplicatedStorage.Blocks.grass_block:Clone()
				block.Position = Vector3.new(x * 3, (noise_value * y_multiplier // 3) * 3, y * 3) + chunk_offset
				block.Parent = workspace
				
				local block_chunk_id = tostring(block_id_tracker + 1)
				block_id_tracker += 1

				block:SetAttribute('chunk_id', block_chunk_id)

				new_chunk[block_chunk_id] = {instance = block, name = 'grass_block'}
				
			end
			
		end
		
		
		
		--[[
		local chunk_offset = Vector3.new(chunk_position.X * chunk_size, 0, chunk_position.Y * chunk_size) * 3
		
		local block_chunk_id = tostring(block_id_tracker + 1)
		block_id_tracker += 1
		
		local block = game.ReplicatedStorage.Blocks.grass_block:Clone()
		block.Position = Vector3.new(x * 3, (noise_value * y_multiplier // 3) * 3, y * 3) + chunk_offset
		block.Parent = workspace
		
		block:SetAttribute('chunk_id', block_chunk_id)
		
		new_chunk[block_chunk_id] = {instance = block, name = 'grass_block'}
		
		local value = math.random(100)
		
		if value < 25 then
			local short_grass = game.ReplicatedStorage.Blocks.short_grass:Clone()
			short_grass.Position = block.Position + Vector3.new(0, 2.5, 0)
			short_grass.Parent = workspace
			
			new_chunk[block_chunk_id..'short_grass'] = {instance = short_grass, name = 'short_grass'}
			
			continue
		end
		
		if value > 25 and value < 30 then
			local poppy = game.ReplicatedStorage.Blocks.poppy:Clone()
			poppy.Position = block.Position + Vector3.new(0, 1.5, 0)
			poppy.Parent = workspace
			new_chunk[block_chunk_id..'poppy'] = {instance = poppy, name = 'poppy'}
			
			continue
		end
		
		if value > 95 then
			local dandelion = game.ReplicatedStorage.Blocks.dandelion:Clone()
			dandelion.Position = block.Position + Vector3.new(0, 1.5, 0)
			dandelion.Parent = workspace
			new_chunk[block_chunk_id..'dandelion'] = {instance = dandelion, name = 'dandelion'}
			
			continue
		end
		--
		
	end
	
	chunks[id] = new_chunk
	
	
	cull_faces(new_chunk)
end

local function unload_chunk(chunk_id)
	
	for _, item in chunks[chunk_id] do
		item.instance:Destroy()
		
	end
	
end

iris:Connect(function()
	--iris.ShowDemoWindow()

	iris.Window({'Paramaters'})

	amplitude = iris.InputNum({'Amplitude', .1, 0.2, 10}).state.number.value
	frequency = iris.InputNum({'Frequency', 0.001, 0.001, 20}).state.number.value
	octaves = iris.InputNum({'Octaves', 1, 1, 10}).state.number.value
	lacunarity = iris.InputNum({'Lacunarity', 0.00001, 1, 10}).state.number.value
	persistance = iris.InputNum({'Persistance', 0.001, 0, 1}).state.number.value
	seed = iris.InputNum({'Seed'}).state.number.value
	y_multiplier = iris.SliderNum({'Y Multiplier', 0.1, 1, 100}).state.number.value

	iris.Indent({})
	
	local logged_generating = generating
	generating = iris.Checkbox({'Generate'}).state.isChecked.value
	
	if generating and not logged_generating then
		generate_chunk({X = 1, Y = 1})
		generate_chunk({X = 2, Y = 1})
		generate_chunk({X = 1, Y = 2})
		generate_chunk({X = 2, Y = 2})
	elseif logged_generating and not generating then
		unload_chunk('1:1')
		unload_chunk('2:1')
		unload_chunk('1:2')
		unload_chunk('2:2')
	end
	
	iris.End()

	iris.End()
end)

--[[task.spawn(function()

	while true do
		
		
		image.Size = Vector2.new(script.Parent.ImageLabel.Size.X.Offset, script.Parent.ImageLabel.Size.Y.Offset)
		
		if pixels == {} then
			pixels = table.create(image.Size.X * image.Size.Y * 4, 1)
		end
		
		local skipper = 0
		for i = 1, image.Size.X * image.Size.Y do

			if skipper > 25000 then
				task.wait()
				skipper = 0
			end

			skipper +=1

			local pixelIndex = 1 + ((i - 1) * 4)

			local x = ((i - 1) % image.Size.X) + 1
			local y = math.floor((i - 1) / image.Size.X) + 1

			local noise_value = noise(x, y)

			-- RGBO -> Red, Green, Blue, Opacity

			if noise_value < 0.33 and noise_value > 0.3 then

				pixels[pixelIndex] = sand_color.R
				pixels[pixelIndex + 1] = sand_color.G
				pixels[pixelIndex + 2] = sand_color.B

				pixels[pixelIndex + 3] = 1
				continue
			end

			if noise_value < 0.3 then

				pixels[pixelIndex] = sea_color.R
				pixels[pixelIndex + 1] = sea_color.G
				pixels[pixelIndex + 2] = sea_color.B

				pixels[pixelIndex + 3] = 1
				continue
			end

			if noise_value > 0.3 and noise_value < 0.72 then

				pixels[pixelIndex] = land_color.R
				pixels[pixelIndex + 1] = land_color.G
				pixels[pixelIndex + 2] = land_color.B

				pixels[pixelIndex + 3] = 1
				continue
			end

			if noise_value > 0.72 and noise_value < 0.87 then

				pixels[pixelIndex] = rock_color.R
				pixels[pixelIndex + 1] = rock_color.G
				pixels[pixelIndex + 2] = rock_color.B

				pixels[pixelIndex + 3] = 1
				continue
			end

			if noise_value > 0.87 then
				pixels[pixelIndex] = snow_color.R
				pixels[pixelIndex + 1] = snow_color.G
				pixels[pixelIndex + 2] = snow_color.B

				pixels[pixelIndex + 3] = 1
				continue
			end

		end

		image:WritePixels(Vector2.new(0, 0), image.Size, pixels)

		task.wait(.25)
	end
end)
]]