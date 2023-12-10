local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local StateController = require(script.Parent.StateController)
local SettingsConfig = require(ReplicatedStorage.Shared.Configs.Settings)
local SoundsConfig = require(ReplicatedStorage.Shared.Configs.Sounds)

local ALWAYS_ENABLED_GUIS = {
    "Top",
    "RightButtons",
    "LeftButtons",
    "Effects",
}

local BlurEffect = Instance.new("BlurEffect", Lighting)
BlurEffect.Size = 0

local Local = {}
local Shared = {}

Shared.BillboardGuis = {

}

Shared.Guis = {

}

function Shared.OnStart()

end

function Shared.ToggleBlurEffect(isGuiActive)

end

function Shared.OpenGui(gui: ScreenGui)

end

function Shared.SetupClosing(gui: ScreenGui)

end

function Shared.SetupOpening(gui: ScreenGui, button: GuiButton)

end

function Shared.SetupHidingNotifications(openGui: ScreenGui, notificationHolder: Instance)

end

function Shared.HandleProgressBar(progressBar: Frame, percentCompleted: number, percentText: string?)

end

function Local.HideTemplates()

end

return Shared
