--!nocheck
--!nolint UnknownGlobal

local env = type(getgenv) == 'function' and getgenv()

if type(env) == 'table' then
    if type(env.stop_rocky_aimbot_modded) == 'function' then
        env.stop_rocky_aimbot_modded()
    end
else
    return error('Missing global environment')
end

local cloneref = type(cloneref) == 'function' and cloneref or function(object)
    return object
end

local insert = table.insert
local connections = {}
local instances = {}
local create = Instance.new

local newInstance = function(class_name, parent)
    local object = create(class_name, parent)
    insert(instances, object)
    return object
end

local connect = function(signal, callback)
    local connection = signal:Connect(callback)
    insert(connections, connection)
    return connection
end

local str = select(2, pcall(game.HttpGet, game, 'https://sirius.menu/rayfield'))
if type(str) == 'string' then
    local f = select(2, pcall(loadstring, str))
    if type(f) == 'function' then
        Rayfield = select(2, pcall(f))
    end
end

if type(Rayfield) ~= 'table' then
    error('Rayfield missing or failed to load')
    return
end

local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local HttpService = cloneref(game:GetService("HttpService"))
local TeleportService = cloneref(game:GetService("TeleportService"))

local plr = Players.LocalPlayer
local char = plr.Character
local humanoid = char and char:FindFirstChildWhichIsA('Humanoid')
local hrp = humanoid and humanoid.RootPart or (char and char:FindFirstChild('HumanoidRootPart'))

local function onCharacterAdded(character)
    char = character
    humanoid = char and char:FindFirstChildWhichIsA('Humanoid')
    hrp = humanoid and humanoid.RootPart or (char and char:FindFirstChild('HumanoidRootPart'))
end

connect(plr.CharacterAdded, onCharacterAdded)

if char then
    onCharacterAdded(char)
end

local camera = workspace.CurrentCamera
local mouse = plr:GetMouse()
local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

local hue = 0
local rainbowFov = false
local rainbowSpeed = 0.005

local aimFov = 100
local aimParts = {"Head"}
local aiming = false
local predictionStrength = 0.065
local smoothing = 0.05

local aimbotEnabled = false
local wallCheck = true
local stickyAimEnabled = false
local teamCheck = false
local healthCheck = false
local minHealth = 0

local antiAim = false

local antiAimAmountX = 0
local antiAimAmountY = -100
local antiAimAmountZ = 0

local antiAimMethod = "Reset Velo"

local randomVeloRange = 100

local spinBot = false
local spinBotSpeed = 20

local circleColor = Color3.fromRGB(255, 0, 0)
local targetedCircleColor = Color3.fromRGB(0, 255, 0)

local Window = Rayfield:CreateWindow({
    Name = "▶ Universal Hub ◀",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by Agreed 🥵\nFixed by Rocky & thuarnel",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "UniversalHub",
        FileName = "byAgreed"
    },
})

local Aimbot = Window:CreateTab("Aimbot")
local AntiAim = Window:CreateTab("Anti-Aim")
local Misc = Window:CreateTab("Misc")

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.Radius = aimFov
fovCircle.Filled = false
fovCircle.Color = circleColor
fovCircle.Visible = false

local currentTarget = nil

local function checkTeam(player)
    if teamCheck and typeof(player.Team) == 'Instance' and player.Team == plr.Team then
        return true
    end
    return false
end

local function checkWall(targetCharacter)
    local targetHead = targetCharacter:FindFirstChild("Head")
    if not targetHead then return true end

    local origin = camera.CFrame.Position
    local direction = (targetHead.Position - origin).unit * (targetHead.Position - origin).magnitude
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {plr.Character, targetCharacter}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    return raycastResult and raycastResult.Instance ~= nil
end

local function getClosestPart(character)
    local closestPart = nil
    local shortestCursorDistance = aimFov

    for _, partName in ipairs(aimParts) do
        local part = character:FindFirstChild(partName)
        if part then
            local partPos = camera:WorldToViewportPoint(part.Position)
            local screenPos = Vector2.new(partPos.X, partPos.Y)
            local cursorDistance = (screenPos - Vector2.new(mouse.X, mouse.Y)).Magnitude

            if cursorDistance < shortestCursorDistance and partPos.Z > 0 then
                shortestCursorDistance = cursorDistance
                closestPart = part
            end
        end
    end

    return closestPart
