-- [ objects ] --
-- Fetches the PlayerGui to organize Scripts.
local PlayerGui = script.Parent 
local Scripts = PlayerGui:WaitForChild("Scripts")

-- Fetches the appropriate Gui objects.
local AudienceGui = PlayerGui:WaitForChild("AudienceGui")
local CastawayGui = PlayerGui:WaitForChild("CastawayGui")

-- Fetches the appropriate Script objects.
local Audience = Scripts:WaitForChild("Audience")
local Castaway = Scripts:WaitForChild("Castaway")
local Host = Scripts:WaitForChild("Host")

-- [ functions ] --
-- Sends each of the appropriate GUI controllers to the appropriate locations.
Audience.Parent = AudienceGui
Castaway.Parent = CastawayGui

-- Turns on each of the controllers.
Audience.Enabled = true
Castaway.Enabled = true

-- Removes the initial container.
Scripts:Destroy()