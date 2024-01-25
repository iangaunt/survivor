-- [ module ] --
local v = {}

--[[
    From hereafter, some terminology will be used to describe parts of the Tribal Council.
    A "party" is a player who receives at least one vote and is included in the reveal.
    A "vote" is a singular vote for elimination towards any particular party.

    A "tie" is when two parties receive the same (and MOST) amount of votes in a Tribal Council.
    Ties are NOT considered if the amount of votes they receive is LESS than the most votes receieved.
]]

--[[
    This module "VoteSort" is designed to organize a dictionary of parties and votes into a series of
    votes, designed to create as much suspense as possible. The votes fall similarly to the pattern of
    the show "Survivor", however there is some randomness involved in order to make the votes seem fresh
    each time. It wouldn't be suspenseful if there was a pattern, so VoteSort allows for two vote
    reveal patterns (deemed Alternate or Full Row).

    Alternate chooses to bounce in between each of the voted parties, while Full Row reveals their full vote
    count one by one. This is randomly selected for every VoteSort, which allows for the votes to be organized in a
    different and unpredictable order every time the votes are generated.
]]--

--[[
    This module should be used sparingly throughout your longterm. If you don't know what you're doing, I wouldn't
    bother touching this module and instead opt to do something traditionally. If you understand most of the syntax and
    want to try some of your own methods, go right ahead. However, most of these methods are unoptimized (voteSort getting into
    the O(n^3) time complexity range), and should not be used super frequently on the server.
]]

-- Converts the table into a dictionary. o(n)
function v.tableToDictionary(table)
    -- Initialize a dictionary.
    local dictionary = {}

    -- Create a dictionary out of the table by adding a new key to the dictionary when the first occurance of an item is found.
    for _, value in pairs (table) do
        if dictionary[value] then
            dictionary[value] += 1;
        else
            dictionary[value] = 1;
        end
    end

    -- Returns the dictionary.
    return dictionary;
end

-- Converts the dictionary into a table with every vote. o(n + m) where n is the number of parties and m is the number of votes.
function v.dictionaryToVotes(dictionary)
    -- Initialize a table.
    local tab = {}

    -- Creates a clone of the dictionary to modify its contents.
    local dictionaryClone = table.clone(dictionary)

    -- Continue adding the least voted parties to the table, removing them from the clone, until the clone is empty.
    while v.getLengthOfDictionary(dictionaryClone) > 0 do
        local leastVotes = v.getLeastVotedParty(dictionaryClone)
        while dictionaryClone[leastVotes] > 0 do
            table.insert(tab, leastVotes)
            dictionaryClone[leastVotes] -= 1
        end

        -- Remove the least voted party from the table. (At this point it will be 0, and will mess up further results.)
        dictionaryClone[leastVotes] = nil
    end

    -- Returns the table.
    return tab;
end

-- Converts the dictionary into a table with JUST the names of the parties involved. o(n)
function v.dictionaryToParties(dictionary)
    -- Initialize a table.
    local tab = {}

    -- Creates a clone of the dictionary to modify its contents.
    local dictionaryClone = table.clone(dictionary)

    -- Continue adding the least voted parties to the table, removing them from the clone, until the clone is empty.
    while v.getLengthOfDictionary(dictionaryClone) > 0 do
        local leastVotes = v.getLeastVotedParty(dictionaryClone)
        table.insert(tab, leastVotes)

        -- Remove the least voted party from the table.
        dictionaryClone[leastVotes] = nil
    end

    -- Returns the table.
    return tab;
end

-- Gets the length of a dictionary. o(n)
function v.getLengthOfDictionary(dictionary)
    -- Initialize a number counter.
    local length = 0;

    -- Iterate through every pair in the dictionary.
    for _, _ in pairs (dictionary) do
        length += 1
    end

    -- Return the length of the dictionary.
    return length;
end

-- Gets the highest amount of votes cast for a given party. o(n)
function v.getHighestVoteCount(dictionary)
    -- Initialize a number to store the highest amount of votes.
    local highest: number = 0;

    -- Iterate through the dictionary to compare the highest amount of votes with the next pair.
    for _, value in pairs (dictionary) do
        if value > highest then
            highest = value;
        end
    end

    -- Return the highest amount of votes.
    return highest;
end

-- Gets the highest amount of votes cast for a given party. o(n)
function v.getLowestVoteCount(dictionary)
    -- Initialize a number to store the lowest amount of votes.
    local lowest: number = 0;

    -- Iterate through the dictionary to compare the lowest amount of votes with the next pair.
    for _, value in pairs (dictionary) do
        if value < lowest then
            lowest = value;
        end
    end

    -- Return the lowest amount of votes.
    return lowest;
