local module = {}

local Compression = require(script.compression)
local BitBuffer = require(script.bitbuffer)

--// pre-index
local compress = Compression.Zlib.Compress
local decompress = Compression.Zlib.Decompress

local buffer = BitBuffer.new()
local isEmptyBuffer = true

local function encodeBase128(data:string)
	if not isEmptyBuffer then
		buffer:ResetBuffer()
	end
	isEmptyBuffer = false
	buffer:WriteString(data)
	return buffer:ToBase128()
end

local function decodeBase128(base128Content:string)
	local newBuffer = BitBuffer.FromBase128(base128Content)
	return newBuffer:ReadString()
end

function module.compress(data:string,level:number,strategy:"dynamic"|"fixed"|"huffman_only"):string
	local compressed = compress(data,{
		level = level or 6;
		strategy = strategy or "dynamic"
	})
	return encodeBase128(compressed)
end

function module.decompress(compressedData:string):string
	local base91Decoded = decodeBase128(compressedData)
	local decompressed = decompress(base91Decoded)
	return decompressed
end

return module