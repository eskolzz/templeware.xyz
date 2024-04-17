local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'templeware.xyz',
    Center = true,
    AutoShow = true,
    TabPadding = 8
})

local Tabs = {
    ESP = Window:AddTab('ESP'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}


local espSettings = Tabs.ESP:AddLeftGroupbox('ESP Settings')
local espSettings2 = Tabs.ESP:AddRightGroupbox('ESP Misc')



espSettings:AddToggle('espKillswitch', {
    Text = 'esp killswitch',
    Default = false, 
    Tooltip = 'esp killswitch', 

    Callback = function(Value)
        ESP_SETTINGS.Enabled = not ESP_SETTINGS.Enabled
    end
})


espSettings:AddToggle('Boxes', {
    Text = 'esp boxes',
    Default = false, 
    Tooltip = 'esp boxes', 

    Callback = function(Value)
        ESP_SETTINGS.ShowBox = not ESP_SETTINGS.ShowBox
    end
})


espSettings:AddToggle('Box Filled', {
    Text = 'box fill',
    Default = false, 
    Tooltip = 'box fill', 

    Callback = function(Value)
        ESP_SETTINGS.ShowFilledBox = not ESP_SETTINGS.ShowFilledBox
    end
})


espSettings:AddToggle('Show Name', {
    Text = 'name esp',
    Default = false, 
    Tooltip = 'name esp', 

    Callback = function(Value)
        ESP_SETTINGS.ShowName = not ESP_SETTINGS.ShowName
    end
})


espSettings:AddToggle('Show Distance', {
    Text = 'distance esp',
    Default = false, 
    Tooltip = 'distance esp', 

    Callback = function(Value)
        ESP_SETTINGS.ShowDistance = not ESP_SETTINGS.ShowDistance
    end
})


espSettings:AddToggle('Show Health', {
    Text = 'health esp',
    Default = false, 
    Tooltip = 'health esp', 

    Callback = function(Value)
        ESP_SETTINGS.ShowHealth = not ESP_SETTINGS.ShowHealth
    end
})

--[[
espSettings:AddToggle('Show Chams', {
    Text = 'chams',
    Default = false, 
    Tooltip = 'chams', 

    Callback = function(Value)
        ESP_SETTINGS.ChamsEnabled = not ESP_SETTINGS.ChamsEnabled
    end
})
--]]

espSettings:AddLabel('Box Color'):AddColorPicker('Box Color', {
    Default = Color3.new(1, 1, 1),
    Title = 'Box Color', 
    Transparency = nil, 

    Callback = function(Value)
        ESP_SETTINGS.BoxColor = Value
    end
})

espSettings:AddLabel('Box Fill Color'):AddColorPicker('Box Fill Color', {
    Default = Color3.new(1, 1, 1), 
    Title = 'Box Fill Color', 
    Transparency = nil, 

    Callback = function(Value)
        ESP_SETTINGS.FilledBoxColor = Value
    end
})

espSettings:AddLabel('NameColor'):AddColorPicker('NameColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'Some color',
    Transparency = nil,

    Callback = function(Value)
        ESP_SETTINGS.NameColor = Value
    end
})

--[[
espSettings:AddLabel('Chams Fill Color'):AddColorPicker('Chams Fill Color', {
    Default = Color3.new(1, 1, 1),
    Title = 'Some color',
    Transparency = nil,

    Callback = function(Value)
        ESP_SETTINGS.ChamsColor = Value
    end
})

espSettings:AddLabel('Chams Outline Color'):AddColorPicker('Chams Outline Color', {
    Default = Color3.new(0, 0, 0),
    Title = 'Some color',
    Transparency = nil,

    Callback = function(Value)
        ESP_SETTINGS.ChamsOutlineColor = Value
    end
})
--]]














espSettings2:AddToggle('Teamcheck', {
    Text = 'teamcheck',
    Default = false, 
    Tooltip = 'teamcheck', 

    Callback = function(Value)
        ESP_SETTINGS.Teamcheck = not ESP_SETTINGS.Teamcheck
    end
})


espSettings2:AddToggle('vischeck', {
    Text = 'visible check',
    Default = false, 
    Tooltip = 'visible check', 

    Callback = function(Value)
        ESP_SETTINGS.Wallcheck = not ESP_SETTINGS.Wallcheck
    end
})


espSettings2:AddToggle('Animated Health Bars', {
    Text = 'animated health bar',
    Default = false, 
    Tooltip = 'animated health bar', 

    Callback = function(Value)
        ESP_SETTINGS.AnimatedHealthBars = not ESP_SETTINGS.AnimatedHealthBars
    end
})


espSettings2:AddToggle('health based color', {
    Text = 'health based color',
    Default = false, 
    Tooltip = 'health based color', 

    Callback = function(Value)
        ESP_SETTINGS.HealthBasedColor = not ESP_SETTINGS.HealthBasedColor
    end
})






--[[

local ESP_SETTINGS = {
    BoxOutlineColor = Color3.new(0, 0, 0),
    BoxColor = Color3.new(1, 1, 1),
    FilledBoxColor = Color3.new(1, 1, 1),
    NameColor = Color3.new(1, 1, 1),
    HealthOutlineColor = Color3.new(0, 0, 0),
    HealthHighColor = Color3.new(0, 1, 0),
    HealthLowColor = Color3.new(1, 0, 0),
    HealthColor = Color3.new(1, 1, 1),
    AnimatedHealthBars = false,
    DistanceColor = Color3.new(1, 1, 1),
    HealthBasedColor = false,
    CharSize = Vector2.new(4, 6),
    Teamcheck = false,
    WallCheck = false,
    Enabled = false,
    ShowFilledBox = false,
    ShowBox = false,
    BoxType = "Normal",
    ShowName = false,
    ShowHealth = false,
    ShowDistance = false,
    ShowTracer = false,
    TracerThickness = 1, --dont use tracers they're currently broken and im too lazy to fix them
    TracerPosition = "Bottom",
}
--]]

task.spawn(function()
    while true do
        wait(1)

        local state = Options.KeyPicker:GetState()
        if state then
            print('KeyPicker is being held down')
        end

        if Library.Unloaded then break end
    end
end)

Library:SetWatermarkVisibility(true)
Library:Notify("Hello World!", 5)
Library:SetWatermark('This is a really long watermark to test the resizing')
Library.KeybindFrame.Visible = true; 

Library:OnUnload(function()

    ESP_SETTINGS.Enabled = false
    
    Library.Unloaded = true
end)

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })
Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('MyScriptHub')
SaveManager:SetFolder('MyScriptHub/specific-game')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()
