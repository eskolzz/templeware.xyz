-- esp.lua
--// Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local cache = {}

local bones = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "LowerTorso"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}
}

--// Settings
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
    TracerThickness = 1,
    TracerPosition = "Bottom",
}

local function create(class, properties)
    local drawing = Drawing.new(class)
    for property, value in pairs(properties) do
        drawing[property] = value
    end
    return drawing
end

local function createEsp(player)
    local esp = {
        tracer = create("Line", {
            Thickness = ESP_SETTINGS.TracerThickness,
            Color = ESP_SETTINGS.TracerColor,
            Transparency = 1
        }),
        boxOutline = create("Square", {
            Color = ESP_SETTINGS.BoxOutlineColor,
            Thickness = 3,
            Filled = false
        }),
        box = create("Square", {
            Color = ESP_SETTINGS.BoxColor,
            Thickness = 1,
            Filled = false
        }),
        filledBox = create("Square", {
            Color = ESP_SETTINGS.BoxColor,
            Thickness = 1,
            Transparency = 0.3,
            Filled = true
        }),
        name = create("Text", {
            Color = ESP_SETTINGS.NameColor,
            Outline = true,
            Center = true,
            Size = 13
        }),
        healthOutline = create("Line", {
            Thickness = 3,
            Color = ESP_SETTINGS.HealthOutlineColor
        }),
        health = create("Line", {
            Thickness = 1
        }),
        distance = create("Text", {
            Color = Color3.new(1, 1, 1),
            Size = 12,
            Outline = true,
            Center = true
        }),
        boxLines = {},
    }

    cache[player] = esp
end

local function isPlayerBehindWall(player)
    local character = player.Character
    if not character then
        return false
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return false
    end

    local ray = Ray.new(camera.CFrame.Position, (rootPart.Position - camera.CFrame.Position).Unit * (rootPart.Position - camera.CFrame.Position).Magnitude)
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {localPlayer.Character, character})
    
    return hit and hit:IsA("Part")
end

local function removeEsp(player)
    local esp = cache[player]
    if not esp then return end

    for _, drawing in pairs(esp) do
        drawing:Remove()
    end

    cache[player] = nil
end

function lerp(a, b, t)
    return a + (b - a) * t
end


