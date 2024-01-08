local noise_functions = {}

local chunk_settings = require(script.Parent.ChunkSettings)

local amplitude = chunk_settings.amplitude
local frequency = chunk_settings.frequency
local octaves = chunk_settings.octaves
local lacunarity = chunk_settings.lacunarity
local persistance = chunk_settings.persistance

--local chunk_size = chunk_settings.chunk_size
--local world_size = chunk_settings.world_size

local seed = 392

print(seed)

function noise_functions.fBM(x, y)

	local noise = 0
	local amplitude = amplitude
	local frequency = frequency
	
	local x1 = x
	local y1 = y
	

	for _ = 1, octaves do
		local octave_noise = math.noise(
			x1 / frequency,
			y1 / frequency,
			seed)

		noise += octave_noise * amplitude
		
		x1 *= lacunarity
		y1 *= lacunarity
		
		amplitude *= persistance
	end

	return math.clamp(noise, -1, 1)
end

function noise_functions.perlin(x, y)
	
	return math.noise(x / 10, y / 10, seed)
	
end

return noise_functions