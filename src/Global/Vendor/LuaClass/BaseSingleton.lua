-- base class for singleton objects, based on LuaClass
-- based loosely off Container.lua 'https://github.com/SinisterRectus/Discordia/blob/master/libs/containers/abstract/Container.lua'

local classMain = script.Parent
local LuaClass = require(classMain)

local BaseSingleton, get, set = LuaClass("BaseSingleton")
BaseSingleton.__singleton = nil

local function _initSingleton(prototype, ...)
    if not prototype.__singleton then -- create singleton
        prototype.__singleton = prototype:__initSingleton(...)
    end
    return prototype.__singleton
end

local types = {['string'] = true, ['number'] = true, ['boolean'] = true}
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

function BaseSingleton.__initSingleton(prototype, props)
    local new = setmetatable({}, prototype)
    if props then
        load(new, props)
    end
    return new
end

function BaseSingleton.__init(prototype, ...)
    if prototype == BaseSingleton then
        error("Cannot instantiate abstract class: '"..prototype.__name.."'")
    else
        return _initSingleton(prototype, ...)
    end
end

return BaseSingleton