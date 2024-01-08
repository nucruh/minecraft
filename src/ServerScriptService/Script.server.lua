local b = require(game.ReplicatedStorage.BlockCompression)

local chunk = {}


local function generate_chunk_data_fake()
	for x = 1, 16 do
		for y = 1, 16 do
			local block = {x, math.random(0, 86), y, math.random(50, 120), 1}
			chunk[game:GetService('HttpService'):GenerateGUID(false)] = block			
		end
	end
end

generate_chunk_data_fake()


local final_compressed = ''
for _, block_data in chunk do
	final_compressed ..= b:compress(block_data)
end

-- control
local control = ''
for _, block_data in chunk do
	control..=('x'..block_data[1]..'y'..block_data[2]..'z'..block_data[3]..'t'..block_data[4]..'1')
end

warn(control:len())
warn(final_compressed:len())

print(game:GetService('HttpService'):JSONEncode(control):len())
print(game:GetService('HttpService'):JSONEncode(final_compressed):len())