local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts

local IsServer = RunService:IsServer()
local RootDirectory = if IsServer then ServerScriptService else Players.LocalPlayer:WaitForChild("PlayerScripts")
local ModuleDirectory = if IsServer then RootDirectory.Services else RootDirectory:WaitForChild("Controllers")

local function RequireModule(moduleScript: Instance)
	if moduleScript:IsA("ModuleScript") then
		local import = require(moduleScript)

		local onStart = import.OnStart
		if onStart then
			onStart()
		end
	end
end

return function()
	if IsServer then
		for _, child in ModuleDirectory:GetChildren() do
			RequireModule(child)
		end
	else
		for _, child in StarterPlayerScripts.Controllers:GetChildren() do
			local module = ModuleDirectory:WaitForChild(child.Name)
			RequireModule(module)
		end
	end
end
