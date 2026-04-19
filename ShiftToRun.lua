local cloneref = cloneref or function(...) return ... end
local UserInputService = game:GetService("UserInputService")
local TweenService = cloneref(cloneref(game:GetService("TweenService")))

local plr = game:GetService("Players").LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

local mouseLockController = cloneref(plr.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("CameraModule"):WaitForChild("MouseLockController"))
local boundKeys = cloneref(mouseLockController:FindFirstChild("BoundKeys"))

-- Configurations
local config = {
	["FovChange"] = true, -- Whether to do the zoomed out FOV effect while running (default is true)
	["Fov"] = 80, -- What the sprinting FOV will be (Roblox default is 70, script default is 80)
	["ChangeTime"] = 0.40, -- Adjusts the time for the speed and FOV change (script default is 0.40)
	["Speed"] = 30, -- The speed to use while running (Roblox default is 16, script default is 30)
	["UseCtrlLock"] = true -- Whether to bind Shiftlock to Ctrl so it doesn't conflict with sprinting (default is true)
}

if config.UseCtrlLock then
	if boundKeys then
		boundKeys.Value = "LeftControl"
	else
		boundKeys = Instance.new("StringValue")
		boundKeys.Name = "BoundKeys"
		boundKeys.Value = "LeftControl"
		boundKeys.Parent = mouseLockController
	end
end

local oldFov = workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView
local tweenInfo = TweenInfo.new(config.ChangeTime, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
UserInputService.InputBegan:Connect(function(input, processed)
	if input.KeyCode == Enum.KeyCode.LeftShift and not processed then
		local speed = TweenService:Create(humanoid, tweenInfo, {["WalkSpeed"] = config.Speed})
		speed:Play()

		if config.FovChange == true and workspace.CurrentCamera then
			local tween = TweenService:Create(workspace.CurrentCamera, tweenInfo, {["FieldOfView"] = config.Fov})
			tween:Play()
		end
	end
end)

UserInputService.InputEnded:Connect(function(input, processed)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		local speed = TweenService:Create(humanoid, tweenInfo, {["WalkSpeed"] = game:GetService("StarterPlayer").CharacterWalkSpeed})
		speed:Play()

		if config.FovChange == true and workspace.CurrentCamera and oldFov then
			local tween = TweenService:Create(workspace.CurrentCamera, tweenInfo, {["FieldOfView"] = oldFov})
			tween:Play()
		end
	end
end)
