-- [ services ] --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")

-- [ objects ] --
local HostCommunication: RemoteEvent = ReplicatedStorage.HostCommunication
local HostKitObjects, HostKitWorkspace = ServerStorage.HostKitObjects, workspace.HostKitWorkspace
local WorkspaceComps, WorkspaceMusic, ObjectComps, ObjectMusic = HostKitWorkspace.Competitions, HostKitWorkspace.Music, HostKitObjects.Competitions, HostKitObjects.Music
local GameRules = HostKitObjects.GameRules

-- [ functions ] --

-- Collect all of the available assets for the host kit and send it to the client.
local comps, music, rules = {}, {}, {}
for _, comp in pairs (ObjectComps:GetChildren()) do
    table.insert(comps, comp.Name)
end
for _, song in pairs (ObjectMusic:GetChildren()) do
    table.insert(music, song.Name)
end
for _, rule in pairs (GameRules:GetChildren()) do
    table.insert(rules, rule.Name)
end

Players.PlayerAdded:Connect(function(player)
    if player:GetRankInGroup(15523570) >= 100 then
        local data = {comps, music, rules}
        HostCommunication:FireClient(player, "AddData", data)
    end
end)

HostCommunication.OnServerEvent:Connect(function(plr, key, info)
    -- Only players who are highly ranked in the group can use the UI.
    if plr:GetRankInGroup(15523570) >= 100 then

        -- If a competition is found, then remove it. If not, add a copy of it to the game.
        if key == "SpawnComp" then
            if not WorkspaceComps:FindFirstChild(info) then
                if ObjectComps:FindFirstChild(info) then
                    ObjectComps[info]:Clone().Parent = WorkspaceComps
                end
            else
                WorkspaceComps[info]:Destroy()
            end
            return;
        elseif key == "ClearComps" then
            WorkspaceComps:ClearAllChildren()
            return;
        end

        if key == "PlayMusic" then

            -- Fade out the currently playing audio track.
            TweenService:Create(
                WorkspaceMusic,
                TweenInfo.new(2),
                {
                    Volume = 0
                }
            ):Play()
            task.wait(2.2)
            WorkspaceMusic.Playing = false

            WorkspaceMusic.Volume = 0.7
            WorkspaceMusic.TimePosition = 0
            WorkspaceMusic.SoundId = ObjectMusic[info].SoundId
            WorkspaceMusic.Playing = true
            return;
        elseif key == "KillMusic" then
            WorkspaceMusic.Volume = 0
            WorkspaceMusic.Playing = false
            return;
        end

        if key == "ChangeRule" then
            -- Toggle a gamerule for all current players.
            GameRules[info].Value = not GameRules[info].Value
            return;
        end
    end
end)