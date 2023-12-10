local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ProfileService = require(ReplicatedStorage.Packages["profileservice-fork"])
local DataTemplate = require(ReplicatedStorage.Shared.PlayerData)
local UpdateState = require(ReplicatedStorage.Shared.Functions.UpdateState)
local Remotes = ReplicatedStorage.Remotes.PlayerData

export type UpdateDataAction = UpdateState.UpdateDataAction

local DATASTORE_NAME = "Production" -- DO NOT MODIFY

if RunService:IsStudio() then
    DATASTORE_NAME = "Testing"
end

local ProfileStore = ProfileService.GetProfileStore(DATASTORE_NAME, DataTemplate.DEFAULT_PLAYER_DATA)
export type Profile = {
    Data: UpdateState.PlayerData,
    Release: () -> void
 }
local Profiles: { [Player] : Profile } = {}

local Local = {}
local Shared = {}

Shared.ProfileLoaded = Instance.new("BindableEvent")

function Shared.OnStart()
    for _, player in Players:GetPlayers() do
        Local.CreateProfile(player)
    end

    Players.PlayerAdded:Connect(Local.CreateProfile)
    Players.PlayerRemoving:Connect(Local.RemoveProfile)

    Remotes.GetData.OnServerInvoke = Local.FetchPlayerData
end

function Shared.GetState(player: Player)
    local profile = Profiles[player]
    if profile then
        return profile.Data
    end
end

function Shared.UpdateState(player: Player, action: UpdateState.UpdateDataAction)
    local profile = Profiles[player]
    if not profile then
        return false
    end

    local function UpdateLeaderstats(action: UpdateState.UpdateDataAction)
        if action.type == "UpdateStage" then
            player.leaderstats.Stage.Value += action.amount
        elseif action.type == "UpdateDeaths" then
            player.leaderstats.Deaths.Value += action.amount
        end
    end

    UpdateLeaderstats(action)
    UpdateState(profile.Data, action)
    Remotes.UpdateData:FireClient(player, action)
end

--

function Local.CreateLeaderstats(player: Player, data: UpdateState.PlayerData)
    local leaderstats = Instance.new("Folder", player)
    leaderstats.Name = "leaderstats"

    local stage = Instance.new("NumberValue", leaderstats)
    stage.Name = "Stage"
    stage.Value = data.stage

    local rebirths = Instance.new("NumberValue", leaderstats)
    rebirths.Name = "Rebirths"
    rebirths.Value = data.rebirths
end

function Local.CreateProfile(player: Player)
    local userId = player.UserId
    local profileKey = `{userId}_Data`
    local profile = ProfileStore:LoadProfileAsync(profileKey)

    if not profile then
        player:Kick()
        return
    end

    profile:ListenToRelease(function()
        Profiles[player] = nil
        player:Kick()
    end)

    profile:AddUserId(userId)
    profile:Reconcile()

    Profiles[player] = profile
    Local.CreateLeaderstats(player, profile.Data)
    task.delay(1, function()
        Shared.ProfileLoaded:Fire(player)
    end)
end

function Local.RemoveProfile(player: Player)
    local profile = Profiles[player]
    if profile then
        profile:Release()
    end
end

function Local.FetchPlayerData(player: Player)
    local profile = Profiles[player]
    if not profile then
        return false
    end
    return profile.Data
end

return Shared
