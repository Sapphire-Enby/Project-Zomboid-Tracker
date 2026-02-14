--[[    PlayerTest.lua
 * A simple test script to capture player data and write to JSON on certain events.
 * This script uses the datascrape module to extract player information and the JsonWriter module to serialize it.
 * It hooks into OnCreatePlayer, OnPlayerDeath, and EveryHours events to trigger data capture.
--]]

-- Dependency imports
local datascrape = require("datascrape")  -- Module for extracting player data
local JsonWriter = require("JsonWriter")  -- Module for writing data to JSON files

-- Globals
local playerRecords = {}                  -- Table for processed player data, to be written to JSON
local playersToProcess = {}               -- Players that Need processing, ensures single player or multiplayer compatibility

-- Consider Seperating player data capture and JSON writing
--      into separate functions for better modularity and readability.


--[[      Func : getPlayers
 * Captures data for all players and stores it in playerRecords.
 *
 * Collects players into differed table ( Allows for single player and multiplayer compatibility )
 * After collecting players, we process each player's data and store it in playerRecords.
 * Finally, it writes the playerRecords to a JSON file if there are any records to write.
--]]

local function getPlayersToProcess()

    -- Attempt Multiplayer Collection, Default to Single Player if none found

    -- reset tables
    playersToProcess = {}
    playerRecords = {}

    -- variable to hold online players, will be nil if single player
    local onlinePlayers = getOnlinePlayers()
    -- empty table isnt always nil, check size() > 0
    if onlinePlayers ~= nil and onlinePlayers:size() > 0 then
        -- Multiplayer Mode Detected, Collecting Online Players
        -- Add players to processing table, check for nils just in case
        for i = 0, onlinePlayers:size() - 1 do      -- One by one
            local p = onlinePlayers:get(i)          -- Get a player
            if p ~= nil then                        -- Super Safe  Nil Check
                table.insert(playersToProcess, p)   -- Added to Table
            end
        end
    -- if no online Players check isServer to Avoid empty Multiplayer running Single Player Code
    elseif not isServer() then
        -- if OnlinePlayers is nil, and not isServer: Single Player Detected,
        local sp = getPlayer()                      -- get Local player
        if sp ~= nil then                           -- ensure not nil
            table.insert(playersToProcess, sp)      -- Add to Processing Table
        end
    end

end
-- process players in toProcess table, extract data and write to PlayerRecords
local function processPlayers()
    for _, currentPlayer in ipairs(playersToProcess) do
        local characterName = datascrape.getCharacterName(currentPlayer)
        local kills = datascrape.getKills(currentPlayer)
        local skills = datascrape.getSkills(currentPlayer)
        playerRecords[characterName] = {
            kills = kills,
            skills = skills
        }
    end
end

local function writeRecordsToJson(metadata)
    local hasRecords = false -- using next to check if table is non-empty threw an error
    for _ in pairs(playerRecords) do
        hasRecords = true
        break
    end

    if hasRecords then  -- avoid writing empty data
        JsonWriter.toFile(playerRecords, metadata)
    else
        print("[PlayerTest] No player records to write.")
    end
end

local function onEvent()
    getPlayersToProcess()  -- Collect players based on game mode
    processPlayers()       -- Extract data and populate playerRecords

    local metadata = {
        gameDate = datascrape.getGameDateTime(),
        saveName = datascrape.getSaveName()
    }

    writeRecordsToJson(metadata)   -- Write the collected data to JSON
end
-- some off the top events to hook into for data capture
for _, event in ipairs({Events.OnCreatePlayer,Events.OnPlayerDeath,Events.EveryHours}) do
        event.Add(onEvent)
end