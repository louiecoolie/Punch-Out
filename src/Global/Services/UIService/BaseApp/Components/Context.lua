

-- used for theme

local ReplicatedStorage = game:GetService("ReplicatedStorage")

--modules
local util = ReplicatedStorage.Vendor




-- get roact/rodux
local roact = require(util:WaitForChild("Roact"))
local roactRodux = require(util:WaitForChild("Roact-Rodux"))

local function mapStateToProps(state)
    return {
        themeType = state.playerHandler.Theme.Current;
    }
end

local function mapDispatchToProps(dispatch)
    return {
        
    }
end

local themes = {
    lightTheme = {
        background = Color3.fromRGB(255, 255, 255),
        section = Color3.fromRGB(144, 147, 151),
        option = Color3.fromRGB(135, 139, 142),
        text = Color3.fromRGB(0,0,0),
        border = Color3.fromRGB(100,100,100),
        font = Enum.Font.Gotham;
 
    },
    darkTheme = {
        background = Color3.fromRGB(0, 0, 0),
        section = Color3.fromRGB(44, 47, 51),
        option = Color3.fromRGB(35, 39, 42),
        text = Color3.fromRGB(255,255,255),
        border = Color3.fromRGB(200,200,200),
        font = Enum.Font.GothamSemibold;
    }
}

local loadoutAppContext = roact.createContext({})
local loadoutContextWrapper = roact.Component:extend("loadoutContextWrapper")

function loadoutContextWrapper:init()
  
    self:setState({
        theme = themes[self.props.themeType]
    })
end

function loadoutContextWrapper:render()
   
    return roact.createElement(loadoutAppContext.Provider, {
        value = themes[self.props.themeType],
    }, self.props[roact.Children])
end


local function with(callback)
	return roact.createElement(loadoutAppContext.Consumer, {
		render = callback,
	})
end


return {
	Provider = roactRodux.connect(mapStateToProps, mapDispatchToProps)(loadoutContextWrapper),
	Consumer = loadoutAppContext.Consumer,
	with = with,
}