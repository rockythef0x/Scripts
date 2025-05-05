local tycoons = workspace.Tycoons.Tycoons

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "No Laser Death", Text = "No Laser Death Enabled!"})
for _, v in ipairs(tycoons:GetDescendants()) do
    if v.Name == "Pipe" then
        v.CanTouch = false
    end
end

tycoons.DescendantAdded:Connect(function(descendant)
    if descendant.Name == "Pipe" then
        descendant.CanTouch = false
    end
end)
