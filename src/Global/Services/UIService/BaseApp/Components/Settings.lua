local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

--modules
local util = ReplicatedStorage.Vendor
local roactRodux = require(util:WaitForChild("Roact-Rodux"))
local roact = require(util:WaitForChild("Roact"))
--animation modules
local flipper = require(util:WaitForChild("Flipper"))
local spring = flipper.Spring


local Settings = roact.Component:extend("Settings")

--animations

local TWEEN_IN_SPRING = {
    frequency = 5,
    dampingRatio = 1
}

-- rodux methods

-- do you ever feel like developing is a whole lot of screen staring and then doing something?

local function mapStateToProps(state)
    return {
        open = state.playerHandler.Lobby.currentOpen;
        settings = state.playerHandler.Settings;
        themeSettings = state.playerHandler.Theme;

    }
end

local function mapDispatchToProps(dispatch)
    return {
        cameraToggle = function(fov, position, specular, exposure, camType, lighting)
     
            dispatch({
                type = "ToggleCamera";
                fov = fov;
                position = position;
                specular = specular;
                exposure = exposure;
                camType = camType;
                lighting = lighting;

            })
        end;
        lobbyToggle = function(toggleTo)
            dispatch({
                type = "ToggleLobby";
                toggleTo = toggleTo;
            })
            
        end;
        updateBinding = function(category, setting, key, value)
            dispatch({
                type = "UpdateSetting";
                tree = category;
                setting = setting;
                key = key;
                value = value;
            })
        end;
        updateTheme = function(setting, value)
            dispatch({
                type = "UpdateTheme";
                setting = setting;
                value = value;
            })
        end;
    }
end

-- component methods
local function createButton(self, theme, props)
    return roact.createElement("Frame",{
        Size = UDim2.fromScale(.02,.02);
        Position = props.Position or UDim2.fromScale(0.44,0.44);
        BackgroundColor3 =  theme.border;
        Transparency = 0.5;
    },{ 
        inner = roact.createElement("TextButton",{
            Size = UDim2.fromScale(.6,.6);
            Position = UDim2.fromScale(0.2,0.2);
            Text = "";
            BorderSizePixel = 0;
            BackgroundColor3 = props.Value and theme.text or theme.background;
            [roact.Event.Activated] = function()
                props.Bindable()
                --self.props.ruleSet("UsesTimer", not(vip.customSettings.GameRules.RuleSet.UsesTimer))
            end
        });
        constraint = roact.createElement("UISizeConstraint",{
            MinSize = Vector2.new(30,30);
        })
    });
end

local function createText(self, theme, props)
    return roact.createElement("TextLabel",{
        Text = props.Text;
        Position = props.Position;
        LayoutOrder = props.Order;
        BackgroundTransparency = props.BackgroundTransparency or 0;
        Size = props.Size or UDim2.fromScale(1,0.01);
        BackgroundColor3 = props.Background or theme.text;
        TextColor3 = props.TextColor or theme.background;
        TextSize = props.TextSize or 12;
        Font = theme.font;
        ZIndex = 2;
    },{
        constraint = roact.createElement("UISizeConstraint",{
            MinSize = props.MinSize or  Vector2.new(0,30);
        })
    })

end

local function createTextButton(self, theme, props)
    return roact.createElement("TextButton",{
        Text = props.Text;
        Position = props.Position;
        LayoutOrder = props.Order;
        Size = props.Size or UDim2.fromScale(0.2,0.8);
        BackgroundColor3 = props.Background or theme.text;
        TextColor3 = props.TextColor or theme.background;
        TextSize = props.TextSize or 12;
        Font = theme.font;
        ZIndex = 2;
        [roact.Event.Activated] = function(obj)
            props.Bindable(obj)

        end
    },{
        constraint = roact.createElement("UISizeConstraint",{
            MinSize = Vector2.new(0,30);
        })
    })


end



