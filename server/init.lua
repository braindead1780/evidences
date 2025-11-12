math.randomseed(os.time()) -- Seed the PRNG

lib.locale()
lib.versionCheck("noobsystems/evidences")

if not LoadResourceFile(cache.resource, "html/dui/laptop/dist/index.html") then
    lib.print.error("Setup step missing: Download the script from the releases section (https://github.com/noobsystems/evidences/releases/latest) or build the laptop dui")
    return
end

if require "server.items" then
    local biometricData <const> = require "server.evidences.biometric_data"
    exports("getFingerprint", biometricData.getFingerprint)
    exports("getDNA", biometricData.getDNA)

    local api <const> = require "server.evidences.api"
    exports("get", api.get)

    require "server.evidences.target_actions"
    require "server.evidences.registry.fingerprint"

    -- require database after biometric_data module to ensure the biometric_data table is created first
    require "server.dui.database"
    require "server.dui.callbacks"
    require "server.dui.laptops"

    require "server.commands"
end