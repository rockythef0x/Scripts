local Lighting = game:GetService("Lighting")
local localPlr = game:GetService("Players").LocalPlayer
if getgenv().ndsscripthasRun then
    return
else
    getgenv().ndsscripthasRun = true
end

-- Default settings if they didn't get set
-- I know my method to do this is ass
if getgenv().predictEnabled == nil then
    getgenv().predictEnabled = true
end
if getgenv().chatMessage == nil then
    getgenv().chatMessage = false
end
if getgenv().noStormEffect == nil then
    getgenv().noStormEffect = true
end
if getgenv().notifyTime == nil or not tonumber(getgenv().notifyTime) then
	getgenv().notifyTime = 10
end

local function notifyUser(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = title, Text = text, Duration = duration})
end

notifyUser("Prediction Enabled", "Disaster Prediction has been enabled!", 3)
local predictConnection = nil
local addedConnection = nil
local function thingyidk()
    local char = localPlr.Character or localPlr.CharacterAdded:Wait()
    addedConnection = char.ChildAdded:Connect(function(child)
        local function predict()
            if getgenv().predictEnabled == true then
                notifyUser("Next Disaster", "Next Disaster is: " .. child.Value, getgenv().notifyTime)
                if getgenv().chatMessage == true then
                    game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync("Next Disaster is: " .. child.Value)
                end
            end
        end

        if child.Name == "SurvivalTag" then
            predict()
            predictConnection = child.Changed:Connect(predict)
        end
    end)
end
thingyidk()

localPlr.CharacterAdded:Connect(thingyidk)
localPlr.CharacterRemoving:Connect(function()
    addedConnection:Disconnect()
    if predictConnection then predictConnection:Disconnect() end
end)

Lighting:GetPropertyChangedSignal("FogEnd"):Connect(function()
    if getgenv().noStormEffect then
        Lighting.FogEnd = 100000
    end
end)

localPlr.PlayerGui.ChildAdded:Connect(function(gui)
    if getgenv().noStormEffect == true then
        if gui.Name == "SandStormGui" or gui.Name == "BlizzardGui" then
            gui.Enabled = false
        end
    end
end)