local function createTextBox(self, theme, props)
    return roact.createElement("TextBox",{
        Text = props.Text;
        Position = props.Position;
        LayoutOrder = props.Order;
        Size = props.Size or UDim2.fromScale(1,0.01);
        BackgroundColor3 = props.Background or theme.text;
        TextColor3 = props.TextColor or theme.background;
        TextSize = props.TextSize or 12;
        Font = theme.font;
        ZIndex = 2;
        [roact.Event.FocusLost] = function(obj)
            props.Bindable(obj)

        end
    },{
        constraint = roact.createElement("UISizeConstraint",{
            MinSize = Vector2.new(0,30);
        })
    })


end

local function createTitle(self, theme, props)
    return roact.createElement("Frame",{
        Size = props.Size or UDim2.new(.95,0,0,50);
        Position = props.Position;
        BackgroundTransparency = 1;
        BorderSizePixel = 2;
        BorderColor3 = theme.border;
        LayoutOrder = props.Order;
    },{
        title = roact.createElement("TextLabel",{
            Text = props.Title;
            Font = theme.font;
            TextXAlignment = 0;
            TextColor3 = theme.text;
            BackgroundTransparency = 1;
            TextSize = 24;
            Size = props.TitleSize or UDim2.fromScale(0.4,0.5);
            Position = UDim2.fromScale(0.01, 0);
        });
    })

end


local function createSetting(self, theme, props)
    return roact.createElement("Frame",{
        Size = props.Size or UDim2.new(.95,0,0,50);
        Position = props.Position;
        BackgroundColor3 = theme.option;
        BorderSizePixel = 2;
        BorderColor3 = theme.border;
        LayoutOrder = props.Order;
    },{
        title = roact.createElement("TextLabel",{
            Text = props.Title;
            Font = theme.font;
            TextXAlignment = 0;
            TextColor3 = theme.text;
            BackgroundTransparency = 1;
            TextSize = 18;
            Size = props.TitleSize or UDim2.fromScale(0.4,0.5);
            Position = UDim2.fromScale(0.01, 0);
        });
        desc = roact.createElement("TextLabel",{
            Text = props.Description or "";
            BackgroundTransparency = 1;
            TextXAlignment = 0;
            TextSize = 18;
            TextColor3 = Color3.fromRGB(150,150,150);
            Font = theme.font;
            --TextColor3 = theme.text;
            Size = props.DescriptionSize or UDim2.fromScale(0.5,0.5);
            Position = props.DescriptionPos or UDim2.fromScale(0.01,0.5);
        });
        constraint = roact.createElement("UISizeConstraint",{
            MinSize = props.Constraint or Vector2.new(0,75.5)
        });
        container = roact.createElement("Frame",{
            Size = UDim2.fromScale(1,1);
            BackgroundTransparency = 1;
        },
            props.Children
        );
    })

end

local function createDropdown(self, theme, props)
    return roact.createElement("ScrollingFrame",{
        Size = props.Size;
        Position = props.Position;
        Visible = props.Visible;
        ClipsDescendants = props.ClipsDescendants or false;
        BackgroundTransparency = props.Transparency or 1;

    },{
        layout = roact.createElement("UIListLayout",{
            SortOrder = 2
        });
        children = roact.createFragment(props.Children);
    })



end


