print("No Laser Death Enabled!")
for _, v in ipairs(workspace.Tycoons["Tycoons"]:GetDescendants()) do
    if v.Name == "Pipe" then
        v.CanTouch = false
    end
end

workspace.Tycoons["Tycoons"].DescendantAdded:Connect(function(descendant)
    if descendant.Name == "Pipe" then
        descendant.CanTouch = false
    end
end)
