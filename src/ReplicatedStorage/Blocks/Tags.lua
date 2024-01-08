--[[

#decoration_spawnable -> can spawn terrain decorations on top
#animal_spawnable -> animals can spawn on top
#burns -> lights on fire
#no_cull -> won't solve for culling
#flower -> a flower
#requires_support -> will break if the block beneath doesn't exist anymore
#terrain_decoration -> will spawn on #decoration_spawnable and will adjust for not being a 3x3x3
#grass_spreadable -> grass can spread to it
#not_full -> makes the object adjust for its size when spawning

--]]

return {
	
	grass_block = {'decoration_spawnable', 'animal_spawnable'},
	stone = {},
	dirt = {'grass_spreadable'},
	oak_log = {'burns'},
	oak_leaves = {},
	short_grass = {'no_cull', 'requires_support','terrain_decoration', 'not_full'},
	poppy = {'no_cull', 'flower', 'requires_support', 'terrain_decoration', 'not_full'},
	dandelion = {'no_cull', 'flower', 'requires_support', 'terrain_decoration', 'not_full'},
}