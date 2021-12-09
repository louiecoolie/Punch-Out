--[[
    This is the GUI component of the game, this script is built of several different roact components
    which are updated when state changes.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
--modules
local util = ReplicatedStorage.Vendor
local roactRodux = require(util:WaitForChild("Roact-Rodux"))
local roact = require(util:WaitForChild("Roact"))
--animation modules
local flipper = require(util:WaitForChild("Flipper"))
local spring = flipper.Spring
--components
local components = script.Components
local context = require(components:FindFirstChild("Context"))
local gameHud = require(components:FindFirstChild("Hud"))
local gameShop = require(components:FindFirstChild("Shop"))

local BaseApp = roact.Component:extend("BaseApp")

-- rodux methods

local function mapStateToProps(state)

    return {
        open = state.playerHandler.Lobby.currentOpen;
        themeType = state.playerHandler.Theme.Current;
    }
end

local function mapDispatchToProps(dispatch)
    return {

    }
end



local TWEEN_IN_SPRING = {
    frequency = 5,
    dampingRatio = 1
}

function BaseApp:init()
    --setting placeholder parameters for the animation library to create a motor which is used for animations.
	self.motor = flipper.SingleMotor.new(0)

	local binding, setBinding = roact.createBinding(self.motor:getValue())
	self.binding = binding

	self.motor:onStep(setBinding)


end

function BaseApp:render()
    -- creating hud component which will have coins and power
    local hud = context.with(function(theme)
        return roact.createElement(gameHud, {
            theme = theme;
        })
    
    end)
    local shop = context.with(function(theme)
        return roact.createElement(gameShop, {
            theme = theme;
            serverDispatch = self.props.serverDispatch;
        })
    end)
  
    return roact.createElement(context.Provider,{
        value = self.props.themeType;
    },{
        BaseApp = roact.createElement("ScreenGui", {
            IgnoreGuiInset = true;
            ResetOnSpawn = true;
            DisplayOrder = 10;
        }, { -- children
            Hud = hud;
            Shop = shop
        })
    })
end

function BaseApp:didMount()


end

function BaseApp:willUnmount()
   
end


return roactRodux.connect(mapStateToProps, mapDispatchToProps)(BaseApp)
