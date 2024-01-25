-- [ functions ] --
local Lighting, ReplicatedStorage, RunService, TweenService = game:GetService("Lighting"), game:GetService("ReplicatedStorage"), game:GetService("RunService"), game:GetService("TweenService")

-- Reference the Host Gui, as well as various sections of the Gui.
local HostGui = script.Parent
local System = HostGui.Container.System;
local Picker, SystemContainer, Title = System.Picker, System.SystemContainer, System.Title
local Competitions, Music, Settings, Vote = SystemContainer.Comps, SystemContainer.Music, SystemContainer.Settings, SystemContainer.Vote
local TimeOfDay = System.TimeOfDay

-- Reference the RemoteEvent for client-to-server communication.
local HostCommunication = ReplicatedStorage:WaitForChild("HostCommunication")
local GameRules = ReplicatedStorage.GameRules

-- [ variables ] --
local tweenDebounce = false
local currentlyOn, voteCounter = 1, 0
local checkingForIdols = HostGui.CheckingForIdols

-- [ functions ] --

-- Fetch the data from the server when the client joins the game.
HostCommunication.OnClientEvent:Connect(function(key, data)
    if key == "AddVoteButtonsToList" then
        Vote.StartVote.BackgroundColor3 = Color3.fromRGB(146, 255, 138)
        Vote.StartVote.Text = "End Vote Collecting"

        Vote.SelectCastaways.Visible = false
        Vote.CollectedVotes.Visible = true
    elseif key == "UpdateVoteTable" or key == "UpdateIdolTable" then
        print(data)
        for _, castaway in pairs (Vote.SelectCastaways.Container:GetChildren()) do
            if castaway:IsA("Frame") then
                if table.find(data, castaway.Name) then
                    castaway.Button.BackgroundColor3 = Color3.fromRGB(146, 255, 138)
                else
                    castaway.Button.BackgroundColor3 = Color3.new(1, 1, 1)
                end
            end
        end
    elseif key == "UpdateVoteCount" then
        Vote.CollectedVotes.TextLabel.Text = "Votes Collected: " .. data
    elseif key == "VotesSorted" then
        Vote.StartVote.BackgroundColor3 = Color3.fromRGB(255, 148, 148)
        voteCounter = data
        currentlyOn = 1

        Vote.StartVote.Text = "Start Vote Reveal [0 / " .. voteCounter .. "]"
    elseif key == "VotesError" then
        local origColor, origText = Vote.StartVote.BackgroundColor3, Vote.StartVote.Text
        Vote.StartVote.BackgroundColor3 = Color3.fromRGB(255, 79, 79)
        Vote.StartVote.Text = data

        task.wait(1)

        Vote.StartVote.BackgroundColor3 = origColor
        Vote.StartVote.Text = origText
    elseif key == "OpenIdolTable" then
        Vote.StartVote.BackgroundColor3 = Color3.fromRGB(255, 148, 148)
        Vote.StartVote.Text = "Confirm Idoled Players"

        for _, frame in pairs (Vote.SelectCastaways.Container:GetChildren()) do
            if frame:IsA("Frame") and not table.find(data, frame.Name) then
                frame.Visible = false
            end
        end

        Vote.SelectCastaways.Visible = true
        Vote.CollectedVotes.Visible = false
    elseif key == "ResetVotingBoard" then
        Vote.SelectCastaways.Visible = true
        Vote.CollectedVotes.Visible = false
        Vote.StartVote.BackgroundColor3 = Color3.fromRGB(255, 148, 148)
        currentlyOn = 1
        voteCounter = 0

        for _, frame in pairs (Vote.SelectCastaways.Container:GetChildren()) do
            if frame:IsA("Frame") then
                frame.Visible = true
            end
        end

        Vote.CollectedVotes.TextLabel.Text = "Votes Collected: 0"
        Vote.StartVote.Text = "Start Tribal Council"
    elseif key == "ForceKill" then
        HostCommunication:FireServer("EndTribal")
    end
end)

-- Remove certain features if the "kill all" buttons in each menu are pressed.
Competitions.Clear.MouseButton1Up:Connect(function()
    HostCommunication:FireServer("ClearComps")
end)

