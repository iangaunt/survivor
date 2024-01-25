-- [ servies ] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- [ modules ] --
-- Fetch the Castaways module.
local Castaways = require(ReplicatedStorage.Castaways:WaitForChild("Castaways"))

-- [ objects ] --
local HostCommunication = ReplicatedStorage.HostCommunication
local VoteGui = script.Parent

local Container = VoteGui.VotePanel.Container
local System = Container.CastContainers.System
local Template = System.UIGridLayout.Template

local FadeBlocker = VoteGui.FadeBlocker
local VoteConfirm = VoteGui.VoteConfirm

-- [ variables ] --
local permittedVoteTeams = {"Host", "Alma", "Muerte"}

-- [ functions ] --
HostCommunication.OnClientEvent:Connect(function(key, info)
    -- Add all of the players at Tribal Council into the vote button list.
    if key == "AddVoteButtonsToList" then
        table.sort(info)
        for _, castaway in pairs (info) do
            -- Get the data of that particular castaway from the Castaway module.
            local items = Castaways.castaways[castaway]

            -- Fetch each of the items in the template.
            local temp = Template:Clone()
            local bn = temp.Button
            local desc, overlay = bn.Description, bn.Overlay

            -- Update the button to contain the content of the castaway.
            temp.Name = items["Nickname"]
            desc.Username.Text = items["Username"]
            desc.Castaway.Text = items["Name"]
            overlay.Image = items["Render"]

            -- Parent the castaway's button to the voting container.
            temp.Parent = System

            bn.MouseButton1Up:Connect(function()
                if VoteConfirm.Position == UDim2.new(0.5, 0, 1.6, 0) then
                    TweenService:Create(
                        VoteConfirm,
                        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                        {
                            Position = UDim2.new(0.5, 0, 0.6, 0)
                        }
                    ):Play()

                    VoteConfirm.Title.TextLabel.Text = "Are you sure you want to vote " .. bn.Parent.Name .. "?"

                    local yes
                    local no

                    yes = VoteConfirm.Selectors.Yes.MouseButton1Up:Connect(function()
                        TweenService:Create(
                            VoteGui.VotePanel,
                            TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                            {
                                Position = UDim2.new(0.5, 0, 1.5, 0)
                            }
                        ):Play()

                        TweenService:Create(
                            VoteConfirm,
                            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                            {
                                Position = UDim2.new(0.5, 0, 1.6, 0)
                            }
                        ):Play()

                        HostCommunication:FireServer("AddVoteToUrn", temp.Name)

                        yes:Disconnect()
                        no:Disconnect()

                        task.wait(0.9)
                    end)


                    no = VoteConfirm.Selectors.No.MouseButton1Up:Connect(function()
                        TweenService:Create(
                            VoteConfirm,
                            TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                            {
                                Position = UDim2.new(0.5, 0, 1.6, 0)
                            }
                        ):Play()
        
                        yes:Disconnect()
                        no:Disconnect()
                    end)
                end

            end)
        end
        return;
    end

    if key == "EnableVoteGui" then
        if table.find(permittedVoteTeams, game.Players.LocalPlayer.Team.Name) then

            VoteGui.Enabled = true
            TweenService:Create(
                VoteGui.VotePanel,
                TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                {
                    Position = UDim2.new(0.5, 0, 0.5, 0)
                }
            ):Play()

            task.wait(0.9)
        end
    end

    if key == "ResetVotingBoard" then
        for _, f in pairs (System:GetChildren()) do
            if f:IsA("Frame") then
                f:Destroy()
            end
        end
    end

    if key == "TribalCamera" then
        TweenService:Create(
            FadeBlocker,
            TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
            {
                BackgroundTransparency = 0
            }
        ):Play()

        task.wait(1)

        if info then
            repeat workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
            until workspace.CurrentCamera.CameraType == Enum.CameraType.Scriptable

            workspace.CurrentCamera.CFrame = workspace.Angles.TribalCamera.CFrame
        else
            repeat workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            until workspace.CurrentCamera.CameraType == Enum.CameraType.Custom
        end

        TweenService:Create(
            FadeBlocker,
            TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
            {
                BackgroundTransparency = 1
            }
        ):Play()

        task.wait(1)
        return;
    end

    if key == "PanToAvatar" then
        local char = workspace:FindFirstChild(info)
        if char then
            workspace.CurrentCamera.CFrame = char.Head.CFrame * CFrame.fromEulerAnglesXYZ(0, math.pi, 0) + (char.Head.CFrame.LookVector * 5)

            TweenService:Create(
                workspace.CurrentCamera,
                TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                {CFrame = workspace.CurrentCamera.CFrame + (char.Head.CFrame.LookVector * 0.4)}
            ):Play()
        else
            local def = workspace.Angles.DefaultTribalAngles
            workspace.CurrentCamera.CFrame = def:GetChildren()[math.random(#def:GetChildren())].CFrame
        end
    end
end)