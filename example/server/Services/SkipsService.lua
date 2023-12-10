local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataService = require(ServerScriptService.Services.PlayerDataService)
local ProgressService = require(ServerScriptService.Services.ProgressService)
local RespawnService = require(ServerScriptService.Services.RespawnService)
local StagesConfig = require(ReplicatedStorage.Shared.Configs.Stages)
local Remotes = ReplicatedStorage.Remotes

local PlayerRewardTimes = {}

local Local = {}
local Shared = {}

function Shared.OnStart()
    task.spawn(Local.GiveSkip)

    Remotes.SkipStage.OnServerEvent:Connect(Shared.SkipStage)

    Players.PlayerRemoving:Connect(function(player: Player)
        PlayerRewardTimes[player] = nil
    end)
end

function Local.GiveSkip()
    while true do
        pcall(function()
            for _, player in Players:GetPlayers() do
                local nextSkipTime = PlayerRewardTimes[player]
                if not nextSkipTime then
                    PlayerRewardTimes[player] = os.time() + 120
                    continue
                end

                local secondsLeft = nextSkipTime - os.time()
                if secondsLeft <= 0 then
                    local state = DataService.GetState(player)
                    if not state then
                        continue
                    end

                    local isVIP = state.vip
                    local skipAction: DataService.UpdateDataAction = {
                        type = "UpdateSkips",
                        amount = if isVIP then 2 else 1,
                    }

                    DataService.UpdateState(player, skipAction)
                    PlayerRewardTimes[player] = os.time() + 120
                end
            end
        end)
        task.wait(1)
    end
end

function Shared.SkipStage(player: Player)
    local state = DataService.GetState(player)
    if not state then
        return
    end

    local hasSkips = state.skips > 0
    if not hasSkips then
        return
    end

    local isMaxStage = state.stage >= StagesConfig.TOTAL_STAGES
    if isMaxStage then
        return
    end

    local newStage = state.stage + 1
    local spawnLocation = StagesConfig.GetSpawnLocation(newStage)
    if not spawnLocation then
        return
    end

    ProgressService.TouchSpawnLocation(player, spawnLocation)
    RespawnService.RespawnPlayer(player)

    local skipAction: DataService.UpdateDataAction = {
        type = "UpdateSkips",
        amount = -1,
    }
    DataService.UpdateState(player, skipAction)
end

return Shared