end

local function getTarget()
    local nearestPlayer = nil
    local closestPart = nil
    local shortestCursorDistance = aimFov

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= plr and player.Character and not checkTeam(player) then
            if player.Character:FindFirstChildOfClass("Humanoid") and player.Character.Humanoid.Health >= minHealth or not healthCheck then
                local targetPart = getClosestPart(player.Character)
                if targetPart then
                    local screenPos = camera:WorldToViewportPoint(targetPart.Position)
                    local cursorDistance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude

                    if cursorDistance < shortestCursorDistance then
                        if not checkWall(player.Character) or not wallCheck then
                            shortestCursorDistance = cursorDistance
                            nearestPlayer = player
                            closestPart = targetPart
                        end
                    end
                end
            end
        end
    end

    return nearestPlayer, closestPart
end

local function predict(player, part)
    if player and part then
        local velocity = player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Velocity
        local predictedPosition = part.Position + (velocity * predictionStrength)
        return predictedPosition
    end
    return nil
end

local function smooth(from, to)
    return from:Lerp(to, smoothing)
end

local function aimAt(player, part)
    local predictedPosition = predict(player, part)
    if predictedPosition then
        if player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health >= minHealth or not healthCheck then
            local targetCFrame = CFrame.new(camera.CFrame.Position, predictedPosition)
            camera.CFrame = smooth(camera.CFrame, targetCFrame)
        end
    end
end

local currentTargetPart

connect(RunService.RenderStepped, function()
    if aimbotEnabled then
        local offset = 50
        fovCircle.Position = Vector2.new(mouse.X, mouse.Y + offset)

        if rainbowFov then
            hue = hue + rainbowSpeed
            if hue > 1 then hue = 0 end
            fovCircle.Color = Color3.fromHSV(hue, 1, 1)
        else
            if aiming and currentTarget then
                fovCircle.Color = targetedCircleColor
            else
                fovCircle.Color = circleColor
            end
        end

        if aiming then
            if stickyAimEnabled and currentTarget then
                local headPos = camera:WorldToViewportPoint(currentTarget.Character.Head.Position)
                local screenPos = Vector2.new(headPos.X, headPos.Y)
                local cursorDistance = (screenPos - Vector2.new(mouse.X, mouse.Y)).Magnitude

                if cursorDistance > aimFov or (wallCheck and checkWall(currentTarget.Character)) or checkTeam(currentTarget) then
                    currentTarget = nil
                end
            end

            if not stickyAimEnabled or not currentTarget then
                local target, targetPart = getTarget()
                currentTarget = target
                currentTargetPart = targetPart
            end

            if currentTarget and currentTargetPart then
                aimAt(currentTarget, currentTargetPart)
            end
        else
            currentTarget = nil
        end
    end
end)

connect(RunService.Heartbeat, function()
    if antiAim then
        if antiAimMethod == "Reset Velo" then
            local vel = hrp.Velocity
            hrp.Velocity = Vector3.new(antiAimAmountX, antiAimAmountY, antiAimAmountZ)
            RunService.RenderStepped:Wait()
            hrp.Velocity = vel
        elseif antiAimMethod == "Reset Pos [BROKEN]" then
            local pos = hrp.CFrame
            hrp.Velocity = Vector3.new(antiAimAmountX, antiAimAmountY, antiAimAmountZ)
            RunService.RenderStepped:Wait()
            hrp.CFrame = pos
        elseif antiAimMethod == "Random Velo" then
            local vel = hrp.Velocity
            local a = math.random(-randomVeloRange,randomVeloRange)
            local s = math.random(-randomVeloRange,randomVeloRange)
            local d = math.random(-randomVeloRange,randomVeloRange)
            hrp.Velocity = Vector3.new(a,s,d)
            RunService.RenderStepped:Wait()
            hrp.Velocity = vel
        end
    end
end)

connect(mouse.Button2Down, function()
    if aimbotEnabled then
        aiming = true
    end
end)

connect(mouse.Button2Up, function()
    if aimbotEnabled then
        aiming = false
    end
end)

Aimbot:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Flag = "Aimbot",
    Callback = function(Value)
        aimbotEnabled = Value
        fovCircle.Visible = Value
    end
})

