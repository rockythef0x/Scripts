local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local StarterGui = cloneref(game:GetService("StarterGui"))

local function notify(title, text)
    StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = 3})
end

if not hookmetamethod then return notify('Incompatible Exploit','Your exploit does not support this command (missing hookmetamethod)') end
local oldName; oldName = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod():lower()
    if self == plr and method == "kick" or method == "destroy" then
        return
    end

    return oldName(self, ...)
end)

local oldnIndex; oldnIndex = hookmetamethod(game, "__newindex", function(self, key, value)
    if self == plr and key:lower() == "parent" then
        return
    end

    return oldnIndex(self, key, value)
end)

hookfunction(plr.Kick, newcclosure(function() end))
notify("Anti Kick", "Client anti kick enabled (Only effective on kicks initiated from the client!)")
