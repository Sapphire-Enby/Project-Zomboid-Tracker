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

            if perk then
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

return datascrape