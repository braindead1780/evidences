local eventHandler <const> = require "common.events.handler"

local texture = {}
local replacedTextures = {}

function texture.replace(origTxtName, newDictName, newTxtName)
    -- The AddReplaceTexture native seems to only work when the related texture that should be replaced is loaded. This causes issues especially for players who have just connected.
    -- Therefore, we wait until the model has been loaded before replacing the texture (shoutout to https://discord.com/channels/813030955598086174/830737052352905217/1223793293037408349).
    lib.requestModel("p_laptop_02_s")
    AddReplaceTexture("p_laptop_02_s", origTxtName, newDictName, newTxtName)
    SetModelAsNoLongerNeeded("p_laptop_02_s")

    if not lib.table.contains(replacedTextures, origTxtName) then
        replacedTextures[#replacedTextures + 1] = origTxtName

        eventHandler.onLocal("onResourceStop", function(event)
            if event.arguments[1] == cache.resource then
                RemoveReplaceTexture("p_laptop_02_s", origTxtName)
            end
        end)
    end
end

-- Replace texture of p_laptop_02_s model with prop_laptop_02_ng
-- prop_laptop_02_ng cannot be used because it cannot play the open/close animation
local txd <const> = CreateRuntimeTxd("evidences")
CreateRuntimeTextureFromImage(txd, "laptop", "client/dui/laptops/texture/prop_laptop_02_ng.png")
texture.replace("prop_laptop_02b", "evidences", "laptop")

return texture