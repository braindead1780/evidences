local database <const> = require "server.database"

local framework = {}

function framework.getIdentifier(playerId)
    local player <const> = exports.qbx_core:GetPlayer(playerId)

    if player then
        local playerData <const> = player.PlayerData
        return playerData and playerData.citizenid or nil
    end
    
    return nil
end

function framework.getPlayerName(playerId)
    local player <const> = exports.qbx_core:GetPlayer(playerId)

    if player then
        local playerData <const> = player.PlayerData
        
        if playerData then
            local charinfo <const> = playerData.charinfo
            return charinfo and (charinfo.firstname .. " " .. charinfo.lastname) or "undefined"
        end
    end

    return "undefined"
end

function framework.getCitizens(searchText, limit, offset)
    local pattern <const> = "%" .. searchText:gsub("\\", "\\\\"):gsub("%%", "\\%%"):gsub("_", "\\_") .. "%"

    return database.query(
        [[
            SELECT
                citizenid AS identifier,
                CONCAT_WS(' ', JSON_VALUE(charinfo, '$.firstname'), JSON_VALUE(charinfo, '$.lastname')) AS fullName,
                JSON_VALUE(charinfo, '$.birthdate') AS birthdate,
                CASE
                    WHEN JSON_VALUE(charinfo, '$.gender') = '0' THEN 'male'
                    WHEN JSON_VALUE(charinfo, '$.gender') = '1' THEN 'female'
                    ELSE 'non_binary'
                END AS gender
            FROM players
            HAVING fullName LIKE ?
            LIMIT ? OFFSET ?
        ]],
        pattern, limit, offset
    )
end

function framework.getCitizen(identifier)
    return database.selectFirstRow(
        [[
            SELECT
                citizenid AS identifier,
                CONCAT_WS(' ', JSON_VALUE(charinfo, '$.firstname'), JSON_VALUE(charinfo, '$.lastname')) AS fullName,
                JSON_VALUE(charinfo, '$.birthdate') AS birthdate,
                CASE
                    WHEN JSON_VALUE(charinfo, '$.gender') = '0' THEN 'male'
                    WHEN JSON_VALUE(charinfo, '$.gender') = '1' THEN 'female'
                    ELSE 'non_binary'
                END AS gender
            FROM players
            WHERE citizenid = ?
        ]],
        identifier
    )
end

return framework