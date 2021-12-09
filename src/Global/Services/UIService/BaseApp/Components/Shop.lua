--[[
    User facing component shop that will take in input and submit requests to the server for purchases as well
    as calculate the costs to user
]]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--modules
local util = ReplicatedStorage.Vendor
local roactRodux = require(util:WaitForChild("Roact-Rodux"))
local roact = require(util:WaitForChild("Roact"))
--animation modules
local flipper = require(util:WaitForChild("Flipper"))
local spring = flipper.Spring

local Shop = roact.Component:extend("Shop")
--animations
local TWEEN_IN_SPRING = {
    frequency = 5,
    dampingRatio = 1
}

local function mapStateToProps(state)
    return {
        appTheme = state.playerHandler.Theme.Current; 
        shopEnabled = state.playerHandler.Shop;
        coins = state.playerHandler.Profile.coins;
        power = state.playerHandler.Profile.power;
        powerLevel = state.playerHandler.Profile.powerLevel;
    }
end

local function mapDispatchToProps(dispatch)
    return {
    }
end

-- component methods
--this will calculate the cost of an upgrade based on player level
local function calculateCost(powerLevel)
    local result = (0.2*math.exp(powerLevel)) * 10
    return math.floor(result)
end
-- calculates power gained based on powerlevel
local function calculatePower(powerLevel)
    local result = (0.37*math.exp(powerLevel)) * 10
    return math.floor(result)
end

function Shop:render()
   
    local theme = self.props.theme;


    -- this will create a rounded frame with a button to purchase and button to close with some text labels to give context to the interface
    return roact.createElement("Frame",{
        Size = UDim2.fromScale(0.4,0.4);
        Position = UDim2.fromScale(0.3,0.3);
        BackgroundTransparency = 0;
        BackgroundColor3 = Color3.fromRGB(167, 78, 62);
        Visible = self.props.shopEnabled;
    },{
        UICorner = roact.createElement("UICorner",{
            CornerRadius = UDim.new(.1,0);
        }),
        Title = roact.createElement("TextLabel",{
            Size = UDim2.fromScale(0.5,0.1);
            Position = UDim2.fromScale(0.05,0.05);
            Text = "Upgrades";
            TextScaled = true;
            Font = theme.font;
            TextColor3 = theme.text;
            BackgroundTransparency = 1;
        });
        -- this defines the close button element
        Close = roact.createElement("TextButton",{
            Size = UDim2.fromScale(0.1,0.1);
            Position = UDim2.fromScale(0.85,0.05);
            BackgroundColor3 = theme.background;
            Text = "";
            [roact.Event.Activated] = function() -- when button is pressed send server request to toggle shop
                self.props.serverDispatch:FireServer({
                    type = "Shop"
                })

            end,
        },{
            UICorner = roact.createElement("UICorner",{
                CornerRadius = UDim.new(.5,0);
            }),
            UIListLayout = roact.createElement("UIListLayout",{
                HorizontalAlignment = Enum.HorizontalAlignment.Center;
                VerticalAlignment = Enum.VerticalAlignment.Center;
                SortOrder = Enum.SortOrder.LayoutOrder;
                FillDirection = Enum.FillDirection.Horizontal;
            }),
            Description = roact.createElement("TextLabel",{
                Text = "X";
                Size = UDim2.fromScale(1,1);
                BackgroundTransparency = 1;
                TextColor3 = theme.text;
                Font = theme.font;
                TextScaled = true;

            })
        }),
        --this defines the cost description for upgrade
        CostPower = roact.createElement("TextLabel",{
            Size = UDim2.fromScale(0.3,0.3);
            Position = UDim2.fromScale(0.35, 0.3);
            BackgroundTransparency = 1;
            TextColor3 = theme.text;
            Font = theme.font;
            TextScaled = true;
            Text = "Cost to upgrade.."..calculateCost(self.props.powerLevel+1);
        }),
        -- defines the purchase button
        BuyPower = roact.createElement("TextButton",{
            Size = UDim2.fromScale(0.3,0.3);
            Position = UDim2.fromScale(0.35,0.6);
            BackgroundColor3 = theme.background;
            Text = "";
            [roact.Event.Activated] = function() -- when the button is pressed send a request to server for purchase
                self.props.serverDispatch:FireServer({
                    type = "PurchasePower"
                })

            end,
        },{
            UICorner = roact.createElement("UICorner",{
                CornerRadius = UDim.new(.5,0);
            }),
            UIListLayout = roact.createElement("UIListLayout",{
                HorizontalAlignment = Enum.HorizontalAlignment.Center;
                VerticalAlignment = Enum.VerticalAlignment.Center;
                SortOrder = Enum.SortOrder.LayoutOrder;
                FillDirection = Enum.FillDirection.Horizontal;
            }),
            --text that gives context to the purchase button
            Description = roact.createElement("TextLabel",{
                Text = "Upgrade Power: ";
                Size = UDim2.fromScale(0.4,1);
                BackgroundTransparency = 1;
                TextColor3 = theme.text;
                Font = theme.font;
                TextScaled = true;
                LayoutOrder = 1;

            }),
            --shows prospective upgrade cost
            Value = roact.createElement("Frame",{
                Size = UDim2.fromScale(0.3,.7);
                LayoutOrder = 2;
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
                    Text = self.props.power.." -> "..calculatePower(self.props.powerLevel+1);
                    Size = UDim2.fromScale(0.5,1);
                    BackgroundTransparency = 1;
                    TextColor3 = theme.text;
                    Font = theme.font;
                    TextScaled = true;
                }),
            })
        }),
    })

end
-- roactrodux connects this component to the state for updates.
return roactRodux.connect(mapStateToProps, mapDispatchToProps)(Shop)