end

-- Gets ONE OF the parties with the highest amount of votes. o(n)
function v.getMostVotedParty(dictionary)
    -- Similar to getHighestVoteCount, but returns a string instead.

    -- Initialize a number to store the most voted party.
    local highest: string = "";

    -- Iterate through the dictionary to find a party with the specified amount of votes.
    for key, value in pairs (dictionary) do
        -- Prevents the dictionary from attempting to access a nil value.
        if highest == "" then
            highest = key
        end

        -- Compares the current value to the value in the dictionary at key "highest".
        if value > dictionary[highest] then
            highest = key
        end
    end

    -- Return the most voted party.
    return highest;
end

-- Gets ONE OF the parties with the least amount of votes. o(n)
function v.getLeastVotedParty(dictionary)
    -- Similar to getLowestVoteCount, but returns a string instead.

    -- Initialize a number to store the most voted party.
    local lowest: string = "";

    -- Iterate through the dictionary, comparing each value to the lowest variable.
    for key, value in pairs (dictionary) do
        -- Prevents the dictionary from attempting to access a nil value.
        if lowest == "" then
            lowest = key
        end

        -- Compares the current value to the value in the dictionary at key "lowest".
        if value < dictionary[lowest] then
            lowest = key
        end
    end

    -- Return the least voted party.
    return lowest;
end

-- Checks if the dictionary contains a tie. If a tie is present, the function will return a table of tied parties. If not, it will return false. o(n^2)
function v.checkForTie(dictionary): {string} | false
    -- Initialize a table to store tied parties.
    local tiedParties: {string} = {}

    -- Fetch the highest number of votes in the dictionary.
    local highestVotes = v.getHighestVoteCount(dictionary)

    -- Pass through every key-value pairs, checking if the total matches the highest number of votes.
    for key, value in pairs (dictionary) do
        if value == highestVotes then
            table.insert(tiedParties, tostring(key))
        end
    end

    -- If there are two or more parties counted in the tiedVotes table, then there is a tie.
    if #tiedParties > 1 then
        return tiedParties
    else
        return false
    end
end

-- Removes the tied parties from the dictionary. o(n^3)
function v.removeTiedParties(dictionary)
    -- Find all of the tied parties in the dictionary.
    local tiedParties = v.checkForTie(dictionary);

    -- If there IS a tie, then remove all of the tied parties from the dictionary.
    if tiedParties then
        for _, party in pairs (tiedParties) do
            dictionary[party] = nil
        end
    end

    -- Return the purged dictionary.
    return dictionary
end

-- Removed all non-tied parties from the dictionary. o(n^3)
function v.selectTiedParties(dictionary)
    -- Fetches the list of all tied parties from the dictionary.
    local tiedParties = v.checkForTie(dictionary);

    -- Removes all non-tied parties from the dictionary.
    for key, _ in pairs (dictionary) do
        if not table.find(tiedParties, key) then
            dictionary[key] = nil
        end
    end

    -- Returns the dictionary of all tied parties.
    return dictionary;
end

