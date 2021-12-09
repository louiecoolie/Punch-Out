-- base class for objects, based on LuaClass
-- based loosely off Container.lua 'https://github.com/SinisterRectus/Discordia/blob/master/libs/containers/abstract/Container.lua'

local HttpService = game:GetService("HttpService")

local classMain = script.Parent
local LuaClass = require(classMain)

local BaseObject, get, set = LuaClass("BaseObject")

local types = {['string'] = true, ['number'] = true, ['boolean'] = true, ['table'] = true}

local function load(self, data)
	-- assert(type(data) == 'table') -- debug
	for k, v in pairs(data) do
		if types[type(v)] then
			self['_' .. k] = v
		elseif v == LuaClass.nullRef then
			self['_' .. k] = nil
		end
	end
end

local function generateHash() -- just use guid to get an identifier, this will be used for connecting server/client objects
	return HttpService:GenerateGUID(false)
end

function BaseObject.__init(prototype, props)
    if prototype == BaseObject then
        error("Cannot instantiate abstract class: '"..prototype.__name.."'")
    else
        local new = setmetatable({}, prototype)
        load(new, props)
		if not new._id then
			new._id = generateHash()
		end
        return new
    end
end

function BaseObject:__serialize()
    -- add serializable properties here
	-- use a dictionary combiner in the future like Cryo
	local ret = {
		classType = self.__name;
		id = self._id;
	}
    return ret
end

function BaseObject:__tostring()
	return "["..self.__name.."]"
end

function BaseObject:__hash()
	return self._id
end

return BaseObject