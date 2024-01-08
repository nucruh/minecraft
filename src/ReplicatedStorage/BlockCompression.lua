local compression = {}

local characters = {
	[0] = '0','1','2','3','4','5','6','7','8','9',
	'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
	'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
	'!','#','$','%','&',"'",'(',')','*','+','.','/',':',';','<','=','>','?','@','[',']','^','_','`','{','}','|','~',
}

local numbers = {['0'] = 0}
for i, character in ipairs(characters) do numbers[character] = i end

local base = #characters + 1

function compression.encode(value)
	if value == 0 then return '0' end
	local text = ''
	
	if value < 0 then text = '-'; value = -value end
	
	while value > 0 do
		text = text .. characters[value % base]
		value = value // base
	end
	
	return text
end

function compression.decode(value)
	local number = 0
	local power = 1
	
	for character in value:gmatch('.') do
		if character == '-' then
			power = -power
		else
			number += numbers[character] * power
			power *= base
		end
	end
	
	return number
end

function compression:compress(block_data)
	
	local x = block_data[1]
	local y = block_data[2]
	local z = block_data[3]
	local block_type = block_data[4]
	local bool = block_data[5] -- was it added or removed? 1 = added, 0 = removed
	
	x = compression.encode(x)
	y = compression.encode(y)
	z = compression.encode(z)
	block_type = compression.encode(block_type)
	
	local data = '  '..x..y..z..block_type
	
	if bool then
		data = data..' '..bool
	end
	
	return data
end


return compression