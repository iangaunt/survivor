-- [ objects ] --
-- Fetches the PlayerGui to organize Scripts.
local PlayerGui = script.Parent
local Scripts = PlayerGui:WaitForChild("Scripts")

-- Fetches the appropriate Gui objects.
local AudienceGui = PlayerGui:WaitForChild("AudienceGui")
local CastawayGui = PlayerGui:WaitForChild("CastawayGui")
local HostGui = PlayerGui:WaitForChild("HostGui")
local VoteGui = PlayerGui:WaitForChild("VoteGui")

-- Fetches the appropriate Script objects.
local Audience = Scripts:WaitForChild("Audience")
local Castaway = Scripts:WaitForChild("Castaway")
local Host = Scripts:WaitForChild("Host")
local Vote = Scripts:WaitForChild("Vote")

-- [ functions ] --
-- Sends each of the appropriate GUI controllers to the appropriate locations.
Audience.Parent = AudienceGui
Castaway.Parent = CastawayGui
Host.Parent = HostGui
Vote.Parent = VoteGui

-- Turns on each of the controllers.
Audience.Enabled = true
Castaway.Enabled = true
Host.Enabled = true
Vote.Enabled = true

-- Removes the initial container.
Scripts:Destroy()