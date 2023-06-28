-- [ functions ] --
local Players, ReplicatedStorage, RunService, TweenService = game:GetService("Players"), game:GetService("ReplicatedStorage"), game:GetService("RunService"), game:GetService("TweenService")

-- [ objects ] --
local player: Player = Players.LocalPlayer;

-- Reference the Host Gui, as well as various sections of the Gui.
local HostGui = script.Parent
local System = HostGui.Container.System;
local Picker, SystemContainer, Title = System.Picker, System.SystemContainer, System.Title
local Competitions, Music, Rules = SystemContainer.Comps, SystemContainer.Music, SystemContainer.Rules

-- Reference the RemoteEvent for client-to-server communication.
local HostCommunication = ReplicatedStorage.HostCommunication

-- [ variables ] --
local tweenDebounce = false

-- [ functions ] --
-- When a menu button is pressed in the Picker, display the proper host menu in the SystemContainer.
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

-- Fetch the data from the server when the client joins the game.
HostCommunication.OnClientEvent:Connect(function(key, data)
    if key == "AddData" then
        print("Received")

        -- Adds new button sets for each of the relevant data containers sent from the server.
        local CompsTemplate = Competitions.Scroller.Template
        for _, comp in pairs (data[1]) do
            local bn = CompsTemplate:Clone()

            bn.Name = comp
            bn.Text = comp
            bn.Parent = CompsTemplate.Parent

            bn.MouseButton1Up:Connect(function()
                HostCommunication:FireServer("SpawnComp", bn.Name)
            end)

            RunService.Heartbeat:Connect(function()
                if workspace.HostKitWorkspace.Competitions:FindFirstChild(bn.Name) then
                    bn.BackgroundColor3 = Color3.fromRGB(118, 118, 118)
                    bn.TextColor3 = Color3.new(1, 1, 1)
                else
                    bn.BackgroundColor3 = Color3.new(1, 1, 1)
                    bn.TextColor3 = Color3.new(0, 0, 0)
                end
            end)
        end
        CompsTemplate:Destroy()

        local MusicTemplate = Music.Scroller.Template
        for _, music in pairs (data[2]) do
            local bn = MusicTemplate:Clone()

            bn.Name = music
            bn.Text = music
            bn.Parent = MusicTemplate.Parent

            bn.MouseButton1Up:Connect(function()
                HostCommunication:FireServer("PlayMusic", bn.Name)
            end)
        end
        MusicTemplate:Destroy()

        -- Note this should ONLY be done if the player is high enough rank!!
    end
end)

-- Remove certain features if the "kill all" buttons in each menu are pressed.
Competitions.Clear.MouseButton1Up:Connect(function()
    HostCommunication:FireServer("ClearComps")
end)

-- Moves the Guis on or off the screen on user interaction.
Title.MouseButton1Up:Connect(function()
    if not tweenDebounce then
        tweenDebounce = true

        local verticalPos = if System.Position == UDim2.new(0.5, 0, 1.225, 0) then 0.7 else 1.225
        local background = if verticalPos == 1.225 then 1 else 0.6

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