Aimbot:CreateDropdown({
    Name = "Aim Part",
    Options = {"Head","HumanoidRootPart","Left Arm","Right Arm","Torso","Left Leg","Right Leg"},
    CurrentOption = {"Head"},
    MultipleOptions = true,
    Flag = "AimPart",
    Callback = function(Options)
        aimParts = Options
    end,
 })

Aimbot:CreateSlider({
    Name = "Smoothing",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 5,
    Flag = "Smoothing",
    Callback = function(Value)
        smoothing = 1 - (Value / 100)
    end,
})

Aimbot:CreateSlider({
    Name = "Prediction Strength",
    Range = {0, 0.2},
    Increment = 0.001,
    CurrentValue = 0.065,
    Flag = "PredictionStrength",
    Callback = function(Value)
        predictionStrength = Value
    end,
})

Aimbot:CreateToggle({
    Name = "Fov Visibility",
    CurrentValue = true,
    Flag = "FovVisibility",
    Callback = function(Value)
        fovCircle.Visible = Value
    end
})

Aimbot:CreateSlider({
    Name = "Aimbot Fov",
    Range = {0, 1000},
    Increment = 1,
    CurrentValue = 100,
    Flag = "AimbotFov",
    Callback = function(Value)
        aimFov = Value
        fovCircle.Radius = aimFov
    end,
})

Aimbot:CreateToggle({
    Name = "Wall Check",
    CurrentValue = true,
    Flag = "WallCheck",
    Callback = function(Value)
        wallCheck = Value
    end
})

Aimbot:CreateToggle({
    Name = "Sticky Aim",
    CurrentValue = false,
    Flag = "StickyAim",
    Callback = function(Value)
        stickyAimEnabled = Value
    end
})

Aimbot:CreateToggle({
    Name = "Team Check",
    CurrentValue = false,
    Flag = "TeamCheck",
    Callback = function(Value)
        teamCheck = Value
    end
})

Aimbot:CreateToggle({
    Name = "Health Check",
    CurrentValue = false,
    Flag = "HealthCheck",
    Callback = function(Value)
        healthCheck = Value
    end
})

Aimbot:CreateSlider({
    Name = "Min Health",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 0,
    Flag = "MinHealth",
    Callback = function(Value)
        minHealth = Value
    end,
})

Aimbot:CreateColorPicker({
    Name = "Fov Color",
    Color = circleColor,
    Callback = function(Color)
        circleColor = Color
        fovCircle.Color = Color
    end
})

Aimbot:CreateColorPicker({
    Name = "Targeted Fov Color",
    Color = targetedCircleColor,
    Callback = function(Color)
        targetedCircleColor = Color
    end
})

Aimbot:CreateToggle({
    Name = "Rainbow Fov",
    CurrentValue = false,
    Flag = "RainbowFov",
    Callback = function(Value)
        rainbowFov = Value
    end
})

AntiAim:CreateToggle({
    Name = "Anti-Aim",
    CurrentValue = false,
    Flag = "AntiAim",
    Callback = function(Value)
        antiAim = Value
        if Value then
            Rayfield:Notify({Title = "Anti-Aim", Content = "Enabled!", Duration = 1, Image = 4483362458,})
        else
            Rayfield:Notify({Title = "Anti-Aim", Content = "Disabled!", Duration = 1, Image = 4483362458,})
        end
    end
})

AntiAim:CreateDropdown({
    Name = "Anti-Aim Method",
    Options = {"Reset Velo","Random Velo","Reset Pos [BROKEN]"},
    CurrentOption = "Reset Velo",
    Flag = "AntiAimMethod",
    Callback = function(Option)
        antiAimMethod = type(Option) == "table" and Option[1] or Option
        if antiAimMethod == "Reset Velo" then
            Rayfield:Notify({Title = "Reset Velocity", Content = "Nobody will see it, but exploiters will aim in the wrong place.", Duration = 5, Image = 4483362458,})
        elseif antiAimMethod == "Reset Pos [BROKEN]" then
            Rayfield:Notify({Title = "Reset Pos [BROKEN]", Content = "This is a bit buggy right now, so idk if it works that well", Duration = 5, Image = 4483362458,})
        elseif antiAimMethod == "Random Velo" then
            Rayfield:Notify({Title = "Random Velocity", Content = "Depending on ping some peoplev will see u 'teleporting' around but you are actually in the same spot the entire time.", Duration = 5, Image = 4483362458,})
        end
    end,
})