local function createSuperSetting(self, theme, props)

    local table = props.Table
    local mapBase = props.Map
    return {
        content = createDropdown(self, theme, {
            Position = UDim2.fromScale(0.1,0.2);
            Size = UDim2.fromScale(0.8,0.8);
            Transparency = 1;
            ClipsDescendants = true;
            Children = (function()
                local generated = {}
                local count = 1;
                for i, value in pairs(table) do
                   
                    count +=1
                    local type
                    if typeof(value) == "boolean" then
                        type = createButton
                    else
                        type = createTextBox
                    end
                    generated[i] = roact.createElement("Frame",{
                        BackgroundTransparency = 1;
                        Size = UDim2.new(1,0,0,50);
                    },{
                        desc = createText(self, theme, {
                            Text = mapBase and mapBase[i] or i;
                            TextColor = theme.text;
                            TextSize = 18;
                            Size = UDim2.fromScale(0.5, 0.1);
                            Background = theme.section;
                            BackgroundTransparency = 1;
                            MinSize = Vector2.new(0,50);
                            Order = count;
                        });
                        option = type(self, theme, {
                            Text = (typeof(value) == "string" or typeof(value) == "number") and value;
                            TextColor = theme.section;
                            Value = (typeof(value) == "boolean") and value;
                            TextSize = 18;
                            Size = UDim2.fromScale(0.5, 0.1);
                            Position = (typeof(value) == "boolean") and  UDim2.fromScale(0.717,0) or UDim2.fromScale(0.5,0);
                            Background = theme.text;
                            BackgroundTransparency = 1;
                            MinSize = Vector2.new(0,50);
                            Order = count;
                            Bindable = function(obj)
                          
                                if typeof(value) == "boolean" then
                                 
                                    self.props.superSet(not(value),i, props.Super)
                                elseif typeof(value) == "string" then
                                    self.props.superSet(obj.Text,i, props.Super)
                                elseif typeof(value) == "number" then
                                    self.props.superSet(tonumber(obj.Text) or 0,i,props.Super)
                                end


                            end;
                        })
    

                    })
                end
                    
                return generated
            end)()
        });
    }
end

local function createOptionButton(self, theme, props)--open, theme, Name, Position, Dispatch, Size)

    local children = {}
    children["UIText"] = roact.createElement("UITextSizeConstraint", {
        MaxTextSize = 24;
    })

    if props.open ==  props.Name then
        children["UIGradient"] =  roact.createElement("Frame",{
            Size = UDim2.fromScale(1,1);
            BorderSizePixel = 0;
            ZIndex = 20;
            BackgroundTransparency = 1;
        },{ 

            Border = roact.createElement("Frame",{
                BackgroundColor3 = Color3.fromRGB(255,255,255);
                Size = UDim2.fromScale(1,0.05);
                Position = UDim2.fromScale(0, .95);
                ZIndex = 21;
               
                BorderSizePixel =  0;
            })
        });
        return roact.createElement("TextButton",{
            Text = props.Name;
            Font = theme.font;
            BackgroundTransparency = 1;
            BackgroundColor3 = theme.text;
            TextSize = 16;
            --TextScaled = true;
            LayoutOrder = props.Order;
            TextColor3 = theme.text;
            BorderSizePixel = 0;
            ZIndex = 21;
            Size = props.Size or UDim2.fromScale(0.12,1);
            Position = props.Position;
            [roact.Event.Activated] = function(obj)
                props.Dispatch(obj)
            end;

        },
            children
        )
    else
        return roact.createElement("TextButton",{
            Text = props.Name;
            Font = theme.font;
            BackgroundTransparency = 1;
            ZIndex = 20;
            TextSize = 16;
            --TextScaled = true;
            LayoutOrder = props.Order;
            TextColor3 = theme.text;
            Size = props.Size or UDim2.fromScale(0.12,1);
            Position = props.Position;
            [roact.Event.Activated] = function(obj)
        
                self.motor:setGoal(spring.new(0, TWEEN_IN_SPRING))
                
                wait(0.1)
                props.Dispatch(obj)
            end;
            [roact.Event.MouseEnter] = function(obj)
                obj.TextColor3 = theme.border;
            end;
            [roact.Event.MouseLeave] = function(obj)
                obj.TextColor3 = theme.text;
            end;
        },
            children
        )

    end



end

