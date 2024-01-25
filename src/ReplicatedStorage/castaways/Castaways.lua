-- [ module ] --
local c = {}

--[[
    This table contains information on every castaway in the season. It includes their nickname, full name,
    full body render (for the overlay on the voting UI), and their usernames. This data NEEDS to be formatted correctly
    when using this module or the module will NOT WORK.

    To add a castaway, it can be done in the following manner:
    - Add a table to the castaways table. Give it the name of the castaway (I would recommend nickname for readability).
    - Add the following properties to the table (what they should contain should be easy to figure out):
    {
        ["Name"] = "Barbara C.",
        ["Nickname"] = "Barbara",
        ["Render"] = "http://www.roblox.com/asset/?id=13913190500",
        ["Username"] = "oatmeIk"
    }
    -- EVERY KEY IN THIS TABLE MUST MATCH THE FOUR ABOVE. THEY MUST ALL BE PRESENT.

    The actual order of the keys is irrelevant. It will be sorted alphabetically when the game begins.
    The advantage of using a dictionary instead of a table (which most are familiar with) is that selecting
    an object from the dictionary takes constant time, meaning NO ITERATION has to take place. This is incredibly
    useful when adding players to the voting UI.
]]

c.castaways = {
    ["Ashanti"] = {
        ["Name"] = "Ashanti S.", ["Nickname"] = "Ashanti", ["Username"] = "elysi_n",
        ["Render"] = "http://www.roblox.com/asset/?id=13913188467"
    },
    ["Barbara"] = {
        ["Name"] = "Barbara C.", ["Nickname"] = "Barbara", ["Username"] = "oatmeIk",
        ["Render"] = "http://www.roblox.com/asset/?id=13913190500"
    },
    ["Blue"] = {
        ["Name"] = "Blue J.", ["Nickname"] = "Blue", ["Username"] = "Lil_boy06",
        ["Render"] = "http://www.roblox.com/asset/?id=13913193327"
    },
    ["Bryson"] = {
        ["Name"] = "Bryson W.", ["Nickname"] = "Bryson", ["Username"] = "bizooke",
        ["Render"] = "" -- TODO: reupload Bryson av
    },
    ["Destiny"] = {
        ["Name"] = "Destiny J.", ["Nickname"] = "Destiny", ["Username"] = "3xclusive_Madis",
        ["Render"] = "http://www.roblox.com/asset/?id=13913200327"
    },
    ["Hardy"] = {
        ["Name"] = "Hardy J.", ["Nickname"] = "Hardy", ["Username"] = "Hardwoodwarrior23",
        ["Render"] = "http://www.roblox.com/asset/?id=13913202153"
    },
    ["Jennie"] = {
        ["Name"] = "Jennie B.", ["Nickname"] = "Jennie", ["Username"] = "covengirls",
        ["Render"] = "http://www.roblox.com/asset/?id=13913204755"
    },
    ["Jules"] = {
        ["Name"] = "Jules W.", ["Nickname"] = "Jules", ["Username"] = "jzulesphobic",
        ["Render"] = "http://www.roblox.com/asset/?id=13913207225"
    },
    ["July"] = {
        ["Name"] = "July S.", ["Nickname"] = "July", ["Username"] = "July7292",
        ["Render"] = "http://www.roblox.com/asset/?id=13913209045"
    },
    ["Justus"] = {
        ["Name"] = "Justus L.", ["Nickname"] = "Justus", ["Username"] = "inchclinch",
        ["Render"] = "http://www.roblox.com/asset/?id=13913210760"
    },
    ["Landen"] = {
        ["Name"] = "Landen S.", ["Nickname"] = "Landen", ["Username"] = "Iandenspears",
        ["Render"] = "http://www.roblox.com/asset/?id=13913212952"
    },
    ["Lena"] = {
        ["Name"] = "Lena B.", ["Nickname"] = "Lena", ["Username"] = "PR41L",
        ["Render"] = "http://www.roblox.com/asset/?id=13913215075"
    },
    ["Luke"] = {
        ["Name"] = "Luke V.", ["Nickname"] = "Luke", ["Username"] = "lucasbyron",
        ["Render"] = "http://www.roblox.com/asset/?id=13913217333"
    },
    ["Max"] = {
        ["Name"] = "Max S.", ["Nickname"] = "Max", ["Username"] = "Maaxon",
        ["Render"] = "http://www.roblox.com/asset/?id=13913219544"
    },
    ["Paolo"] = {
        ["Name"] = "Paolo M.", ["Nickname"] = "Paolo", ["Username"] = "PaolosPurgatory",
        ["Render"] = "http://www.roblox.com/asset/?id=13913221544"
    },
    ["Pandi"] = {
        ["Name"] = "Pandi S.", ["Nickname"] = "Pandi", ["Username"] = "OceanJoker",
		["Render"] = "http://www.roblox.com/asset/?id=13913230399" 
    },
    ["Rose"] = {
        ["Name"] = "Rose B.", ["Nickname"] = "Rose", ["Username"] = "flower1920000",
        ["Render"] = "" -- TODO: reupload Rose av
    },
    ["Sammy"] = {
        ["Name"] = "Sammy B.", ["Nickname"] = "Sammy", ["Username"] = "XxSammyBear",
        ["Render"] = "http://www.roblox.com/asset/?id=13913225679"
    },
    ["Tea"] = {
        ["Name"] = "Tea K.", ["Nickname"] = "Tea", ["Username"] = "Teasipsdrink",
	    ["Render"] = "" -- TODO: reupload Tea av
    },
    ["Wesley"] = {
        ["Name"] = "Wesley W.", ["Nickname"] = "Wesley", ["Username"] = "wesxley",
        ["Render"] = "http://www.roblox.com/asset/?id=13913232882"
    }
}

-- Table for storing each of the castaways alphabetically.
c.castawaysOrder = {"Ashanti", "Barbara", "Blue", "Bryson", "Destiny", "Hardy", "Jennie", "Jules", "July", "Justus", "Landen", "Lena", "Luke", "Max", "Paolo", "Pandi", "Rose", "Sammy", "Tea", "Wesley"}

-- Table for storing which castaways are currently eligible to be voted.
-- Used primarily for hosts to update their GUI accordingly.
c.castawaysAtTribal = {}
c.idoledCastaways = {}

return c