AntiAim:CreateSlider({
    Name = "Anti-Aim Amount X",
    Range = {-1000, 1000},
    Increment = 10,
    CurrentValue = 0,
    Flag = "AntiAimAmountX",
    Callback = function(Value)
        antiAimAmountX = Value
    end,
})

AntiAim:CreateSlider({
    Name = "Anti-Aim Amount Y",
    Range = {-1000, 1000},
    Increment = 10,
    CurrentValue = -100,
    Flag = "AntiAimAmountY",
    Callback = function(Value)
        antiAimAmountY = Value
    end,
})

AntiAim:CreateSlider({
    Name = "Anti-Aim Amount Z",
    Range = {-1000, 1000},
    Increment = 10,
    CurrentValue = 0,
    Flag = "AntiAimAmountZ",
    Callback = function(Value)
        antiAimAmountZ = Value
    end,
})

AntiAim:CreateSlider({
    Name = "Random Velo Range",
    Range = {0, 1000},
    Increment = 10,
    CurrentValue = 100,
    Flag = "RandomVeloRange",
    Callback = function(Value)
        randomVeloRange = Value
    end,
})

-- [< Misc >]

Misc:CreateToggle({
    Name = "Spin-Bot",
    CurrentValue = false,
    Flag = "SpinBot",
    Callback = function(Value)
        spinBot = Value
        if Value then
            for i,v in pairs(hrp:GetChildren()) do
                if v.Name == "Spinning" then
                    v:Destroy()
                end
            end
            plr.Character.Humanoid.AutoRotate = false
            local Spin = newInstance("BodyAngularVelocity")
            Spin.Name = "Spinning"
            Spin.Parent = hrp
            Spin.MaxTorque = Vector3.new(0, math.huge, 0)
            Spin.AngularVelocity = Vector3.new(0,spinBotSpeed,0)
            Rayfield:Notify({Title = "Spin Bot", Content = "Enabled!", Duration = 1, Image = 4483362458,})
        else
            for i,v in pairs(hrp:GetChildren()) do
                if v.Name == "Spinning" then
                    v:Destroy()
                end
            end
            plr.Character.Humanoid.AutoRotate = true
            Rayfield:Notify({Title = "Spin Bot", Content = "Disabled!", Duration = 1, Image = 4483362458,})
        end
    end
})

Misc:CreateSlider({
    Name = "Spin-Bot Speed",
    Range = {0, 1000},
    Increment = 1,
    CurrentValue = 20,
    Flag = "SpinBotSpeed",
    Callback = function(Value)
        spinBotSpeed = Value
        if spinBot then
            for i,v in pairs(hrp:GetChildren()) do
                if v.Name == "Spinning" then
                    v:Destroy()
                end
            end
            local Spin = newInstance("BodyAngularVelocity")
            Spin.Name = "Spinning"
            Spin.Parent = hrp
            Spin.MaxTorque = Vector3.new(0, math.huge, 0)
            Spin.AngularVelocity = Vector3.new(0,Value,0)
        end
    end,
})

Misc:CreateButton({
	Name = "Server Hop",
	Callback = function()
		if httprequest then
            local servers = {}
            local req = httprequest({Url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true", game.PlaceId)})
            local body = HttpService:JSONDecode(req.Body)
        
            if body and body.data then
                for i, v in next, body.data do
                    if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= game.JobId then
                        table.insert(servers, 1, v.id)
                    end
                end
            end
        
            if #servers > 0 then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], plr)
            else
                Rayfield:Notify({Title = "Server Hop", Content = "Couldn't find a valid server!!!", Duration = 1, Image = 4483362458,})
            end
        else
            Rayfield:Notify({Title = "Server Hop", Content = "Your executor is ass!", Duration = 1, Image = 4483362458,})
        end
	end,
})

function env.stop_rocky_aimbot_modded()
    if fovCircle then fovCircle:Remove() end
    if type(Rayfield) == 'table' and type(Rayfield.Destroy) == 'function' then Rayfield:Destroy() end

    for _, instance in pairs(instances) do
        if typeof(instance) == 'Instance' then
            instance:Destroy()
        end
    end

    for _, connection in pairs(connections) do
        if typeof(connection) == 'RBXScriptConnection' and connection.Connected then
            connection:Disconnect()
        end
    end
end