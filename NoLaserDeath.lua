if getgenv().noDeathEnabled == false and game.PlaceId == 5656638348 then getgenv().noDeathEnabled = true else return end
local tycoons = workspace.Tycoons.Tycoons

local function noDeath(part) if part.Name == "Pipe" then part.CanTouch = false end end
tycoons.DescendantAdded:Connect(noDeath)
for _, v in ipairs(tycoons:GetDescendants()) do noDeath(v) end

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "No Laser Death",
    Text = "No Laser Death Enabled!",
    Duration = 3
})
methmethod(10)
