-- This holds the common functions used to scrape player data
-- Independent of any particular gamemode

-- Names of functions are self-explanatory,
-- they all require a player object as the first argument

local datascrape = {}
    
    function datascrape.getCharacterName(p)
        local username = p:getUsername()
        return tostring(username or "Unknown")
    end

    function datascrape.getKills(p)
        local kills = p:getZombieKills()
        return tonumber(kills) or 0
    end

    function datascrape.getSkills(p)
        if not PerkFactory or not PerkFactory.PerkList then --perkFactory helps generate the list of perks, ready by import time
            print("[datascrape] ERROR: PerkFactory not ready!")
            return {}
        end

        local skills = {}
        local allperks = PerkFactory.PerkList  -- generates a list of all perks in the game

        for i=0, allperks:size()-1 do -- one by one, get each perk from the list, and check the player's level in that perk
            local perk = allperks:get(i)

---@diagnostic disable-next-line: undefined-global -- In Lua, 'null' is not a standard value, but in the context of Project Zomboid's Lua environment, 'null' is used to represent a nil value from Java. This check ensures that we don't attempt to call methods on a nil perk, which would cause errors.
            if perk and perk ~= null then           -- null is java value for nil, This prevents attempts to access methods on a nil perk, which would cause errors
                local perkName = perk:getType()     -- will return the common name of the perk e.g. "Strength" or "Cooking"
                local level = p:getPerkLevel(perk)  -- will return the level of that perk for the player

                if perkName and level then
                    skills[tostring(perkName)] = tonumber(level) or 0
                end
            end
        end

        -- Count skills, simply for logging purposes
        local skillCount = 0
        for _ in pairs(skills) do
            skillCount = skillCount + 1
        end
        print("[Datascrape] Collected " .. skillCount .. " skills")

        return skills
    end

    function datascrape.getGameDateTime()
        local gt = getGameTime()
        if not gt then return "" end

        -- Month is 0-indexed in PZ: July=0, Aug=1, Sep=2, etc.
        local monthNames = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"}
        local monthIndex = gt:getMonth()
        local monthName = monthNames[(monthIndex % 12) + 1] or "???"
        local day = gt:getDay()
        local hour = gt:getHour()
        local minutes = gt:getMinutes()

        return string.format("%s %d, %02d:%02d", monthName, day, hour, minutes)
    end

    function datascrape.getSaveName()
        -- getWorld():getWorld() returns save folder timestamp string in singleplayer
        local ok, saveName = pcall(function()
            return getWorld():getWorld()
        end)

        if ok and saveName and saveName ~= "" then
            return tostring(saveName)
        end

        -- Fallback for multiplayer: use server name
        local serverOk, serverName = pcall(function()
            return getServerName()
        end)

        if serverOk and serverName and serverName ~= "" then
            return tostring(serverName)
        end

        return "unknown"
    end

return datascrape