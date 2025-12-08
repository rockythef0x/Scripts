local Lighting = game:GetService("Lighting")
local localPlr = game:GetService("Players").LocalPlayer

if getgenv().ndsscripthasRun then
    return
else
    getgenv().ndsscripthasRun = true
end

local defaultSettings = {
    ["PredictEnabled"] = true, 
    ["ChatMessage"] = false,
    ["NoStorms"] = true
}

-- Make sure the settings exist in case the loadstring is outdated
if getgenv().ndsSettings then
    for i, v in pairs(defaultSettings) do
        if not ndsSettings[i] then
            ndsSettings[i] = v
        end
    end
else
    getgenv().ndsSettings = table.clone(defaultSettings)
end 


local function notifyUser(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = title, Text = text, Duration = math.huge, Button1 = "Okay"})
end

notifyUser("Prediction Enabled", "Disaster Prediction has been enabled!", 3)
local predictConnection
local addedConnection
local function main()
    local char = localPlr.Character or localPlr.CharacterAdded:Wait()
    addedConnection = char.ChildAdded:Connect(function(child)
        local function predict()
            if ndsSettings.PredictEnabled then
                notifyUser("Next Disaster", "Next Disaster is: " .. child.Value, ndsSettings.NotifyTime)
                if ndsSettings.ChatMessage == true then
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
main()

localPlr.CharacterAdded:Connect(main)
localPlr.CharacterRemoving:Connect(function()
    addedConnection:Disconnect()
    if predictConnection then predictConnection:Disconnect() end
end)

Lighting:GetPropertyChangedSignal("FogEnd"):Connect(function()
    if ndsSettings.NoStorms then
        Lighting.FogEnd = 100000
    end
end)

localPlr.PlayerGui.ChildAdded:Connect(function(gui)
    if ndsSettings.NoStorms == true then
        if table.find({"SandStormGui", "BlizzardGui"}, gui.Name) then
            gui.Enabled = false
        end
    end
end)
