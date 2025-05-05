local Lighting = game:GetService("Lighting")
local localPlr = game:GetService("Players").LocalPlayer
if getgenv().ndsscripthasRun then
    return
else
    getgenv().ndsscripthasRun = true
end

-- Settings defaults cuz some people might run without
-- I know my method to do this is ass be quiet
if getgenv().predictEnabled == nil then
    getgenv().predictEnabled = true
end
if getgenv().chatMessage == nil then
    getgenv().chatMessage = false
end
if getgenv().removestormGuis == nil then
    getgenv().removestormGuis = true
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
                notifyUser("Next Disaster", "Next Disaster is: " .. child.Value, 10)
                if getgenv().chatMessage == true then
                    game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync("Next Disaster is: " .. child.Value)
                end
            end
        end

        if child.Name == "SurvivalTag" then
            predict()
            predictConnection = child:GetPropertyChangedSignal("Value"):Connect(predict)
        end
    end)
end
thingyidk()

localPlr.CharacterAdded:Connect(thingyidk)
localPlr.CharacterRemoving:Connect(function()
    addedConnection:Disconnect()
    predictConnection:Disconnect()
end)

localPlr.PlayerGui.ChildAdded:Connect(function(gui)
    if getgenv().removestormGuis == true then
        if gui.Name == "SandStormGui" or gui.Name == "BlizzardGui" then
            gui.Enabled = false
			task.wait(1.5)
			Lighting.FogEnd = 100000
			for i,v in pairs(Lighting:GetDescendants()) do
				if v:IsA("Atmosphere") then
					v:Destroy()
				end
			end
        end
    end
end)
