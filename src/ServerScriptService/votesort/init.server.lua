-- [ services ] --
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- [ modules ] --
-- Fetches the proper methods to sort the collected votes.
local VoteSort = require(script.VoteSort)
local Castaways = require(ReplicatedStorage.Castaways.Castaways)

-- [ objects ] --
local HostCommunication = ReplicatedStorage.HostCommunication
local parchment = workspace:FindFirstChild("ClickParchment", true)

-- [ variables ] --
local storedVotes = {}

local votes = {}
local ongoingTribal, votingPeriod = false, false

local webhookURL = "https://webhook.lewisakura.moe./api/webhooks/1125092028120842310/0Gh0WV_rSv56jhxWV3k9c5R8UBColc_VIYfSC1jx9GKK3_UeXRkWp-ITacFSTYLc03cg"
local teamsAllowedToVote = {
	"Host",
	"Alma",
	"Muerte"
}

-- [ functions ] --
function getTotalVotes(list)
    local counter = 0
    for entry, _ in pairs (list) do
        counter += #list[entry]
    end
    return counter
end

game.Players.PlayerAdded:Connect(function(plr)
    plr.Chatted:Connect(function(msg)
        if msg == "TRIBAL::END" and plr:GetRankInGroup(15523570) >= 100 then
            HostCommunication:FireClient(plr, "ForceKill")
        end
    end)
end)

HostCommunication.OnServerEvent:Connect(function(plr, key, info)
    -- Only players who are highly ranked in the group can use the UI.
    if plr:GetRankInGroup(15523570) >= 100 then

        -- Sends out the vote to all players on the server.
        if key == "StartVote" then
            if not ongoingTribal and #Castaways.castawaysAtTribal > 0 then
                ongoingTribal = true
                storedVotes = {}
                HostCommunication:FireAllClients("AddVoteButtonsToList", table.clone(Castaways.castawaysAtTribal))
            else
                HostCommunication:FireAllClients("VotesError", "No Parties / Ongoing Tribal")
            end
        end

        -- Add or remove a player from the Tribal Council voting list.
        if key == "AlterCastawayVote" then
            if table.find(Castaways.castawaysAtTribal, info) then
                table.remove(Castaways.castawaysAtTribal, table.find(Castaways.castawaysAtTribal, info))
            else
                if Castaways.castaways[info] ~= nil then
                    table.insert(Castaways.castawaysAtTribal, info)
                end
            end

            HostCommunication:FireAllClients("UpdateVoteTable", table.clone(Castaways.castawaysAtTribal))
            votingPeriod = true
            return;
        end

        -- Asks the hosts to input any idoled castaways.
        if key == "CheckForIdols" then
            if VoteSort.getLengthOfDictionary(storedVotes) > 0 then
                HostCommunication:FireAllClients("OpenIdolTable", table.clone(Castaways.castawaysAtTribal))
                HostCommunication:FireAllClients("UpdateVoteTable", table.clone(Castaways.idoledCastaways))
            else
                HostCommunication:FireAllClients("VotesError", "No Votes Cast")
            end
        end

        if key == "AlterCastawayIdolStatus" then
            if table.find(Castaways.idoledCastaways, info) then
                table.remove(Castaways.idoledCastaways, table.find(Castaways.idoledCastaways, info))
            else
                if Castaways.castaways[info] ~= nil then
                    table.insert(Castaways.idoledCastaways, info)
                end
            end

            HostCommunication:FireAllClients("UpdateVoteTable", table.clone(Castaways.idoledCastaways))
            return;
        end

        -- Sorts the votes that were received from the urn.
        if key == "SortVotes" then
            votingPeriod = false
            for _, player in pairs (storedVotes) do
                for _, vote in pairs (player) do
                    table.insert(votes, vote)
                end
            end

            votes = VoteSort.voteSort(VoteSort.tableToDictionary(votes))
            if #votes > 0 then
                if #Castaways.idoledCastaways > 0 then
                    votes = VoteSort.organizeForIdols(votes, Castaways.idoledCastaways)
                end
                HostCommunication:FireAllClients("VotesSorted", #votes)
            else
                HostCommunication:FireAllClients("VotesError", "No Votes Cast")
            end
        end

        if key == "RevealVote" then
            HostCommunication:FireAllClients("TribalCamera", true)

            task.wait(1)

            local c = ServerStorage.Parchment:Clone()
            c:FindFirstChild("TextLabel", true).Text = votes[info]
            c.Parent = plr.Character
            plr.Character.HumanoidRootPart.Anchored = true
        elseif key == "VoteRevealed" then
            HostCommunication:FireAllClients("PanToAvatar", Castaways.castaways[info]["Username"])

            task.wait(3)

            HostCommunication:FireAllClients("TribalCamera", false)

            task.wait(1)

            plr.Character.Parchment:Destroy()
            plr.Character.HumanoidRootPart.Anchored = false
        end

        if key == "EndTribal" then
            local votesEmbed = {["content"] = "",}

            for p, t in pairs (storedVotes) do
                local str = "**" .. p .. "** " .. "= "
                for _, v in pairs (t) do
                    str = str .. v .. ", "
                end

                votesEmbed["content"] = votesEmbed["content"] .. string.sub(str, 0, -3) .. "\n"
            end
            pcall(function()
                HttpService:PostAsync(webhookURL, HttpService:JSONEncode(votesEmbed))
            end)

            HostCommunication:FireAllClients("ResetVotingBoard")
            ongoingTribal = false
            votingPeriod = false

            storedVotes = {}
            votes = {}

            Castaways.castawaysAtTribal = {}
            Castaways.idoledCastaways = {}
            HostCommunication:FireAllClients("UpdateVoteTable", table.clone(Castaways.castawaysAtTribal))
        end
    end

    -- Adds a vote from a player to the tribal council urn.
    if key == "AddVoteToUrn" then
        if storedVotes[plr.Name] == nil then
            storedVotes[plr.Name] = {}
            table.insert(storedVotes[plr.Name], info)
        else
            table.insert(storedVotes[plr.Name], info)
        end
        HostCommunication:FireAllClients("UpdateVoteCount", getTotalVotes(storedVotes))
        return
    end
end)

parchment.ClickDetector.MouseClick:Connect(function(plr)
    if table.find(teamsAllowedToVote, plr.Team.Name) and not storedVotes[plr.Name] and ongoingTribal and votingPeriod or plr.Team == game.Teams.Host and ongoingTribal and votingPeriod then
        HostCommunication:FireClient(plr, "EnableVoteGui")
    end
    task.wait()
end)