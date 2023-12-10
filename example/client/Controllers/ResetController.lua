local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

local GuiController = require(script.Parent.GuiController)
local RespawnController = require(script.Parent.RespawnController)
local SoundsConfig = require(ReplicatedStorage.Shared.Configs.Sounds)

local Button = GuiController.Guis.RightButtons.Frame.Reset

local Local = {}
local Shared = {}

function Shared.OnStart()
    Button.MouseButton1Click:Connect(Local.Reset)
    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then return end
        if input.KeyCode == Enum.KeyCode.R then
            Local.Reset()
        end
    end)
end

function Local.Reset()
    local character = Player.Character
    if character then
        RespawnController.ForceTeleportPlayer(character)
        SoundsConfig.PlaySound("Error")
    end
end


return Shared
