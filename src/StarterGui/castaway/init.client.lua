-- [ functions ] --
local Lighting, Players, ReplicatedStorage, RunService, TweenService = game:GetService("Lighting"), game:GetService("Players"), game:GetService("ReplicatedStorage"), game:GetService("RunService"), game:GetService("TweenService")

-- [ objects ] --
local player: Player = Players.LocalPlayer;
local HostCommunication = ReplicatedStorage.HostCommunication

-- Reference the Castaway Gui, as well as various sections of the Gui.
local CastawayGui = script.Parent
local System = CastawayGui.Container.System
local Camps, Lag, Title, Reset, TimeOfDay = System.Camps, System.Lag, System.Title, System.Reset, System.TimeOfDay

-- [ variables ] --
local tweenDebounce = false
local lagSetting = 2

-- [ variables ] --
local whitelist = {
    "Muerte",
    "Alma",
    "Purgatorio"
}

-- [ functions ] --

-- Checks if the player can access the specified Guis.
RunService.Heartbeat:Connect(function()
    -- Check if the player can access the GU by checking if their team is on the whitelist.
    if player.Team and table.find(whitelist, player.Team.Name) then
        CastawayGui.Enabled = true

        -- Remove any camp cards with the same name as the player. This prevents them from removing their own camp.
        for _, card in pairs (Camps.Items:GetChildren()) do
            if card:IsA("Frame") then
                card.Visible = true
                if card.Name == player.Team.Name then
                    card.Visible = false
                end

                -- Notifies the user if the camp is successfully spawned.
                if workspace.Camps:FindFirstChild(card.Name .. " Camp") then
                    card.Button.Text = "ON"
                    card.Button.BackgroundColor3 = Color3.fromRGB(89, 255, 89)
                else
                    card.Button.Text = "OFF"
                    card.Button.BackgroundColor3 = Color3.fromRGB(226, 71, 71);
                end
            end
        end
    else
        CastawayGui.Enabled = false
    end

    -- This is o(n^2). It works; just won't scale.
    -- Worst case scenario is <10 checks so I literally do not care.
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

-- Allows the user to despawn and respawn the camps of other tribes.
for _, camp in pairs (Camps.Items:GetChildren()) do
    if camp:IsA("Frame") then
        local title = camp.Name
        camp.Button.MouseButton1Up:Connect(function()
            if workspace.Camps:FindFirstChild(title .. " Camp") then
                workspace.Camps[title .. " Camp"]:Destroy()
            else
                ReplicatedStorage.Camps[title .. " Camp"]:Clone().Parent = workspace.Camps
            end
        end)
    end
end

-- Removes certain parts according to the specific "lag setting".
for _, mode in pairs (Lag.Items.Settings:GetChildren()) do
    if mode:IsA("TextButton") then
        RunService.Heartbeat:Connect(function()
            if mode.Text == tostring(lagSetting) then
                mode.BackgroundColor3 = Color3.fromRGB(89, 255, 89)
            else
                mode.BackgroundColor3 = Color3.new(1, 1, 1)
            end
        end)

        mode.MouseButton1Up:Connect(function()
            lagSetting = tonumber(mode.Text)

            for _, part in pairs (workspace:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Model") then
                    if part:FindFirstChild("LagSetting") then
                        local lagValue = part.LagSetting.Value

                        if lagValue > lagSetting then
                            local parentHolder = Instance.new("ObjectValue")
                            parentHolder.Name = "ParentHolder"
                            parentHolder.Parent = part
                            parentHolder.Value = part.Parent

                            part.Parent = ReplicatedStorage.RemovedObjects
                        end
                    end
                end
            end

            if #ReplicatedStorage.RemovedObjects:GetChildren() > 0 then
                for _, part in pairs (ReplicatedStorage.RemovedObjects:GetDescendants()) do
					if part:IsA("BasePart") or part:IsA("Model") then
						if part:FindFirstChild("LagSetting") then
							local lagValue = part.LagSetting.Value

							if lagValue <= lagSetting then
								part.Parent = part.ParentHolder.Value
								part.ParentHolder:Destroy()
							end
						end
                    end
                end
            end
        end)
    end
end

-- Prompts the server to reset the player's avatar when the Reset button is pressed.
Reset.Refresh.MouseButton1Up:Connect(function()
    HostCommunication:FireServer("ResetCharacter")
end)

-- Updates the TimeOfDay tag on the player's screen to show them the current sun position.
Lighting:GetPropertyChangedSignal("TimeOfDay"):Connect(function()
	-- Get the current hour of the time.
	local hourNum = tonumber(string.sub(Lighting.TimeOfDay, 1, 2))

	-- Add a Day or Night tag at the beginning depending on the time of day.
    -- 17 to 6 is Night, 16 and 17 and 6 to 7 is Dusk / Dawn, else is day
	local caption = "🌕 Night"
    if hourNum == 15 then
        caption = "🌙 Dusk"
    elseif hourNum == 5 then
        caption = "⛅ Dawn"
    elseif hourNum > 5 and hourNum < 15 then
        caption = "☀️ Day"
    end

	-- Display the time of day.
	TimeOfDay.Text = caption
end)