function createStack(self, theme, props)
    local settings = props.Settings
    
    if props.Type == "Choices" then
        return roact.createElement("Frame",{
            Size = UDim2.fromScale(0.5,1);
            Position = UDim2.fromScale(0.5,0);
            BackgroundTransparency = 1;
        }, props.Children)


    else
        return roact.createElement("Frame",{
            Size = UDim2.fromScale(0.5,1);
            Position = UDim2.fromScale(0.5,0);
            BackgroundTransparency = 1;
        },{
            layout = roact.createElement("UIListLayout",{
                FillDirection = 0;
                Padding = UDim.new(0.01,0);
            });
            firstBind = createTextButton(self, theme, {
                
                Text = settings[props.Tree][props.Setting][1].Name;
                Bindable = function(obj)
                    local connection
                    obj.Text = "press key"
                    spawn(function()
                        connection = game:GetService("UserInputService").InputBegan:Connect(function(input)

                            if input.KeyCode.Name == "Unknown" then
                                obj.Text = settings[props.Tree][props.Setting][1].Name -- bring it back to original value
                            else
                                obj.Text = input.KeyCode.Name -- update keybinding on text
                                self.props.updateBinding(props.Tree, props.Setting, 1, input.KeyCode)
                            end

                            connection:Disconnect();
                    
                        end)
                    
                        
                    end) --i'm using spawn because I don't really care about execution order from task.spawn
                end;

            
            });
            secondBind = createTextButton(self, theme, {
                        
                Text = settings[props.Tree][props.Setting][2].Name;
                Bindable = function(obj)
                    local connection
                    obj.Text = "press key"
                    spawn(function()
                        connection = game:GetService("UserInputService").InputBegan:Connect(function(input)

                            if input.KeyCode.Name == "Unknown" then
                                obj.Text = settings[props.Tree][props.Setting][2].Name -- bring it back to original value
                            else
                                obj.Text = input.KeyCode.Name -- update keybinding on text
                                self.props.updateBinding(props.Tree, props.Setting, 2, input.KeyCode)
                            end

                            connection:Disconnect();
                    
                        end)
                    
                        
                    end) --i'm using spawn because I don't really care about execution order from task.spawn
                end;
            });
            thirdBind = createTextButton(self, theme, {
                        
                Text = settings[props.Tree][props.Setting][3] and settings[props.Tree][props.Setting][3].Name or "Enter Key";
                Bindable = function(obj)
                    local connection
                    obj.Text = "press key"
                    spawn(function()
                        connection = game:GetService("UserInputService").InputBegan:Connect(function(input)

                            if input.KeyCode.Name == "Unknown" then
                                obj.Text = settings[props.Tree][props.Setting][3].Name or "Enter Key"-- bring it back to original value
                            else
                                obj.Text = input.KeyCode.Name -- update keybinding on text
                                self.props.updateBinding(props.Tree, props.Setting, 3, input.KeyCode)
                            end

                            connection:Disconnect();
                    
                        end)
                    
                        
                    end) --i'm using spawn because I don't really care about execution order from task.spawn
                end;
            })
        })
    end

end

