--[[
    This component will build out the coins and power display to end user.
]]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--modules
local util = ReplicatedStorage.Vendor
local roactRodux = require(util:WaitForChild("Roact-Rodux"))
local roact = require(util:WaitForChild("Roact"))
--animation modules
local flipper = require(util:WaitForChild("Flipper"))
local spring = flipper.Spring

local Hud = roact.Component:extend("Hud")

--animation spring parameters
local TWEEN_IN_SPRING = {
    frequency = 5,
    dampingRatio = 1
}
-- acquire state to supply to app components
local function mapStateToProps(state)
    return {
        coins = state.playerHandler.Profile.coins;
        power = state.playerHandler.Profile.power
    }
end

local function mapDispatchToProps(dispatch)
    return {

    }
end

function Hud:render()
    local theme = self.props.theme;
    -- return component structure to mount in main app
    return roact.createElement("Frame",{
        Size = UDim2.fromScale(1,1),
        BackgroundTransparency = 1,
    },{
        --create the coin display
        Coins = roact.createElement("Frame",{
            Size = UDim2.fromScale(0.1,0.1);
            Position = UDim2.fromScale(0.01,0.5);
            BackgroundColor3 = theme.background;
        },{
            UIListLayout = roact.createElement("UIListLayout",{
                HorizontalAlignment = Enum.HorizontalAlignment.Center;
                VerticalAlignment = Enum.VerticalAlignment.Center;
                FillDirection = Enum.FillDirection.Horizontal;
            }),
            UICorner = roact.createElement("UICorner",{
                CornerRadius = UDim.new(.5,0);
            }),
            Description = roact.createElement("TextLabel",{
                Text = "Coins: ";
                Size = UDim2.fromScale(0.4,1);
                BackgroundTransparency = 1;
                TextColor3 = theme.text;
                Font = theme.font;
                TextScaled = true;

            }),
            Value = roact.createElement("Frame",{
                Size = UDim2.fromScale(0.3,.7);
                BackgroundColor3 = theme.option
            },{
                UICorner = roact.createElement("UICorner",{
                    CornerRadius = UDim.new(.5,0);
                }),
                UIListLayout = roact.createElement("UIListLayout",{
                    HorizontalAlignment = Enum.HorizontalAlignment.Center;
                    VerticalAlignment = Enum.VerticalAlignment.Center;
                    FillDirection = Enum.FillDirection.Horizontal;
                }),
                Description = roact.createElement("TextLabel",{
                    Text = self.props.coins;
                    Size = UDim2.fromScale(0.5,1);
                    BackgroundTransparency = 1;
                    TextColor3 = theme.text;
                    Font = theme.font;
                    TextScaled = true;
                }),
            })
        }),
        --create the power display
        Power = roact.createElement("Frame",{
            Size = UDim2.fromScale(0.1,0.1);
            Position = UDim2.fromScale(0.01,0.39);
            BackgroundColor3 = Color3.fromRGB(184, 92, 92);
        },{
            UIListLayout = roact.createElement("UIListLayout",{
                HorizontalAlignment = Enum.HorizontalAlignment.Center;
                VerticalAlignment = Enum.VerticalAlignment.Center;
                FillDirection = Enum.FillDirection.Horizontal;
            }),
            UICorner = roact.createElement("UICorner",{
                CornerRadius = UDim.new(.5,0);
            }),
            Description = roact.createElement("TextLabel",{
                Text = "Power: ";
                Size = UDim2.fromScale(0.4,1);
                BackgroundTransparency = 1;
                TextColor3 = theme.text;
                Font = theme.font;
                TextScaled = true;

            }),
            Value = roact.createElement("Frame",{
                Size = UDim2.fromScale(0.3,.7);
                BackgroundColor3 = theme.option
            },{
                UICorner = roact.createElement("UICorner",{
                    CornerRadius = UDim.new(.5,0);
                }),
                UIListLayout = roact.createElement("UIListLayout",{
                    HorizontalAlignment = Enum.HorizontalAlignment.Center;
                    VerticalAlignment = Enum.VerticalAlignment.Center;
                    FillDirection = Enum.FillDirection.Horizontal;
                }),
                Description = roact.createElement("TextLabel",{
                    Text = self.props.power;
                    Size = UDim2.fromScale(0.5,1);
                    BackgroundTransparency = 1;
                    TextColor3 = theme.text;
                    Font = theme.font;
                    TextScaled = true;
                }),
            })
        }),
        --create the controls display
        ControlDisplay = roact.createElement("TextButton",{
            Size = UDim2.fromScale(0.1,0.1);
            Position = UDim2.fromScale(0.45,0.9);
            BackgroundColor3 = theme.text;
            Text = ""
        },{
            UIListLayout = roact.createElement("UIListLayout",{
                HorizontalAlignment = Enum.HorizontalAlignment.Center;
                VerticalAlignment = Enum.VerticalAlignment.Center;
                SortOrder = Enum.SortOrder.LayoutOrder;
                FillDirection = Enum.FillDirection.Horizontal;
            }),
            UICorner = roact.createElement("UICorner",{
                CornerRadius = UDim.new(.5,0);
            }),
            PunchIcon = roact.createElement("ImageLabel",{
                Image = "rbxassetid://8206948623";
                Size = UDim2.fromScale(0.4,1);
                BackgroundTransparency = 1;
                LayoutOrder = 1;
            }),

            MouseIcon = roact.createElement("ImageLabel",{
                Image = "rbxassetid://8206975547";
                Size = UDim2.fromScale(0.4,1);
                BackgroundTransparency = 1;
                LayoutOrder = 2;
            }),
        })
    })

end
--using roactrodux to connect this part of the ui to state. changes to state will update the ui.
return roactRodux.connect(mapStateToProps, mapDispatchToProps)(Hud)





