-- [ functions ] --
local Players, ReplicatedStorage, RunService, Teams, TweenService, UserInputService = game:GetService("Players"), game:GetService("ReplicatedStorage"), game:GetService("RunService"), game:GetService("Teams"),game:GetService("TweenService"), game:GetService("UserInputService")

-- [ objects ] --
local player: Player = Players.LocalPlayer

-- Reference the Castaway Gui, as well as various sections of the Gui.
local AudienceGui = script.Parent

-- References particular buttons and objects needed for the various audience Guis to function.
local ButtonSystem = AudienceGui.ButtonContainer.ButtonSystem
local Information, Spectate, LagMode = ButtonSystem.Information, ButtonSystem.Spectate, ButtonSystem.LagMode
local InformationPanel, SpectatePanel = AudienceGui.InformationPanel, AudienceGui.SpectatePanel
local LeftButton, RightButton = SpectatePanel:FindFirstChild("LeftButton", true), SpectatePanel:FindFirstChild("RightButton", true)

local currentCamera = workspace.CurrentCamera
local HostCommunication = ReplicatedStorage.HostCommunication

-- [ variables ] --
-- Stores which teams can be spectated.
local spectateTeams = {
    "Alma",
    "Muerte",
	"Purgatorio"
}

-- Stores which players can be spectated.
local spectatePlayers = {}

-- Stores the current index of the spectate Gui.
local viewingNumber = 1

-- Checks if the player is currently focused on a text box, such as chat, to prevent erratic spectating behavior.
local focusedOnText = false

-- Stores if the lag mode is currently enabled on the client.
local lagModeOn = false

-- Stores if the player is able to move the camera (such as in cutscenes).
local canMoveCamera = true

-- [ functions ] --
-- Changes the color of the button to its inverted stage when prompted.
function tweenButton(button, panel)
    local bgColor = if panel.Visible == true then Color3.fromRGB(66, 66, 66) else Color3.fromRGB(200, 200, 200)
    local imgColor = if bgColor == Color3.fromRGB(200, 200, 200) then Color3.new(0, 0, 0) else Color3.new(1, 1, 1)

    TweenService:Create(
        button,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            BackgroundColor3 = bgColor,
            ImageColor3 = imgColor
        }
    ):Play()
end

-- Changes the position of the player's camera to the next available player.
function moveSpectate(mod)
	if canMoveCamera then
		viewingNumber = viewingNumber + mod

		if spectatePlayers[viewingNumber] == nil then
			if viewingNumber > #spectatePlayers then
	            viewingNumber = 1
	        elseif viewingNumber < 1 then
	            viewingNumber = #spectatePlayers
	        end
		else
			currentCamera.CameraSubject = spectatePlayers[viewingNumber].Character.Humanoid
		end
	end
end

-- If the HostKit fires a key to lock the camera, prevent spectating at that point.
HostCommunication.OnClientEvent:Connect(function(key, info)
	if key == "TribalCamera" then
		canMoveCamera = not info
	end
end)

-- Toggles the information panel.
Information.MouseButton1Up:Connect(function()
    tweenButton(Information, InformationPanel)
    InformationPanel.Visible = not InformationPanel.Visible
end)

-- Toggles the spectator panel.
Spectate.MouseButton1Up:Connect(function()
    if player.Team == Teams.Audience then
        tweenButton(Spectate, SpectatePanel)
        SpectatePanel.Visible = not SpectatePanel.Visible

        if SpectatePanel.Visible == false then
            currentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
        end
    end
end)

-- Removes the ability to spectate if the player is focused on a text box.
UserInputService.TextBoxFocused:connect(function()
	focusedOnText = true
end)

-- Adds the ability to spectate when the player clicks off of the text box.
UserInputService.TextBoxFocusReleased:connect(function()
	focusedOnText = false
end)

-- Shifts the player's camera if they press Q or E, and invokes moveSpectate accordingly.
UserInputService.InputBegan:Connect(function(input)
	if SpectatePanel.Visible == true and input.UserInputType == Enum.UserInputType.Keyboard and focusedOnText == false then
        local keyPressed = input.KeyCode
        if keyPressed == Enum.KeyCode.Q then
            moveSpectate(-1)
        elseif keyPressed == Enum.KeyCode.E then
            moveSpectate(1)
        end
	end
end)

-- Moves the player's camera to the previous player in the spectate table.
LeftButton.MouseButton1Up:Connect(function()
    moveSpectate(-1)
end)

-- Moves the player's camera to the next avaiable player in the spectate table.
RightButton.MouseButton1Up:Connect(function()
    moveSpectate(1)
end)

-- Updates the table of players available to spectate, making sure added or removed players are added.
RunService.Heartbeat:Connect(function()
	if player.Team == game.Teams.Audience then
		AudienceGui.Enabled = true
		for _, team in pairs(spectateTeams) do
			for _, p in pairs (Teams[team]:GetPlayers()) do
				table.insert(spectatePlayers, p)
			end
		end

		for _, p in pairs (spectatePlayers) do
			if p.Character == nil then
				table.remove(spectatePlayers, table.find(spectatePlayers, p))
				moveSpectate(1)
			end
		end
	else
		AudienceGui.Enabled = false
	end
end)

-- Toggles all lag parts in the game, regardless of their level.
LagMode.MouseButton1Up:Connect(function()
	tweenButton(LagMode, AudienceGui.LagPanel)

	if not lagModeOn then
		for _, part in pairs (workspace:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("Model") then
				if part:FindFirstChild("LagSetting") then
					local parentHolder = Instance.new("ObjectValue")
					parentHolder.Name = "ParentHolder"
					parentHolder.Parent = part
					parentHolder.Value = part.Parent

					part.Parent = ReplicatedStorage.RemovedObjects
				end
			end
		end
	else
		if #ReplicatedStorage.RemovedObjects:GetChildren() > 0 then
			for _, part in pairs (ReplicatedStorage.RemovedObjects:GetDescendants()) do
				if part:FindFirstChild("ParentHolder") and (part:IsA("BasePart") or part:IsA("Model")) then
					part.Parent = part.ParentHolder.Value
					part.ParentHolder:Destroy()
				end
			end
		end
	end

	AudienceGui.LagPanel.Visible = not AudienceGui.LagPanel.Visible
	lagModeOn = not lagModeOn
end)