-- For every game rule in the Settings GUI, change it on the Settings folder.
for _, button in pairs (Settings:GetChildren()) do
    if button:IsA("TextButton") then
        RunService.Heartbeat:Connect(function()
            if GameRules[button.Name].Value then
                button.BackgroundColor3 = Color3.fromRGB(146, 255, 138)
                button.Text = button.Name .. ": ON"
            else
                button.BackgroundColor3 = Color3.fromRGB(255, 148, 148)
                button.Text = button.Name .. ": OFF"
            end
        end)

        button.MouseButton1Up:Connect(function()
            HostCommunication:FireServer("ChangeGameRule", button.Name)
        end)
    end
end

-- Start the Tribal Council period for all players.
Vote.StartVote.MouseButton1Up:Connect(function()
    if Vote.StartVote.Text == "Start Tribal Council" then
        HostCommunication:FireServer("StartVote")
    elseif Vote.StartVote.Text == "End Vote Collecting" then
        HostCommunication:FireServer("CheckForIdols")
        checkingForIdols.Value = true
    elseif Vote.StartVote.Text == "Confirm Idoled Players" then
        HostCommunication:FireServer("SortVotes")
        Vote.SelectCastaways.Visible = false
        checkingForIdols.Value = false
    elseif string.match(Vote.StartVote.Text, "Start Vote Reveal") then
        if currentlyOn <= voteCounter then
            HostCommunication:FireServer("RevealVote", currentlyOn)

            currentlyOn += 1
            Vote.StartVote.Text = "Start Vote Reveal [" .. currentlyOn - 1 .. " / " .. voteCounter .. "]"
            print(currentlyOn .. " : " .. voteCounter)
        else
            HostCommunication:FireServer("EndTribal")
        end
    end
end)

-- Moves the Guis on or off the screen on user interaction.
Title.MouseButton1Up:Connect(function()
    if not tweenDebounce then
        tweenDebounce = true

        local verticalPos = if System.Position == UDim2.new(0.5, 0, 1.13, 0) then 0.6 else 1.13
        local background = if verticalPos == 1.13 then 1 else 0.6

        TweenService:Create(
            System,
            TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {
                Position = UDim2.new(0.5, 0, verticalPos, 0)
            }
        ):Play()

        TweenService:Create(
            System.Parent.Gradient,
            TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {
                ImageTransparency = background
            }
        ):Play()

        task.wait(0.8)
        tweenDebounce = false
    end
end)
-- Updates the TimeOfDay tag on the player's screen to show them the current sun position.
Lighting:GetPropertyChangedSignal("TimeOfDay"):Connect(function()
	-- Fetch the current ClockTime.
	local clock = Lighting.ClockTime

	-- If the clock time is more than 12, show PM to signify the afternoon.
	local suffix = if clock > 12 then "PM" else "AM"

	-- Get the current hour of the time.
	local hourNum = tonumber(string.sub(Lighting.TimeOfDay, 1, 2))

	-- Add a Day or Night tag at the beginning depending on the time of day.
	local caption = "🌕 Night"
    if hourNum == 15 then
        caption = "🌙 Dusk"
    elseif hourNum == 5 then
        caption = "⛅ Dawn"
    elseif hourNum > 5 and hourNum < 15 then
        caption = "☀️ Day"
    end

	-- Round the hour number down to format in 12-hour time and not military time.
	if hourNum > 13 then
		hourNum -= 12
	elseif hourNum == 0 then
		hourNum = 12
	end

	-- Display the time of day.
	TimeOfDay.Text = caption .. ": " .. hourNum .. ":" .. string.sub(Lighting.TimeOfDay, 4, 5) .. " " .. suffix
end)

-- Changes the menu when the player clicks a different host panel.
for _, bn in pairs (Picker:GetDescendants()) do
	if bn:IsA("TextButton") then
		local title = bn.Parent.Name

		-- When a button is pressed, hide all of the other menus.
		bn.MouseButton1Up:Connect(function()
			for _, f in pairs (SystemContainer:GetChildren()) do
				if f:IsA("Frame") then
					f.Visible = false;
				end
			end

			-- Enable the menu if it is found (used internally to prevent crashing).
			if SystemContainer:FindFirstChild(title) then
				SystemContainer[title].Visible = true
			end
		end)
	end
end