function createContent(self, theme, props)
    local content
    

    if props.open == "CONTROL BINDINGS" then -- content got redefined here
        local settings = self.props.settings
    
        content = {
            navigation = createTitle(self, theme, {
                Title = "Navigation";
                Order = 0
            });
            tabbingRight = createSetting(self, theme, {
                Constraint = Vector2.new(0,90);
                Title = "Tabbing Right";
      
                Order = 1;
                Children = createStack(self, theme, {
                    Settings = settings;
                    Tree = "Navigation";
                    Setting = "tabRight"
                })
            });
            tabbingLeft = createSetting(self, theme, {
                Constraint = Vector2.new(0,90); 
                Title = "Tabbing Left";
                Order = 2;
                Children = createStack(self, theme, {
                    Settings = settings;
                    Tree = "Navigation";
                    Setting = "tabLeft"
                })
            });
        }
    elseif props.open == "THEME" then
        local settings = self.props.themeSettings

        content = {
   
            preset = createSetting(self, theme, {
               -- Type = 
                Constraint = Vector2.new(0,90);
                Title = "Presets";
      
                Order = 1;
                Children = createStack(self, theme, {
                    Type = "Choices";
                    Children = {
                        layout = roact.createElement("UIListLayout",{
                            FillDirection = 0;
                            Padding = UDim.new(0.01,0);
                        });
                        dark = createTextButton(self, theme, {
                
                            Text = "Dark Theme";
                            Bindable = function(obj)
                                self.props.updateTheme("Current", "darkTheme");
                            end;
                        });
                        light = createTextButton(self, theme, {
                
                            Text = "Light Theme";
                            Bindable = function(obj)
                                self.props.updateTheme("Current", "lightTheme");
                            end;
                        })

                    }
                })
            });

        }
    end


    content["Layout"] = roact.createElement("UIListLayout",{
        HorizontalAlignment = 0;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Padding = UDim.new(0.01,0);
    })
    content["Padding"] = roact.createElement("UIPadding",{
        PaddingTop = UDim.new(0.01,0);
    })
    return roact.createElement("ScrollingFrame",{
        Size = props.Size;
        Position = props.Position;
        BackgroundTransparency = 0.1;
        BackgroundColor3 = theme.background;
    }, content)


end

function Settings:init()
	self.motor = flipper.SingleMotor.new(1)
  
	local binding, setBinding = roact.createBinding(self.motor:getValue())
	self.binding = binding

	self.motor:onStep(setBinding)
    self.motor:onComplete(function()
        self.motor:setGoal(spring.new(1, TWEEN_IN_SPRING))
    end)

    self:setState({
        open = "CONTROL BINDINGS"
    })
end

function Settings:render()
    local theme = self.props.theme;
    local open = self.state.open

    return roact.createElement("Frame",{
        Size = UDim2.fromScale(1,1);
        BackgroundTransparency = 1;
    },{
        topbar = roact.createElement("Frame",{
            Size = UDim2.fromScale(1,0.07);
            ZIndex = 20;
            BackgroundColor3 = theme.section;
            BorderSizePixel = 0;
            BackgroundTransparency = 0.2;
        
        },{
            Layout = roact.createElement("UIListLayout",{
                FillDirection = 0;
                --HorizontalAlignment = 0;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Padding = UDim.new(0.01,0);
            });
            Padding = roact.createElement("UIPadding",{
                PaddingTop = UDim.new(0.01,0);
            });
            control = createOptionButton(self, theme, {
                Name = "CONTROL BINDINGS";
                open = open, 
                Order = 1;
                Position = UDim2.fromScale(0.1,0),
                Size = UDim2.fromScale(0.2,1);
                Dispatch =  function(obj) 
                    spawn(function() 
                        self:setState(function() 
                            return {
                                open = obj.Text
                            } 
                        end) 
                    end)
                end,
            });
            theme = createOptionButton(self, theme, {
                Name = "THEME";
                open = open, 
                Order = 2;
                Position = UDim2.fromScale(0.1,0),
                Size = UDim2.fromScale(0.2,1);
                Dispatch =  function(obj)
                    spawn(function() 
                        self:setState(function() 
                            return {
                                open = obj.Text
                            } 
                        end) 
                    end)
                end,
            });
            vip = (self.props.serverType == "VIPServer") and createOptionButton(self, theme,{
                Name = "SERVER SETTINGS";
                open = open;
                Order = 3;
                Size = UDim2.fromScale(0.2, 1);
                Dispatch = function(obj)
                    spawn(function()
                        self:setState(function()
                            return {
                                open = obj.Text
                            }
                        end)
                    end)
                end;
            })
        }) or nil;
        contents = createContent(self, theme, {
            open = open;
            Size = UDim2.fromScale(1, .93);
            Position = UDim2.fromScale(0, 0.07);
        })
    })

end

return roactRodux.connect(mapStateToProps, mapDispatchToProps)(Settings)
