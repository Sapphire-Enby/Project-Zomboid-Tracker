local JsonWriter = {}
function JsonWriter.encode(playerRecords)
    -- We build the JSON string piece by piece using a table of string fragments.
    -- This is more efficient than repeated string concatenation in Lua because
    -- strings are immutable - each concat creates a new string object.
    -- At the end, table.concat() joins them all in one operation.
    local result = {}

    -- Begin the root JSON object - this will contain all characters
    -- The newline adds formatting for human readability
    table.insert(result, "{\n")

    -- Track whether we're on the first character entry.
    -- JSON requires commas BETWEEN items, not after the last one.
    -- So we only insert a comma before items that aren't first.
    local firstChar = true

    -- Iterate over each character in the record table
    -- characterName = the player's username (string key)
    -- charData = table containing { kills = number, skills = table }
    for characterName, charData in pairs(playerRecords) do
        -- Add comma separator before all characters except the first
        -- This produces: "char1": {...}, "char2": {...}
        -- NOT: "char1": {...}, "char2": {...},  (trailing comma is invalid JSON)
        if not firstChar then
            table.insert(result, ',\n')
        end
        firstChar = false

        -- Open this character's object with their name as the key
        -- Indented 2 spaces for readability
        -- Example output: "PlayerName": {
        table.insert(result, '  "')
        table.insert(result, tostring(characterName))  -- tostring() ensures safety if key is somehow not a string
        table.insert(result, '": {\n')

        -- Write the kills field (zombie kill count)
        -- Default to 0 if kills is nil/missing
        -- Indented 4 spaces (nested inside character object)
        table.insert(result, '    "kills": ')
        table.insert(result, tostring(charData.kills or 0))
        table.insert(result, ',\n')  -- Comma here because skills object follows

        -- Begin the skills sub-object
        -- This will contain all perk names and their levels
        table.insert(result, '    "skills": {\n')

        -- Same comma-tracking pattern for skills
        -- Prevents trailing comma after the last skill
        local firstSkill = true

        -- Iterate over all skills for this character
        -- skill = perk name (e.g., "Strength", "Cooking")
        -- level = numeric skill level (0-10 typically)
        -- Using "or {}" protects against nil skills table
        for skill, level in pairs(charData.skills or {}) do
            -- Add comma separator before all skills except the first
            if not firstSkill then
                table.insert(result, ',\n')
            end
            firstSkill = false

            -- Write skill entry: "SkillName": level
            -- Indented 6 spaces (nested inside skills object)
            table.insert(result, '      "')
            table.insert(result, tostring(skill))
            table.insert(result, '": ')
            table.insert(result, tostring(level))  -- Numbers don't need quotes in JSON
        end

        -- Close the skills object
        -- Newline first to put closing brace on its own line
        table.insert(result, '\n    }\n')

        -- Close this character's object
        -- No newline after - the comma or final brace handles that
        table.insert(result, '  }')
    end

    -- Close the root JSON object
    table.insert(result, '\n}')

    -- Join all string fragments into final JSON string
    -- This is O(n) where n is total string length, much better than
    -- repeated concatenation which would be O(n^2)
    return table.concat(result)
end
-- ==== END JSON ENCODER ====
function JsonWriter.toFile(playerRecords)
    -- Use inline JSON encoder
    local jsonString = JsonWriter.encode(playerRecords)

    -- Write using PZ's file API
    local writer = getFileWriter("playerdata.json", true, false)
    writer:write(jsonString)
    writer:close()

    -- Alongside the playerdata.json file, a flag file named updated.flag
    -- is created/updated to signal that new data is available.
    local flagWriter = getFileWriter("updated.flag", true, false)
    flagWriter.close()

    print("[PlayerTest] Data exported to: " .. getDir() .. "/playerdata.json")
    return true
end

return JsonWriter