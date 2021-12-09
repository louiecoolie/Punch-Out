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
local function calculateCost(powerLevel)
    local result = (0.2*math.exp(powerLevel)) * 10
    return math.floor(result)
end

local function calculatePower(powerLevel)
    local result = (0.37*math.exp(powerLevel)) * 10
    return math.floor(result)
end


function Shop:init()

end

function Shop:render()
   
    local theme = self.props.theme;



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
        Close = roact.createElement("TextButton",{
            Size = UDim2.fromScale(0.1,0.1);
            Position = UDim2.fromScale(0.85,0.05);
            BackgroundColor3 = theme.background;
            Text = "";
            [roact.Event.Activated] = function()
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
        CostPower = roact.createElement("TextLabel",{
            Size = UDim2.fromScale(0.3,0.3);
            Position = UDim2.fromScale(0.35, 0.3);
            BackgroundTransparency = 1;
            TextColor3 = theme.text;
            Font = theme.font;
            TextScaled = true;
            Text = "Cost to upgrade.."..calculateCost(self.props.powerLevel+1);
        }),
        BuyPower = roact.createElement("TextButton",{
            Size = UDim2.fromScale(0.3,0.3);
            Position = UDim2.fromScale(0.35,0.6);
            BackgroundColor3 = theme.background;
            Text = "";
            [roact.Event.Activated] = function()
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
            Description = roact.createElement("TextLabel",{
                Text = "Upgrade Power: ";
                Size = UDim2.fromScale(0.4,1);
                BackgroundTransparency = 1;
                TextColor3 = theme.text;
                Font = theme.font;
                TextScaled = true;
                LayoutOrder = 1;

            }),
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

function Shop:didMount()

end

function Shop:willUnmount()


end

return roactRodux.connect(mapStateToProps, mapDispatchToProps)(Shop)





