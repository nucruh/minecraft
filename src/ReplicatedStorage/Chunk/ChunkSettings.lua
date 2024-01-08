return {
	chunk_size = 16, -- self explanatory
	world_size = 512, -- not used
	
	max_height = 32, -- gives better results if similar or same to min_height but abs()
	min_height = -32, -- gives better results if negative

	amplitude = 1, -- general amplitude, NOT used currently
	frequency = 150, -- "granularity"
	octaves = 2, -- how many times to apply noise
	lacunarity = 3, -- frequency increase per octave
	persistance = .35, -- how much amplitude remains after each octave
	squish = 60, -- higher value -> more "swiss cheese" like terrain, lower value -> more flattened out terrain
	
	y_multiplier = 1, -- not used
}