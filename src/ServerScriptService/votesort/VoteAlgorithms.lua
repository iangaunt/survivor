-- [ module ] --
local algos = {}

--[[
    From hereafter, some terminology will be used to describe parts of the Tribal Council.
    A "party" is a player who receives at least one vote and is included in the reveal.
    A "vote" is a singular vote for elimination towards any particular party.

    A "tie" is when two parties receive the same (and MOST) amount of votes in a Tribal Council.
    Ties are NOT considered if the amount of votes they receive is LESS than the most votes receieved.
]]

-- Converts the table into a dictionary. o(n)
function algos.tableToDictionary(table)
    -- Initialize a dictionary.
    local dictionary = {}

    -- Create a dictionary out of the table.
    for _, name in pairs (table) do
        if dictionary[name] then
            dictionary[name] += 1;
        else
            dictionary[name] = 1;
        end
    end

    -- Outputs the dictionary.
    return dictionary;
end

-- Converts the dictionary into a table with every vote. o(n + m) where n is the number of parties and m is the number of votes.
function algos.dictionaryToVotes(dictionary)
    -- Initialize a table.
    local tab = {}

    -- Creates a table out of the dictionary by adding each key (value) amount of times.
    for key, value in pairs (dictionary) do
        for i = 1, value do
            print(i)
            table.insert(tab, key)
        end
    end

    -- Outputs the table.
    return tab;
end

-- Converts the dictionary into a table with JUST the names of the parties involved. o(n)
function algos.dictionaryToParties(dictionary)
    -- Initialize a table.
    local tab = {}

    -- Creates a table out of the dictionary by adding each key (value) amount of times.
    for key, _ in pairs (dictionary) do
        table.insert(tab, key)
    end

    -- Outputs the table.
    return tab;
end

-- Gets the length of a dictionary. o(n)
function algos.getLengthOfDictionary(dictionary)
    -- Initialize a number counter.
    local length = 0;

    -- Iterate through every pair in the dictionary.
    for _, _ in pairs (dictionary) do
        length += 1
    end

    -- Return the length of the dictionary.
    return length;
end

-- Sorts a dictionary in descending order. o(n^2)
function algos.sortDictionary(dictionary)
    -- Create a new table to store parties in their sorted order.
    local sortedParties = {};

    --[[
    i ← 1
    while i < length(A)
        j ← i
        while j > 0 and A[j-1] > A[j]
            swap A[j] and A[j-1]
            j ← j - 1
        end while
        i ← i + 1
    end while
    ]]--
end

-- Gets the highest amount of votes cast for a given party. o(n)
function algos.getHighestVoteCount(dictionary)
    -- Initialize a number to store the highest amount of votes.
    local highest = 0

    -- Iterate through the dictionary to compare the highest amount of votes with the next pair.
    for _, value in pairs (dictionary) do
        if value > highest then
            highest = value;
        end
    end

    -- Return the highest amount of votes.
    return highest;
end

-- Checks if the dictionary contains a tie. If a tie is present, the function will return a table of tied parties. If not, it will return false. o(n^2)
function algos.checkIfVoteContainsTie(dictionary)
    -- Initialize a table to store tied votes.
    local tiedVotes = {}

    -- Fetch the highest number of votes in the dictionary.
    local highestVotes = algos.getHighestVoteCount(dictionary)

    -- Pass through every key-value pairs, checking if the total matches the highest number of votes.
    for key, value in pairs (dictionary) do
        if value == highestVotes then
            table.insert(tiedVotes, key)
        end
    end

    -- If there are two or more parties counted in the tiedVotes table, then there is a tie.
    if #tiedVotes > 1 then
        return tiedVotes
    else
        return false
    end
end

return algos
