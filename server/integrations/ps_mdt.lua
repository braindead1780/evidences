-- Optional ps-mdt (Project Sloth MDT) integration
-- When ps-mdt is installed alongside this evidence script, this file:
--   1. Syncs each player's forensic fingerprint into ps-mdt's mdt_profiles table so
--      officers can see the same fingerprint identifier in both the evidence laptop and ps-mdt.
--   2. Fires "evidences:psMdtEvidenceAnalysed" when an evidence item is analysed, giving
--      ps-mdt (or any other script) a hook to create/update incident reports automatically.

if not GetResourceState("ps-mdt"):find("start") then
    return
end

local biometricsProvider <const> = require "server.biometrics.biometrics_provider"
local framework <const> = require "common.frameworks.framework"

lib.print.info("[evidences] ps-mdt detected – ps-mdt integration enabled.")

-- Writes this script's forensic fingerprint for a player into ps-mdt's mdt_profiles row.
-- Only sets the value when the column is currently NULL or empty so that manually entered
-- fingerprints in ps-mdt are not overwritten.
local function syncFingerprintWithPsMdt(playerId)
    local identifier <const> = framework.getIdentifier(playerId)
    if not identifier then return end

    local fingerprint <const> = biometricsProvider.getFingerprint(playerId)
    if not fingerprint then return end

    MySQL.update.await(
        [[
            INSERT INTO mdt_profiles (citizenid, fingerprint)
            VALUES (?, ?)
            ON DUPLICATE KEY UPDATE
                fingerprint = IF(fingerprint IS NULL OR fingerprint = '', ?, fingerprint)
        ]],
        identifier, fingerprint, fingerprint
    )
end

-- When a player finishes loading, give the biometrics provider a moment to initialise
-- their biometric record and then push the fingerprint to ps-mdt.
RegisterNetEvent("evidences:playerLoaded", function()
    local playerId <const> = source

    CreateThread(function()
        Wait(2000)
        syncFingerprintWithPsMdt(playerId)
    end)
end)

-- When any evidence item is marked as analysed by the evidence laptop, broadcast an event
-- that ps-mdt (or any third-party script) can listen to in order to attach the evidence to
-- an incident report.
--
-- Listener example (in your ps-mdt bridge or server script):
--   AddEventHandler("evidences:psMdtEvidenceAnalysed", function(officerId, item)
--       exports["ps-mdt"]:createReport({ ... })
--   end)
AddEventHandler("evidences:evidenceItemAnalysed", function(officerId, item)
    TriggerEvent("evidences:psMdtEvidenceAnalysed", officerId, item)
end)
