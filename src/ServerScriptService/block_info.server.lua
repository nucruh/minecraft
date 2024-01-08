local x0 = 8
local x1 = 15
local x2 = 127

function to_binary(n, precision)
	local binary = ''
	
	precision = precision or 0
	
	while n > 0 do
		binary = (n % 2)..binary
		n = n // 2
	end
	
	while #binary < precision do
		binary = '0'..binary
	end
	
	return binary
end

function to_number(n)
	local x = 0
	local power = #n - 1
	
	for i = 1, #n do
		local d = tonumber(string.sub(n, i, i))
		x += d * (2 ^ power)
		power -= 1
	end
	
	return x
end

function pad_binary(n, pad)
	
	while #n < pad do
		n = '0'..n
	end
	
	return n
end

local numberized = to_number(to_binary(x0, 6)..to_binary(x1, 4)..to_binary(x2, 7))
local converted_back = pad_binary(to_binary(numberized), 17)

local a, b, c = string.sub(converted_back, 1, 6), string.sub(converted_back, 7, 10), string.sub(converted_back, 11, 17)

print(to_number(a))
print(to_number(b))
print(to_number(c))