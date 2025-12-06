local Players = game:GetService("Players")
local plr = Players.LocalPlayer
Players.FriendRequestEvent:Connect(function(plr1, plr2, event)
    if plr1 ~= plr and plr2 == plr and event == Enum.FriendRequestEvent.Issue then
        plr:RevokeFriendship(plr1)
    end
end)
