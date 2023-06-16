--// initialize variables //--

local playerTable = nil
local viewingNumber = 1
local player = game.Players.LocalPlayer

local focusedOnText = false
local UIS = game:GetService("UserInputService")

wait(1)

--// initialize functions //--

function resetGui()
	script.Parent.GuiActive.Value = false
	script.Parent.Parent.ChangePlayer.Visible = false
	script.Parent.Holder.PlayerName.Text = "NOBODY"
	viewingNumber = 1
	game.Workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
end

function moveRight()
	playerTable = game.Players:GetChildren()
	
	viewingNumber = viewingNumber + 1
	
	if playerTable[viewingNumber] == nil then
		viewingNumber = 1
	end
	
	if playerTable[viewingNumber] ~= nil then
		game.Workspace.CurrentCamera.CameraSubject = playerTable[viewingNumber].Character.Humanoid
		if playerTable[viewingNumber].Name ~= player.Name then
			script.Parent.Holder.PlayerName.Text = playerTable[viewingNumber].Name:upper()
		else 
			script.Parent.Holder.PlayerName.Text = "NOBODY"
		end
	end
end

function moveLeft()
	playerTable = game.Players:GetChildren()
	local maxNumber = #playerTable
	
	viewingNumber = viewingNumber - 1
	
	if playerTable[viewingNumber] == nil then
		viewingNumber = maxNumber
	end
	
	if playerTable[viewingNumber] ~= nil then
		game.Workspace.CurrentCamera.CameraSubject = playerTable[viewingNumber].Character.Humanoid
		if playerTable[viewingNumber].Name ~= player.Name then
			script.Parent.Holder.PlayerName.Text = playerTable[viewingNumber].Name:upper()
		else 
			script.Parent.Holder.PlayerName.Text = "NOBODY"
		end
	end
end

function checkTeam(color)
	for i,v in pairs(script.Parent.Parent.AllowedTeams:GetChildren()) do
		if v.Value == game.Players.LocalPlayer.TeamColor then
			return true
		end
	end
	return false
end

--// if a player focuses on a textbox like chat, dont switch players while typing //--
UIS.TextBoxFocused:connect(function()
	focusedOnText = true
end)

--// if a player is done typing, allow them to use Q/E to change spec again //--
UIS.TextBoxFocusReleased:connect(function()
	focusedOnText = false
end)

--// initialize Q/E control //--
UIS.InputBegan:connect(function(input,gameProcessed)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if script.Parent.GuiActive.Value == true and focusedOnText == false then
			local keyPressed = input.KeyCode
			if keyPressed == Enum.KeyCode.Q then
				moveLeft()
			elseif keyPressed == Enum.KeyCode.E then
				moveRight()
			end
		end
	end
end)

--// initialize manual-click right button //--
script.Parent.RightButton.Button.MouseButton1Click:connect(function(right)
	moveRight()
end)

--// initialize manual-click left button //--
script.Parent.LeftButton.Button.MouseButton1Click:connect(function(left)
	moveLeft()
end)

--// initialize opening/closing spectate //--
script.Parent.Parent.SpectateButton.Spectate.MouseButton1Down:connect(function(click)
	if script.Parent.GuiActive.Value == false then
		script.Parent.GuiActive.Value = true
		script.Parent.Parent.ChangePlayer.Visible = true
	elseif script.Parent.GuiActive.Value == true then
		resetGui()
	end
end)

--// initialize team changing function //--
game.Players.LocalPlayer.Changed:connect(function()
	if checkTeam() == true then
		script.Parent.Parent.SpectateButton.Visible = true
	else
		script.Parent.Parent.SpectateButton.Visible = false
		resetGui()
	end
end)

if checkTeam() == true then
	script.Parent.Parent.SpectateButton.Visible = true
else
	script.Parent.Parent.SpectateButton.Visible = false
	resetGui()
end