-- Selects a random method to sort a set of votes. o(1)
function v.randomSortMethod()
    local possibleMethods = {"Alternate", "Full Row"}
    return possibleMethods[math.random(#possibleMethods)]
end

-- Sorts the provided dictionary based on a random vote reveal pattern.
function v.revealSortDictionary(dictionary, allowSwaps: boolean)
    -- Select a random method for sorting the votes.
    local method = v.randomSortMethod()

    -- Create a new table for sorting the votes.
    local sorted = {}

    -- Clone the current dictionary to not modify the original copy.
    local dictionaryClone = table.clone(dictionary)

    -- Sort the table based on the random vote reveal pattern.
    if method == "Alternate" then
        -- Iterate through the dictionary, alternating between keys, until the dictionary is empty.
        while v.getLengthOfDictionary(dictionaryClone) > 0 do
            for key, _ in pairs (dictionaryClone) do
                -- Add a copy of the key to the table as a "vote", and remove one from the counter.
                table.insert(sorted, key)
                dictionaryClone[key] -= 1

                -- If the key runs out of votes, then remove it from the dictionary.
                if dictionaryClone[key] == 0 then
                    dictionaryClone[key] = nil
                end
            end
        end
    elseif method == "Full Row" then
        -- Iterate through the dictionary, adding all votes from a key, until the dictionary is empty.
        for key, _ in pairs (dictionaryClone) do
            while dictionaryClone[key] > 0 do
                table.insert(sorted, key)
                dictionaryClone[key] -= 1
            end

            -- Remove entrances from dictionary to save memory.
            dictionaryClone[key] = nil
        end
    end

    -- Swap some of the entries if the function was called with a random value.
    if allowSwaps then
        local swaps = math.random(0, 3)
        while swaps > 0 do
            -- Swaps two random items in the list.
            v.randomSwap(sorted)

            -- Remove one swap from the counter.
            swaps -= 1
        end
    end

    -- Return the sorted list.
    return sorted;
end

function v.revealSortTable(list, allowSwaps: boolean)
    -- Select a random method for sorting the votes.
    local method = v.randomSortMethod()

    -- Create a new table for sorting the votes.
    local sorted = {}

    -- Create a new dictionary of the votes from the list.
    local dict = v.tableToDictionary(list)

    -- Sort the table based on the random vote reveal pattern.
    if method == "Alternate" then
        -- Add each key from the dictionary in the order of the list until the dictionary is empty.
        while v.getLengthOfDictionary(dict) > 0 do
            for _, value in pairs (v.dictionaryToParties(dict)) do
                if dict[value] then
                    table.insert(sorted, value)
                    dict[value] -= 1

                    -- Remove "value" from the dictionary if there are no more votes to count from that party.
                    if dict[value] == 0 then
                        dict[value] = nil
                    end
                else
                    continue
                end
            end
        end
    elseif method == "Full Row" then
        -- Iterate through the dictionary, adding all votes from a key, in the order of the list, until the dictionary is empty.
        for _, value in pairs (list) do
            if dict[value] then
                while dict[value] > 0 do
                    table.insert(sorted, value)
                    dict[value] -= 1
                end
                dict[value] = nil
            end
        end
    end

    -- Swap some of the entries if the function was called with a random value.
    if allowSwaps then
        local swaps = math.random(0, 3)
        while swaps > 0 do
            -- Swaps two random items in the list.
            v.randomSwap(sorted)

            -- Remove one swap from the counter.
            swaps -= 1
        end
    end

    -- Return the sorted list.
    return sorted;
end

-- Randomly swaps two items in the list. o(1)
function v.randomSwap(list)
    if #list > 1 then
         -- Pick two random indices.
        local i = math.random(#list - 1)
        local j = i + 1
        -- Theoretically, this could pick the same index twice, infinitely many times, but that's the fun of random numbers.

        -- Swap the two items in the list at indices i and j.
        local temp = list[i]
        list[i] = list[j]
        list[j] = temp
    end
end

-- Organizes the votes according to which parties were idoled, placing their votes at the beginning.
function v.organizeForIdols(list, idoledParties)
    local finalList = {}
    for _, party in pairs (idoledParties) do
        -- Store the votes of the idoled party in the list.
        local idoledVotes = {}

        -- Iterate through the list, removing idoled parties from the voting order.
        while table.find(list, party) do
            local i = table.find(list, party)
            table.insert(idoledVotes, list[i])
            table.remove(list, i)
        end

        -- Stitch the votes back together.
        list = v.voteSort(v.tableToDictionary(list))
        for _, value in pairs (list) do
            table.insert(idoledVotes, value)
        end
        finalList = idoledVotes
        list = finalList
    end
    return finalList
end

-- Organizes the provided dictionary into a table of votes, organized for suspense.
function v.voteSort(votes)
    -- Find a tie in the votes, if it exists.
    local isTied: {string} | false = v.checkForTie(votes)

    -- If there is a tie, then count how many parties exist in the tie. If not, begin sorting immediately.
    if isTied then
        -- Choose whether to order the votes by non-tied -> tied, or just run through the whole set of votes.
        local orderByTie = (math.random(0, 1) - 1) == 0

        if orderByTie then
            -- Sorts the parties by tied and non-tied players.
            local nonTiedVotes = v.revealSortDictionary(v.removeTiedParties(table.clone(votes)), true)
            local tiedVotes = v.revealSortDictionary(v.selectTiedParties(table.clone(votes)), true)

            -- Stitch the two sorted tables together.
            local sorted = table.clone(nonTiedVotes)
            for _, item in pairs (tiedVotes) do
                table.insert(sorted, item)
            end

            return sorted
        else
            -- Sort the table directly using the reveal sort function.
            local sorted = v.revealSortTable(v.dictionaryToVotes(votes), true)

            return sorted
        end
    else
        -- Cut off the last vote of the sorted table.
        local sorted = v.dictionaryToVotes(votes)
        local finalVote = sorted[#sorted]
        sorted[#sorted] = nil

        -- Tack back the final vote. This is to prevent any misreads in the vote.
        sorted = v.revealSortTable(sorted, true)
        table.insert(sorted, finalVote)

        return sorted
    end
end

return v