local function updateEsp()
    for player, esp in pairs(cache) do
        local character, team = player.Character, player.Team
        if character and (not ESP_SETTINGS.Teamcheck or (team and team ~= localPlayer.Team)) then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local head = character:FindFirstChild("Head")
            local humanoid = character:FindFirstChild("Humanoid")
            local isBehindWall = ESP_SETTINGS.WallCheck and isPlayerBehindWall(player)
            local shouldShow = not isBehindWall and ESP_SETTINGS.Enabled
            if rootPart and head and humanoid and shouldShow then
                local position, onScreen = camera:WorldToViewportPoint(rootPart.Position)
                if onScreen then
                    local hrp2D = camera:WorldToViewportPoint(rootPart.Position)
                    local charSize = (camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0)).Y - camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 2.6, 0)).Y) / 2
                    local boxSize = Vector2.new(math.floor(charSize * 1.4), math.floor(charSize * 1.9))
                    local boxPosition = Vector2.new(math.floor(hrp2D.X - charSize * 1.4 / 2), math.floor(hrp2D.Y - charSize * 1.6 / 2))

                    if ESP_SETTINGS.ShowName and ESP_SETTINGS.Enabled then
                        esp.name.Visible = true
                        esp.name.Text = string.lower(player.Name)
                        esp.name.Position = Vector2.new(boxSize.X / 2 + boxPosition.X, boxPosition.Y - 16)
                        esp.name.Color = ESP_SETTINGS.NameColor
                    else
                        esp.name.Visible = false
                    end

                    if ESP_SETTINGS.ShowFilledBox and ESP_SETTINGS.Enabled then
                        esp.filledBox.Position = boxPosition
                        esp.filledBox.Size = boxSize
                        esp.filledBox.Color = ESP_SETTINGS.FilledBoxColor
                        esp.filledBox.Visible = true
                    else
                        esp.filledBox.Visible = false
                    end

                    if ESP_SETTINGS.ShowBox and ESP_SETTINGS.Enabled then
                        if ESP_SETTINGS.BoxType == "Normal" then
                            esp.boxOutline.Size = boxSize
                            esp.boxOutline.Position = boxPosition
                            esp.box.Size = boxSize
                            esp.box.Position = boxPosition
                            esp.box.Color = ESP_SETTINGS.BoxColor
                            esp.box.Visible = true
                            esp.boxOutline.Visible = true
                            for _, line in ipairs(esp.boxLines) do
                                line:Remove()
                            end
                        elseif ESP_SETTINGS.BoxType == "Corner" then
                            local lineW = (boxSize.X / 3)
                            local lineH = (boxSize.Y / 3)
                        
                            if #esp.boxLines == 0 then
                                for i = 1, 16 do
                                    local boxLine = create("Line", {
                                        Thickness = 1,
                                        Color = ESP_SETTINGS.BoxColor,
                                        Transparency = 1
                                    })
                                    esp.boxLines[#esp.boxLines + 1] = boxLine
                                end
                            end
                        
                            local boxLines = esp.boxLines
                        
                            -- outline
                            for i = 1, 8 do
                                boxLines[i].Thickness = 2
                                boxLines[i].Color = ESP_SETTINGS.BoxOutlineColor
                                boxLines[i].Transparency = 1
                            end
                        
                            boxLines[1].From = Vector2.new(boxPosition.X, boxPosition.Y)
                            boxLines[1].To = Vector2.new(boxPosition.X, boxPosition.Y + lineH)
                        
                            boxLines[2].From = Vector2.new(boxPosition.X, boxPosition.Y)
                            boxLines[2].To = Vector2.new(boxPosition.X + lineW, boxPosition.Y)
                        
                            boxLines[3].From = Vector2.new(boxPosition.X + boxSize.X - lineW, boxPosition.Y)
                            boxLines[3].To = Vector2.new(boxPosition.X + boxSize.X, boxPosition.Y)
                        
                            boxLines[4].From = Vector2.new(boxPosition.X + boxSize.X, boxPosition.Y)
                            boxLines[4].To = Vector2.new(boxPosition.X + boxSize.X, boxPosition.Y + lineH)
                        
                            boxLines[5].From = Vector2.new(boxPosition.X, boxPosition.Y + boxSize.Y - lineH)
                            boxLines[5].To = Vector2.new(boxPosition.X, boxPosition.Y + boxSize.Y)
                        
                            boxLines[6].From = Vector2.new(boxPosition.X, boxPosition.Y + boxSize.Y)
                            boxLines[6].To = Vector2.new(boxPosition.X + lineW, boxPosition.Y + boxSize.Y)
                        
                            boxLines[7].From = Vector2.new(boxPosition.X + boxSize.X - lineW, boxPosition.Y + boxSize.Y)
                            boxLines[7].To = Vector2.new(boxPosition.X + boxSize.X, boxPosition.Y + boxSize.Y)
                        
                            boxLines[8].From = Vector2.new(boxPosition.X + boxSize.X, boxPosition.Y + boxSize.Y - lineH)
                            boxLines[8].To = Vector2.new(boxPosition.X + boxSize.X, boxPosition.Y + boxSize.Y)
                        
                            -- inline
                            for i = 9, 16 do
                                boxLines[i].From = boxLines[i - 8].From
                                boxLines[i].To = boxLines[i - 8].To
                                boxLines[i].Color = ESP_SETTINGS.BoxColor
                            end
                        
                            for _, line in ipairs(boxLines) do
                                line.Visible = true
                            end
                            esp.box.Visible = false
                            esp.boxOutline.Visible = false
                        end
                    else
                        esp.box.Visible = false
                        esp.boxOutline.Visible = false
                        for _, line in ipairs(esp.boxLines) do
                            line:Remove()
                        end
                        esp.boxLines = {}
                    end

                    if ESP_SETTINGS.ShowHealth and ESP_SETTINGS.Enabled then
                        esp.healthOutline.Visible = true
                        esp.health.Visible = true
                        local health = 0
                        if ESP_SETTINGS.AnimatedHealthBars then
                            health = lerp(health, player.Character.Humanoid.Health, 0.3)
                        else
                            health = player.Character.Humanoid.Health
                        end
                        local healthPercentage = health / player.Character.Humanoid.MaxHealth
                        local healthBarHeight = (health / player.Character.Humanoid.MaxHealth) * boxSize.Y
                        esp.healthOutline.From = Vector2.new(boxPosition.X - 6, boxPosition.Y + boxSize.Y + 1)
                        esp.healthOutline.To = Vector2.new(esp.healthOutline.From.X, esp.healthOutline.From.Y - boxSize.Y - 1)
                        esp.health.From = Vector2.new(boxPosition.X - 6, boxPosition.Y + boxSize.Y)
                        
                        esp.health.To = Vector2.new(boxPosition.X - 6, boxPosition.Y + boxSize.Y - healthBarHeight) + Vector2.new(0, 1)
                        if ESP_SETTINGS.HealthBasedColor then
                            esp.health.Color = ESP_SETTINGS.HealthLowColor:Lerp(ESP_SETTINGS.HealthHighColor, healthPercentage)
                        else
                            esp.health.Color = ESP_SETTINGS.HealthColor
                        end
                    else
                        esp.healthOutline.Visible = false
                        esp.health.Visible = false
                    end

                    if ESP_SETTINGS.ShowDistance and ESP_SETTINGS.Enabled then
                        local distance = (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                        esp.distance.Text = string.format("%.1f studs", distance)
                        esp.distance.Position = Vector2.new(boxPosition.X + boxSize.X / 2, boxPosition.Y + boxSize.Y + 5)
                        esp.distance.Color = ESP_SETTINGS.DistanceColor
                        esp.distance.Visible = true
                    else
                        esp.distance.Visible = false
                    end             

                    if ESP_SETTINGS.ShowTracer and ESP_SETTINGS.Enabled then
                        local tracerY
                        if ESP_SETTINGS.TracerPosition == "Top" then
                            tracerY = 0
                        elseif ESP_SETTINGS.TracerPosition == "Middle" then
                            tracerY = camera.ViewportSize.Y / 2
                        else
                            tracerY = camera.ViewportSize.Y
                        end
                        if ESP_SETTINGS.Teamcheck and player.TeamColor == localPlayer.TeamColor then
                            esp.tracer.Visible = false
                        else
                            esp.tracer.Visible = true
                            esp.tracer.From = Vector2.new(camera.ViewportSize.X / 2, tracerY)
                            esp.tracer.To = Vector2.new(hrp2D.X, hrp2D.Y)
                            esp.tracer.Color = ESP_SETTINGS.TracerColor
                            esp.tracer.Thickness = ESP_SETTINGS.TracerThickness
                        end
                    else
                        esp.tracer.Visible = false
                    end
                else
                    for _, drawing in pairs(esp) do
                        drawing.Visible = false
                    end
                    for _, line in ipairs(esp.boxLines) do
                        line:Remove()
                    end
                    esp.boxLines = {}
                end
            else
                for _, drawing in pairs(esp) do
                    drawing.Visible = false
                end
                for _, line in ipairs(esp.boxLines) do
                    line:Remove()
                end
                esp.boxLines = {}
            end
        else
            for _, drawing in pairs(esp) do
                drawing.Visible = false
            end
            for _, line in ipairs(esp.boxLines) do
                line:Remove()
            end
            esp.boxLines = {}
        end
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= localPlayer then
        createEsp(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= localPlayer then
        createEsp(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeEsp(player)
end)

RunService.RenderStepped:Connect(updateEsp)
return ESP_SETTINGS
