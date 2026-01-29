local datascrape = require("datascrape")
local JsonWriter = require("JsonWriter")

local playerRecords = {}

-- locally store player data objects, and iterate through them
local function getPlayers()
    local onlinePlayers = getOnlinePlayers()
    -- check if onlinePlayers is nil before proceeding
    if not onlinePlayers then
        print("[PlayerTest] ERROR: getOnlinePlayers() returned nil")
        return {}
    end
    -- iterate through online players 
    -- fill player records table
    for i = 0, onlinePlayers:size() - 1 do
        -- get each player object
        local currentPlayer = onlinePlayers:get(i)
        -- ensure currentPlayer is not nil
        if currentPlayer then
            -- if valid, extract data using datascrape module
            -- and store in playerRecords table for later json serialization
            playerRecords[datascrape.getCharacterName(currentPlayer)] = {
                kills = datascrape.getKills(currentPlayer),
                skills = datascrape.getSkills(currentPlayer)
            }
        else
            -- log warning if currentPlayer is nil
            print("[PlayerTest] WARNING: currentPlayer is nil at index " .. i)
        end
    end


    local hasRecords = false -- using next to check if table is non-empty threw an error
    for _ in pairs(playerRecords) do
        hasRecords = true
        break
    end

    if hasRecords then  -- avoid writing empty data
        JsonWriter.toFile(playerRecords)
    else
        print("[PlayerTest] No player records to write.")
    end
end

-- some off the top events to hook into for data capture
for _, event in ipairs({Events.OnCreatePlayer,Events.OnPlayerDeath,Events.EveryHours}) do
        event.Add(getPlayers)
end