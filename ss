print("Start")
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Webhook
local WEBHOOK_URL = "https://discord.com/api/webhooks/1409010090517856297/mwsigy2jqmKyqbDp1DAgIrQp_40Ef6n4VUX8iFq0l1fWwzj22Ce2zz8mF9ezTAs5422k"
local Request = syn and syn.request or http_request or request or nil

local function sendToDiscord(content)
    if not Request then return end
    Request({
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = HttpService:JSONEncode({ content = content })
    })
end

-- Fungsi ambil teks dalam kurung
local function getBracketValue(text)
    return string.match(text, "%((.-)%)")
end

-- Listen event BigNotification
ReplicatedStorage.Remotes.Info.BigNotification.OnClientEvent:Connect(function(title, description, color)
    -- Pastikan ini Meteor Shower
    if string.find(title, "Meteor Shower") then
        -- Ambil username di dalam ()
        local id = getBracketValue(title)

        -- Kalau gak ada (), berarti case 1 atau 3 → skip
        if not id then
            return
        end

        -- Cari player berdasarkan username/displayname
        local targetPlayer
        for _, plr in ipairs(Players:GetPlayers()) do
            if string.lower(plr.Name) == string.lower(id)
            or string.lower(plr.DisplayName) == string.lower(id) then
                targetPlayer = plr
                break
            end
        end

        local level, displayName, username = "?", id, id
        if targetPlayer then
            displayName = targetPlayer.DisplayName
            username = targetPlayer.Name

            local leaderstats = targetPlayer:FindFirstChild("leaderstats")
            if leaderstats then
                local levelObj = leaderstats:FindFirstChild("Level")
                if levelObj then
                    level = levelObj.Value
                end
            end
        end

        -- Relative timestamp
        local unix = os.time()
        local timestamp = string.format("<t:%d:R>", unix)

        local message = string.format(
            "%s \\|\\| %s \\|\\| %s \\|\\| (%s) \\|\\|",
            timestamp,
            level,
            displayName,
            username
        )

        sendToDiscord(message)
    end
end)
