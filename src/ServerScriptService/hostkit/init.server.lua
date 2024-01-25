-- [ services ] --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local Teams = game:GetService("Teams")

-- [ modules ] --
local Castaways = require(ReplicatedStorage:WaitForChild("Castaways"):WaitForChild("Castaways"))

-- [ objects ] --
local HostCommunication: RemoteEvent = ReplicatedStorage:WaitForChild("HostCommunication")
local HostKitObjects, HostKitWorkspace = ServerStorage:WaitForChild("HostKitObjects"), workspace:FindFirstChild("HostKitWorkspace")
local WorkspaceComps, WorkspaceMusic, ObjectComps, ObjectMusic = HostKitWorkspace.Competitions, HostKitWorkspace.Music, HostKitObjects.Competitions, HostKitObjects.Music
local GameRules = ReplicatedStorage.GameRules

-- [ variables ] --
local groupTeams = {
	["Host"] = {255, 254, 120, 100},
	["Muerte"] = {4},
	["Alma"] = {5}
}

local playerTeams = {}

-- [ functions ] --
-- Collect all of the available assets for the host kit and send it to the client.
local comps, music = {}, {}
for _, comp in pairs (ObjectComps:GetChildren()) do
    table.insert(comps, comp.Name)
end
for _, song in pairs (ObjectMusic:GetChildren()) do
    table.insert(music, song.Name)
end

Players.PlayerAdded:Connect(function(player)
	-- Fetches the rank of the player who joined the game.
	local rank = player:GetRankInGroup(15523570)

	-- Creates a new Motor6D on the player's right arm for animating tools with moving parts.
	player.CharacterAdded:Connect(function(char)
		-- If the player is high enough rank in the group, then send them the host data.
		if rank >= 100 then
			local data = {comps, music, Castaways.castawaysOrder}
			HostCommunication:FireClient(player, "AddHostKitData", data)
		end

		local M6D = Instance.new("Motor6D")
		M6D.Parent = char["Right Arm"]
		M6D.Part0 = char["Right Arm"]
		M6D.Name = "ToolGrip"

		char.ChildAdded:Connect(function(child)
			if child:IsA("Tool") and child:FindFirstChild("BodyAttach") then
				M6D.Part1 = child.BodyAttach
			end
		end)
	end)

	-- If their rank is found in the Teams table, respawn them at the proper team.
	for name, list in pairs (groupTeams) do
		for _, r in pairs (list) do
			if rank == r then
				player.Team = Teams[name]
				player:LoadCharacter()
			end
		end
	end

	-- If their name is found in the Players table, respawn them at the proper team.
	-- Used for alts only.
	for name, team in pairs (playerTeams) do
		if name == player.Name then
			player.Team = Teams[team]
			player:LoadCharacter()
		end
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

        if key == "ChangeGameRule" then
            -- Toggle a gamerule for all current players.
            GameRules[info].Value = not GameRules[info].Value
            return;
        end
    end

    -- Refresh a castaway who asks to be refreshed.
    if key == "ResetCharacter" then
        if ReplicatedStorage.GameRules.CanRefresh.Value then
            local character = plr.Character or nil

            if character then
                -- Store the player's current position and WalkSpeed before resetting their avatar.
                local position = character.HumanoidRootPart.CFrame
                local walkSpeed = character.Humanoid.WalkSpeed

                -- Refresh the player's character.
                plr:LoadCharacter()

                -- Reposition the character with their previous settings.
                plr.Character:PivotTo(position)
                plr.Character.Humanoid.WalkSpeed = walkSpeed
            end

            return;
        end
    end
end)

while true do
	if not ReplicatedStorage.GameRules.ClockPaused.Value then
		game.Lighting.ClockTime += 0.016667
	end
	task.wait(1)
end